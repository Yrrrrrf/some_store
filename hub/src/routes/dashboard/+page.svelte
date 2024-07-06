<script lang="ts">
    import { onMount } from 'svelte';
    import ProductCard from './ProductCard.svelte';
    import { api_url, productStore, fetchProducts, searchProducts, sortProducts } from '../../utils';
    import { writable } from 'svelte/store';

    let isLoading = true;
    let searchTerm = '';
    let sortBy = 'description';
    let sortOrder: 'asc' | 'desc' = 'asc';
    let categories: { id: number; name: string }[] = [];
    let selectedCategory = '';

    $: filteredAndSortedProducts = sortProducts(
        searchProducts($productStore, searchTerm, selectedCategory),
        sortBy,
        sortOrder
    );

    async function fetchCategories(apiUrl: string): Promise<void> {
        try {
            const response = await fetch(`${apiUrl}/category`);
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            categories = await response.json();
        } catch (error) {
            console.error('Error fetching categories:', error);
            // Handle error (e.g., show error message to user)
        }
    }

    onMount(async () => {
        try {
            await Promise.all([fetchProducts($api_url), fetchCategories($api_url)]);
        } catch (error) {
            console.error('Failed to fetch data:', error);
            // Handle error (e.g., show error message to user)
        } finally {
            isLoading = false;
        }
    });

    function handleSort(field: string) {
        if (sortBy === field) {
            sortOrder = sortOrder === 'asc' ? 'desc' : 'asc';
        } else {
            sortBy = field;
            sortOrder = 'asc';
        }
    }
</script>

<svelte:head>
    <title>Dashboard - Product Overview</title>
</svelte:head>

<div class="container mx-auto p-4">
    <h1 class="text-3xl font-bold mb-6">Product Dashboard</h1>

    <div class="flex flex-wrap gap-4 mb-4">
        <input
                type="text"
                bind:value={searchTerm}
                placeholder="Search products..."
                class="input input-bordered w-full max-w-xs"
        />
        <select
                bind:value={selectedCategory}
                class="select select-bordered w-full max-w-xs"
        >
            <option value="">All Categories</option>
            {#each categories as category}
                <option value={category.id}>{category.name}</option>
            {/each}
        </select>
    </div>

    <div class="mb-4">
        <button on:click={() => handleSort('description')} class="btn btn-sm mr-2">
            Sort by Name {sortBy === 'description' ? (sortOrder === 'asc' ? '↑' : '↓') : ''}
        </button>
        <button on:click={() => handleSort('unit_price')} class="btn btn-sm">
            Sort by Price {sortBy === 'unit_price' ? (sortOrder === 'asc' ? '↑' : '↓') : ''}
        </button>
    </div>

    {#if isLoading}
        <div class="flex justify-center items-center h-64">
            <div class="loader">Loading...</div>
        </div>
    {:else if filteredAndSortedProducts.length === 0}
        <p>No products found matching the current filters.</p>
    {:else}
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {#each filteredAndSortedProducts as product (product.id)}
                <ProductCard {product} />
            {/each}
        </div>
    {/if}
</div>