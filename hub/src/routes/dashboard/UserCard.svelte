<script lang="ts">
    import { onMount } from 'svelte';
    import { Avatar, ProgressRadial } from '@skeletonlabs/skeleton';
    import { User, ShoppingCart, DollarSign } from 'lucide-svelte';
    import { current_user_id } from '$lib/stores/app';
    import apiClient from '$lib/utils/api';
    import { popup, type PopupSettings } from '@skeletonlabs/skeleton';
    import CartSummary from '$lib/components/store/CartSummary.svelte';
    import { goto } from '$app/navigation';
    import type { CartItem, Product } from '$lib/types';
    import { cartUpdateTrigger } from '$lib/stores/cartStore';

    /**
     * Represents a customer in the system.
     */
    interface Customer {
        id: number;
        name: string;
    }

    let user: Customer | null = null;
    let isLoading = true;
    let error: string | null = null;
    let cartItems: CartItem[] = [];
    let productDetails: Map<number, Product> = new Map();

    /**
     * Calculates the total price of items in the cart.
     */
    $: total = cartItems.reduce((sum, item) => {
        const product = productDetails.get(item.product_id);
        return sum + (product ? item.quantity * product.unit_price : 0);
    }, 0);

    /**
     * Fetches user data from the API.
     * @param userId - The ID of the user to fetch.
     */
    async function fetchUserData(userId: number) {
        isLoading = true;
        error = null;
        try {
            const response = await apiClient.fetchRows<Customer>('customer', { id: userId.toString() });
            if (response.length > 0) {
                user = response[0];
                await fetchCartItems(userId);
            } else {
                error = 'User not found';
            }
        } catch (e) {
            console.error('Error fetching user data:', e);
            error = 'Failed to load user data';
        } finally {
            isLoading = false;
        }
    }

    /**
     * Fetches cart items for the user.
     * @param userId - The ID of the user whose cart items to fetch.
     */
    async function fetchCartItems(userId: number) {
        try {
            cartItems = await apiClient.fetchRows<CartItem>('cart', { customer_id: userId.toString() });
            await fetchProductDetails();
        } catch (e) {
            console.error('Error fetching cart items:', e);
        }
    }

    /**
     * Fetches product details for items in the cart.
     */
    async function fetchProductDetails() {
        const productIds = [...new Set(cartItems.map(item => item.product_id))];
        for (const productId of productIds) {
            if (!productDetails.has(productId)) {
                try {
                    const [product] = await apiClient.fetchRows<Product>('product', { id: productId.toString() });
                    if (product) {
                        productDetails.set(productId, product);
                    }
                } catch (e) {
                    console.error(`Error fetching product details for ID ${productId}:`, e);
                }
            }
        }
        productDetails = new Map(productDetails);
    }

    /**
     * Handles updating the quantity of an item in the cart.
     * @param item - The cart item to update.
     * @param change - The amount to change the quantity by.
     */
    async function handleUpdateQuantity(item: CartItem, change: number) {
        const newQuantity = item.quantity + change;
        if (newQuantity > 0) {
            try {
                await apiClient.updateRecord('cart', 'id', item.id, { quantity: newQuantity });
                item.quantity = newQuantity;
                cartItems = [...cartItems];
            } catch (e) {
                console.error('Error updating quantity:', e);
            }
        } else {
            handleRemoveItem(item);
        }
    }

    /**
     * Handles removing an item from the cart.
     * @param item - The cart item to remove.
     */
    async function handleRemoveItem(item: CartItem) {
        try {
            await apiClient.deleteRecord('cart', 'id', item.id);
            cartItems = cartItems.filter(i => i.id !== item.id);
        } catch (e) {
            console.error('Error removing item:', e);
        }
    }

    /**
     * Navigates to the sales dashboard.
     */
    function goToSales() {
        goto('/dashboard/sales');
    }

    /**
     * Popup settings for the cart.
     */
    const popupCart: PopupSettings = {
        event: 'click',
        target: 'popupCart',
        placement: 'bottom',
        closeQuery: '.close-popup'
    };

    // Reactive statement to update cart when triggered
    $: {
        if ($cartUpdateTrigger) {
            fetchCartItems($current_user_id);
        }
    }

    onMount(() => {
        const unsubscribe = current_user_id.subscribe(userId => {
            fetchUserData(userId);
        });

        return unsubscribe;
    });

    /**
     * Closes the cart popup.
     */
    function closePopup() {
        const popupElement = document.querySelector('[data-popup="popupCart"]');
        if (popupElement) {
            popupElement.classList.remove('active');
        }
    }

    /**
     * Navigates to the checkout page.
     */
    function goToCheckout() {
        closePopup();
        goto('/dashboard/checkout');
    }
</script>

<div class="card p-4 variant-soft-surface">
    {#if isLoading}
        <div class="flex justify-center items-center h-32">
            <ProgressRadial />
        </div>
    {:else if error}
        <p class="text-error-500">{error}</p>
    {:else if user}
        <header class="card-header flex flex-col items-center gap-4 text-center">
            <div>
                <h3 class="h3">{user.name}</h3>
                <p class="text-sm opacity-70">Customer</p>
            </div>
        </header>
        <section class="p-4 flex justify-center gap-4">
            <button
                    class="variant-filled-primary flex items-center gap-2 rounded-xl p-4"
                    use:popup={popupCart}
            >
                <ShoppingCart size={24} />
                Cart ({cartItems.length})
            </button>
            <button
                    class="variant-filled-secondary flex items-center gap-2 rounded-xl p-4"
                    on:click={goToSales}
            >
                <DollarSign size={24} />
                Sales
            </button>
        </section>
    {:else}
        <p>No user data available</p>
    {/if}
</div>

<!-- Cart popup -->
<div class="card variant-filled-surface cart-popup" data-popup="popupCart">
    <div class="cart-content">
        <CartSummary
                {cartItems}
                {productDetails}
                editable={true}
                onUpdateQuantity={handleUpdateQuantity}
                onRemoveItem={handleRemoveItem}
        />
    </div>
    <div class="cart-footer p-4">
        <div class="flex justify-between items-center mb-4">
            <span class="text-lg font-semibold">Total:</span>
            <span class="text-xl font-bold">${total.toFixed(2)}</span>
        </div>
        <button class="btn variant-filled-primary w-full" on:click={goToCheckout}>
            Proceed to Checkout
        </button>
    </div>
</div>

<style>
    .cart-popup {
        position: absolute;
        z-index: 1000;
        width: 420px;
        max-height: 80vh;
        display: flex;
        flex-direction: column;
    }
    .cart-content {
        flex-grow: 1;
        overflow-y: auto;
        max-height: calc(60vh - 120px); /* Adjust based on your footer height */
        padding: 1rem;
    }
    .cart-footer {
        background-color: var(--color-surface-100);
        border-top: 1px solid var(--color-surface-300);
    }
</style>