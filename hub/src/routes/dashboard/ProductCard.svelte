<script lang="ts">
    import { snakeToCamelWithSpaces } from '$lib/utils/stringUtils';
    import { ProgressRadial } from '@skeletonlabs/skeleton';
    import { createEventDispatcher } from 'svelte';
    import type { Product } from '$lib/stores/storeManager';

    export let product: Product;
    export let viewMode: 'grid' | 'list' = 'grid';

    let imageLoaded = false;
    let isHovered = false;

    const dispatch = createEventDispatcher<{
        'add-to-cart': Product;
    }>();

    function handleImageLoad() {
        imageLoaded = true;
    }

    function handleAddToCart() {
        dispatch('add-to-cart', product);
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
                >
                    Add to Cart
                </button>
            </div>
        </div>
    </div>
</div>