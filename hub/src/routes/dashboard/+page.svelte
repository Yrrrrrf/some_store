<script lang="ts">
    import { onMount } from 'svelte';
    import { Grid, List } from 'lucide-svelte';
    import ProductCard from './ProductCard.svelte';
    import UserCard from './UserCard.svelte';
    import Cart from './Cart.svelte';

    import {
        productStore,
        categoryStore,
        fetchProducts,
        fetchCategories,
        searchProducts,
        sortProducts,
        addToCart,
        type Product,
        type Category
    } from '$lib/stores/storeManager';
    import { Avatar, InputChip, Tab, TabGroup } from "@skeletonlabs/skeleton";

    let isLoading = true;
    let searchTerms: string[] = [];
    let sortBy: keyof Product = 'description';
    let sortOrder: 'asc' | 'desc' = 'asc';
    let selectedCategory = '';
    let viewMode: 'grid' | 'list' = 'grid';

    let products: Product[] = [];
    let categories: Category[] = [];

    const userId = 1; // Set the main Customer as the one with id = 1 for testing

    $: filteredAndSortedProducts = sortProducts(
        searchProducts(products, searchTerms.join(' '), selectedCategory),
        sortBy,
        sortOrder
    );

    productStore.subscribe(value => products = value);
    categoryStore.subscribe(value => categories = value);

    onMount(async () => {
        try {
            await Promise.all([fetchProducts(), fetchCategories()]);
        } catch (error) {
            console.error('Failed to fetch data:', error);
        } finally {
            isLoading = false;
        }
    });

    function handleSort(field: keyof Product) {
        if (sortBy === field) {
            sortOrder = sortOrder === 'asc' ? 'desc' : 'asc';
        } else {
            sortBy = field;
            sortOrder = 'asc';
        }
    }

    function handleAddToCart(product: Product) {
        addToCart(product);
    }
</script>

<main class="container mx-auto p-4 space-y-8">
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <UserCard {userId} />
        <div class="md:col-span-2">
            <h1 class="h1 mb-4">Product Dashboard</h1>
            <div class="card p-4 variant-soft-surface">
                <header class="card-header">
                    <h2 class="h3">Filters and Sorting</h2>
                </header>
                <section class="p-4 grid grid-cols-1 md:grid-cols-3 gap-4">
                    <InputChip bind:value={searchTerms} name="search" placeholder="Search products..." />
                    <select bind:value={selectedCategory} class="select select-bordered w-full max-w-xs">
                        <option value="">All Categories</option>
                        {#each categories as category}
                            <option value={category.id}>{category.name}</option>
                        {/each}
                    </select>
                    <div class="flex gap-2">
                        <button on:click={() => handleSort('description')} class="btn variant-soft">
                            Name {sortBy === 'description' ? (sortOrder === 'asc' ? '↑' : '↓') : ''}
                        </button>
                        <button on:click={() => handleSort('unit_price')} class="btn variant-soft">
                            Price {sortBy === 'unit_price' ? (sortOrder === 'asc' ? '↑' : '↓') : ''}
                        </button>
                    </div>
                </section>
            </div>
        </div>
    </div>

    <Cart {userId} />

    <div class="flex justify-end mb-4">
        <TabGroup>
            <Tab bind:group={viewMode} name="viewMode" value="grid"><Grid /></Tab>
            <Tab bind:group={viewMode} name="viewMode" value="list"><List /></Tab>
        </TabGroup>
    </div>

    {#if isLoading}
        <div class="flex justify-center items-center h-64">
            <Avatar initials="..." />
        </div>
    {:else if filteredAndSortedProducts.length === 0}
        <p class="text-center">No products found matching the current filters.</p>
    {:else}
        <div class={viewMode === 'grid' ? 'grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6' : 'space-y-4'}>
            {#each filteredAndSortedProducts as product (product.id)}
                <ProductCard {product} {viewMode} on:add-to-cart={() => addToCart(product)} />
            {/each}
        </div>
    {/if}
</main>