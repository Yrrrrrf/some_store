<script lang="ts">
    import { onMount } from 'svelte';
    import { apiClient } from '$lib/utils/api';
    import { current_user_id } from '$lib/stores/app';
    import { ProgressRadial } from '@skeletonlabs/skeleton';
    import { ShoppingCart } from 'lucide-svelte';
    import CartSummary from '$lib/components/store/CartSummary.svelte';
    import CheckoutForm from '$lib/components/store/CheckoutForm.svelte';
    import SaleSuccess from '$lib/components/store/SaleSuccess.svelte';
    import { fetchCartItems, fetchProductDetails } from '$lib/utils/cartUtils';
    import type { CartItem, Product } from '$lib/types';

    let cartItems: CartItem[] = [];
    let productDetails: Map<number, Product> = new Map();
    let isLoading = true;
    let error: string | null = null;
    let saleCompleted = false;

    $: total = cartItems.reduce((sum, item) => {
        const product = productDetails.get(item.product_id);
        return sum + (product ? item.quantity * product.unit_price : 0);
    }, 0);

    async function handleUpdateQuantity(item: CartItem, change: number) {
        const newQuantity = item.quantity + change;
        if (newQuantity > 0) {
            try {
                await apiClient.updateRecord('cart', 'id', item.id, { quantity: newQuantity });
                item.quantity = newQuantity;
                cartItems = [...cartItems];
            } catch (e) {
                console.error('Error updating quantity:', e);
                error = 'Failed to update quantity';
            }
        } else {
            handleRemoveItem(item);
        }
    }

    async function handleRemoveItem(item: CartItem) {
        try {
            await apiClient.deleteRecord('cart', 'id', item.id);
            cartItems = cartItems.filter(i => i.id !== item.id);
        } catch (e) {
            console.error('Error removing item:', e);
            error = 'Failed to remove item';
        }
    }

    function saleSuccess() {
        console.log('Sale successful');
        saleCompleted = true;
    }

    onMount(async () => {
        try {
            cartItems = await fetchCartItems($current_user_id);
            productDetails = await fetchProductDetails(cartItems);
        } catch (e) {
            console.error('Error fetching data:', e);
            error = 'Failed to load checkout data';
        } finally {
            isLoading = false;
        }
    });
</script>

<div class="container mx-auto p-4">
    <header class="mb-8">
        <h1 class="h1 flex items-center gap-2">
            <ShoppingCart size={48} />
            Checkout
        </h1>
    </header>

    {#if isLoading}
        <div class="flex justify-center items-center h-64">
            <ProgressRadial />
        </div>
    {:else if error}
        <p class="text-error-500 p-4 text-center">{error}</p>
    {:else if cartItems.length === 0}
        <p class="p-4 text-center text-xl">Your cart is empty</p>
    {:else if saleCompleted}
        <SaleSuccess />
    {:else}
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
            <div class="card variant-soft-surface">
                <h2 class="h3 p-4 border-b border-surface-300">Order Summary</h2>
                <div class="cart-summary-container">
                    <CartSummary
                            {cartItems}
                            {productDetails}
                            editable={true}
                            onUpdateQuantity={handleUpdateQuantity}
                            onRemoveItem={handleRemoveItem}
                    />
                </div>
                <div class="p-4 border-t border-surface-300">
                    <div class="flex justify-between items-center">
                        <span class="text-lg font-semibold">Total:</span>
                        <span class="text-xl font-bold">${total.toFixed(2)}</span>
                    </div>
                </div>
            </div>
            <div class="card variant-soft-surface">
                <h2 class="h3 p-4 border-b border-surface-300">Checkout Details</h2>
                <div class="checkout-form-container">
                    <CheckoutForm
                            {total}
                            {cartItems}
                            {productDetails}
                            on:sale-success={() => saleSuccess()}
                    />
                </div>
            </div>
        </div>
    {/if}
</div>

<style>
    .container {
        max-width: 1200px;
    }
    .cart-summary-container, .checkout-form-container {
        max-height: calc(80vh - 200px);
        overflow-y: auto;
        padding: 1rem;
    }
</style>
