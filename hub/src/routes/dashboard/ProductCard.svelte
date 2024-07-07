<script lang="ts">
    import { snakeToCamelWithSpaces } from '$lib/utils/stringUtils';
    import { ProgressRadial, Toast } from '@skeletonlabs/skeleton';
    import { createEventDispatcher } from 'svelte';
    import { current_user_id } from '$lib/stores/app';
    import { apiClient } from '$lib/utils/api';
    import { triggerCartUpdate } from '$lib/stores/cartStore';
    import type { Product } from '$lib/stores/storeManager';

    export let product: Product;
    export let viewMode: 'grid' | 'list' = 'grid';

    let imageLoaded = false;
    let isHovered = false;
    let isAddingToCart = false;
    let toastMessage = '';

    const dispatch = createEventDispatcher<{
        'add-to-cart': Product;
    }>();

    function handleImageLoad() {
        imageLoaded = true;
    }

    async function handleAddToCart() {
        if (!$current_user_id) {
            toastMessage = 'Please select a customer before adding to cart.';
            return;
        }

        isAddingToCart = true;
        try {
            const cartItem = {
                customer_id: $current_user_id,
                product_id: product.id,
                quantity: 1
            };
            await apiClient.createRecord('cart', cartItem);
            dispatch('add-to-cart', product);
            triggerCartUpdate(); // Trigger cart update
            toastMessage = 'Product added to cart successfully!';
        } catch (error) {
            console.error('Error adding product to cart:', error);
            toastMessage = 'Failed to add product to cart. Please try again.';
        } finally {
            isAddingToCart = false;
        }
    }
</script>

<div
        class="card overflow-hidden transition-all duration-300 hover:shadow-xl cursor-pointer"
        class:scale-105={isHovered}
        on:mouseenter={() => isHovered = true}
        on:mouseleave={() => isHovered = false}
        on:keydown={(e) => e.key === 'Enter' && handleAddToCart()}
        role="button"
        tabindex="0"
>
    <div class={viewMode === 'grid' ? '' : 'flex'}>
        <header class={viewMode === 'grid' ? 'relative' : 'relative w-1/3'}>
            {#if !imageLoaded}
                <div class="w-full h-48 flex justify-center items-center bg-surface-200-700-token">
                    <ProgressRadial width="w-10" />
                </div>
            {/if}
            <img
                    src={product.image_url}
                    alt={product.description}
                    class="w-full h-48 object-cover transition-all duration-300"
                    class:opacity-0={!imageLoaded}
                    class:scale-110={!imageLoaded}
                    on:load={handleImageLoad}
            />
            <div class="absolute top-2 right-2 transition-all duration-300" class:scale-110={isHovered}>
                <span class="badge variant-filled-primary">{product.code}</span>
            </div>
        </header>
        <div class={viewMode === 'grid' ? 'p-4' : 'p-4 flex-1'}>
            <h2 class="h3 mb-2 line-clamp-2">{snakeToCamelWithSpaces(product.description)}</h2>
            <div class="flex justify-between items-center mt-4">
                <p class="text-lg font-bold text-primary-500">${product.unit_price.toFixed(2)}</p>
                <button
                        class="btn variant-filled-primary transition-all duration-300"
                        class:scale-110={isHovered}
                        on:click={handleAddToCart}
                        disabled={isAddingToCart}
                >
                    {#if isAddingToCart}
                        <ProgressRadial width="w-6" />
                    {:else}
                        Add to Cart
                    {/if}
                </button>
            </div>
        </div>
    </div>
</div>

{#if toastMessage}
    <Toast position="b" autohide={true} timeout={3000} on:close={() => toastMessage = ''}>
        {toastMessage}
    </Toast>
{/if}