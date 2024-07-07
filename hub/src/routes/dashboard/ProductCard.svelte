<script lang="ts">
    import { snakeToCamelWithSpaces } from '../../utils';
    import { ProgressRadial } from '@skeletonlabs/skeleton';
    import { createEventDispatcher } from 'svelte';

    export let product: {
        id: number;
        code: string;
        description: string;
        unit_price: number;
        image_url: string;
        category_id: number;
    };

    let imageLoaded = false;
    let isHovered = false;

    const dispatch = createEventDispatcher();

    function handleImageLoad() {
        imageLoaded = true;
    }

    function handleClick() {
        console.log('Product clicked:', product);
        // dispatch('add-to-cart', product);
    }

    function handleBigCard() {
        console.log('Displaying big card:', product);
        // dispatch('add-to-cart', product);
    }
</script>

<div
        class="card overflow-hidden transition-all duration-300 hover:shadow-xl cursor-pointer"
        class:scale-105={isHovered}
        on:mouseenter={() => isHovered = true}
        on:mouseleave={() => isHovered = false}
        on:keydown={(e) => e.key === 'Enter' && handleClick()}
        role="button"
        tabindex="0"
>
    <header class="relative">
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
            <span class="badge variant-filled-primary" >{product.code}</span>
        </div>
    </header>
    <div class="p-4">
        <h2 class="h3 mb-2 line-clamp-2">{snakeToCamelWithSpaces(product.description)}</h2>
        <div class="flex justify-between items-center mt-4">
            <p class="text-lg font-bold text-primary-500">${product.unit_price.toFixed(2)}</p>
            <button class="btn variant-filled-primary transition-all duration-300" class:scale-110={isHovered} on:click={handleClick}>
                Add to Cart
            </button>
        </div>
    </div>
</div>
