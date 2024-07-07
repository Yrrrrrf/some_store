<script lang="ts">
    import { onMount } from 'svelte';
    import { apiClient } from '$lib/utils/api';
    import { current_user_id } from '$lib/stores/app';
    import { ProgressRadial } from '@skeletonlabs/skeleton';
    import { ShoppingCart } from 'lucide-svelte';
    import CartSummary from '$lib/components/store/CartSummary.svelte';
    import CheckoutForm from '$lib/components/store/CheckoutForm.svelte';
    import { fetchCartItems, fetchProductDetails } from '$lib/utils/cartUtils';
    import type { CartItem, Product } from '$lib/types';

    let cartItems: CartItem[] = [];
    let productDetails: Map<number, Product> = new Map();
    let isLoading = true;
    let error: string | null = null;

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

    function handleCheckout(event: CustomEvent) {
        const orderData = event.detail;
        console.log('Order placed:', orderData);
        // Implement order processing logic here
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

<div class="card p-4 variant-ghost-surface">
    <header class="card-header flex justify-between items-center">
        <h3 class="h3 flex items-center gap-2">
            <ShoppingCart size={24} />
            Checkout
        </h3>
    </header>

    {#if isLoading}
        <div class="flex justify-center items-center h-32">
            <ProgressRadial />
        </div>
    {:else if error}
        <p class="text-error-500 p-4">{error}</p>
    {:else if cartItems.length === 0}
        <p class="p-4 text-center">Your cart is empty</p>
    {:else}
        <CartSummary
                {cartItems}
                {productDetails}
                editable={true}
                onUpdateQuantity={handleUpdateQuantity}
                onRemoveItem={handleRemoveItem}
        />
        <CheckoutForm
                {total}
                {cartItems}
                {productDetails}
                on:checkout={handleCheckout}
        />
    {/if}
</div>