<script lang="ts">
    import { snakeToCamelWithSpaces } from '$lib/utils/stringUtils';
    import { ProgressRadial, Toast } from '@skeletonlabs/skeleton';
    import { createEventDispatcher, onMount } from 'svelte';
    import { current_user_id } from '$lib/stores/app';
    import { apiClient } from '$lib/utils/api';
    import { triggerCartUpdate } from '$lib/stores/cartStore';

    export let productId: number;
    export let viewMode: 'grid' | 'list' = 'grid';

    let product: any = null;
    let imageLoaded = false;
    let isHovered = false;
    let isAddingToCart = false;
    let toastMessage = '';
    let imageUrl = '';
    let possiblePaths: string[] = [];

    const dispatch = createEventDispatcher<{
        'add-to-cart': { customer_id: number; product_id: number; quantity: number };
    }>();

    onMount(async () => {
        try {
            const products = await apiClient.fetchRows('view_product_details', { product_id: productId.toString() }, true);
            if (products.length > 0) {
                product = products[0];
                imageUrl = getImageUrl(product.image_url);
            }
        } catch (error) {
            console.error('Error fetching product details:', error);
        }
    });

    function getImageUrl(originalUrl: string): string {
        if (!originalUrl) {
            return `https://placehold.co/512x512?text=${encodeURIComponent(product.product_name)}`;
        }

        if (originalUrl.startsWith('http://') || originalUrl.startsWith('https://')) {
            return originalUrl;
        }

        possiblePaths = [
            // `/uploads/${originalUrl}`,
            // `/static/uploads/${originalUrl}`,
            originalUrl,
        ];

        return possiblePaths[0];
    }

    function handleImageError() {
        const currentIndex = possiblePaths.indexOf(imageUrl);
        if (currentIndex < possiblePaths.length - 1) {
            imageUrl = possiblePaths[currentIndex + 1];
        } else {
            imageUrl = `https://placehold.co/512x512?text=${encodeURIComponent(product.product_name)}`;
        }
    }

    async function handleAddToCart() {
        if (!$current_user_id) {
            toastMessage = 'Please select a customer before adding to cart.';
            return;
        }

        if (product.inventory < 1) {
            toastMessage = 'This product is out of stock.';
            return;
        }

        isAddingToCart = true;
        try {
            const cartItem = {
                customer_id: $current_user_id,
                product_id: product.product_id,
                quantity: 1
            };

            // Dispatch the event with the correct cart item data
            dispatch('add-to-cart', cartItem);

            // Call the API to add the item to the cart
            await apiClient.createRecord('cart', cartItem);

            triggerCartUpdate();
            toastMessage = 'Product added to cart successfully!';
        } catch (error) {
            console.error('Error adding product to cart:', error);
            toastMessage = 'Failed to add product to cart. Please try again.';
        } finally {
            isAddingToCart = false;
        }
    }
</script>

{#if product}
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
                <img
                        src={imageUrl}
                        alt={product.product_name}
                        class="w-full h-48 object-cover transition-all duration-300"
                        on:error={handleImageError}
                        on:load={() => imageLoaded = true}
                />
                {#if !imageLoaded}
                    <div class="absolute inset-0 flex justify-center items-center bg-surface-200-700-token">
                        <ProgressRadial width="w-10" />
                    </div>
                {/if}
                <div class="absolute top-2 right-2 transition-all duration-300" class:scale-110={isHovered}>
                    <span class="badge variant-filled-primary">{product.product_code}</span>
                </div>
                {#if product.inventory < 1}
                    <div class="absolute inset-0 bg-surface-900-700-token bg-opacity-70 flex items-center justify-center">
                        <span class="text-xl font-bold text-error-500">Out of Stock</span>
                    </div>
                {/if}
            </header>
            <div class={viewMode === 'grid' ? 'p-4' : 'p-4 flex-1'}>
                <h2 class="h3 mb-2 line-clamp-2">{snakeToCamelWithSpaces(product.product_name)}</h2>
                <p class="text-sm mb-2">Category: {product.category_name}</p>
                <div class="flex justify-between items-center mt-4">
                    <p class="text-lg font-bold text-primary-500">${product.unit_price.toFixed(2)}</p>
                    <button
                            class="btn variant-filled-primary transition-all duration-300"
                            class:scale-110={isHovered}
                            on:click={handleAddToCart}
                            disabled={isAddingToCart || product.inventory < 1}
                    >
                        {#if isAddingToCart}
                            <ProgressRadial width="w-6" />
                        {:else if product.inventory < 1}
                            Out of Stock
                        {:else}
                            Add to Cart
                        {/if}
                    </button>
                </div>
                {#if product.inventory > 0 && product.inventory < 15}
                    <p class="text-sm text-warning-500 mt-2">Only {product.inventory} left in stock!</p>
                {/if}
            </div>
        </div>
    </div>
{:else}
    <div class="card p-4 flex justify-center items-center h-48">
        <ProgressRadial width="w-10" />
    </div>
{/if}

{#if toastMessage}
    <Toast position="b" autohide={true} timeout={3000} on:close={() => toastMessage = ''}>
        {toastMessage}
    </Toast>
{/if}
