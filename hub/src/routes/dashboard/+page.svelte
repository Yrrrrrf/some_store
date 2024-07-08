<script lang="ts">
    import { onMount } from 'svelte';
    import { Grid, List } from 'lucide-svelte';
    import ProductCard from './ProductCard.svelte';
    import UserCard from './UserCard.svelte';
    import { Avatar, InputChip, Tab, TabGroup } from "@skeletonlabs/skeleton";
    import { apiClient } from '$lib/utils/api';
    import {
        categoryStore,
        fetchCategories,
        addToCart,
        type Category
    } from '$lib/stores/storeManager';

    // State variables
    let isLoading = true;
    let searchTerms: string[] = [];
    let sortBy: string = 'product_name';
    let sortOrder: 'asc' | 'desc' = 'asc';
    let selectedCategory = '';
    let viewMode: 'grid' | 'list' = 'grid';
    let onlyInStock = false;

    let products: any[] = [];
    let categories: Category[] = [];

    // Subscribe to category store
    categoryStore.subscribe(value => categories = value);

    /**
     * Filters and sorts products based on current search terms, category, and sorting criteria.
     */
    $: filteredAndSortedProducts = products
        .filter(product =>
            (searchTerms.length === 0 || searchTerms.some(term =>
                product.product_name.toLowerCase().includes(term.toLowerCase()) ||
                product.product_code.toLowerCase().includes(term.toLowerCase())
            )) &&
            (selectedCategory === '' || product.category_name === selectedCategory) &&
            (!onlyInStock || product.inventory > 0)
        )
        .sort((a, b) => {
            if (a[sortBy] < b[sortBy]) return sortOrder === 'asc' ? -1 : 1;
            if (a[sortBy] > b[sortBy]) return sortOrder === 'asc' ? 1 : -1;
            return 0;
        });

    /**
     * Initializes the dashboard by fetching necessary data.
     */
    async function initializeDashboard() {
        try {
            await Promise.all([fetchProducts(), fetchCategories()]);
        } catch (error) {
            console.error('Failed to fetch data:', error);
        } finally {
            isLoading = false;
        }
    }

    /**
     * Fetches products from the API.
     */
    async function fetchProducts() {
        try {
            products = await apiClient.fetchRows('view_product_details', {}, true);
        } catch (error) {
            console.error('Failed to fetch products:', error);
        }
    }

    /**
     * Handles sorting of products.
     * @param field - The field to sort by.
     */
    function handleSort(field: string) {
        if (sortBy === field) {
            sortOrder = sortOrder === 'asc' ? 'desc' : 'asc';
        } else {
            sortBy = field;
            sortOrder = 'asc';
        }
    }

    /**
     * Handles adding a product to the cart.
     * @param event - The custom event containing the product details.
     */
    function handleAddToCart(event: CustomEvent) {
        const product = event.detail;
        addToCart(product);
    }

    onMount(initializeDashboard);
</script>

<main class="container mx-auto p-4 space-y-8">
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <UserCard />
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
                            <option value={category.name}>{category.name}</option>
                        {/each}
                    </select>
                    <div class="flex gap-2">
                        <button on:click={() => handleSort('product_name')} class="btn variant-soft">
                            Name {sortBy === 'product_name' ? (sortOrder === 'asc' ? '↑' : '↓') : ''}
                        </button>
                        <button on:click={() => handleSort('unit_price')} class="btn variant-soft">
                            Price {sortBy === 'unit_price' ? (sortOrder === 'asc' ? '↑' : '↓') : ''}
                        </button>
                        <div class="flex items-center">
                            <input type="checkbox" id="inStock" bind:checked={onlyInStock} class="mr-2" />
                            <label for="inStock" class="select-none">In Stock</label>
                        </div>
                    </div>
                </section>
            </div>
        </div>
    </div>

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
            {#each filteredAndSortedProducts as product (product.product_id)}
                <ProductCard productId={product.product_id} {viewMode} on:add-to-cart={handleAddToCart} />
            {/each}
        </div>
    {/if}
</main>
