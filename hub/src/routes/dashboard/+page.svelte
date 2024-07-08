<script lang="ts">
    import { onMount } from 'svelte';
    import { Grid, List, Filter } from 'lucide-svelte';
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
    import { fade, fly, slide } from 'svelte/transition';

    // State variables
    let isLoading = true;
    let searchTerms: string[] = [];
    let sortBy: string = 'product_name';
    let sortOrder: 'asc' | 'desc' = 'asc';
    let selectedCategory = '';
    let selectedProvider = '';
    let viewMode: 'grid' | 'list' = 'grid';
    let onlyInStock = false;
    let showFilters = false;

    let products: any[] = [];
    let categories: Category[] = [];
    let providers: string[] = [];

    // Subscribe to category store
    categoryStore.subscribe(value => categories = value);

    $: filteredAndSortedProducts = products
        .filter(product =>
            (searchTerms.length === 0 || searchTerms.some(term =>
                product.product_name.toLowerCase().includes(term.toLowerCase()) ||
                product.product_code.toLowerCase().includes(term.toLowerCase())
            )) &&
            (selectedCategory === '' || product.category_name === selectedCategory) &&
            (selectedProvider === '' || product.provider_name === selectedProvider) &&
            (!onlyInStock || product.inventory > 0)
        )
        .sort((a, b) => {
            if (a[sortBy] < b[sortBy]) return sortOrder === 'asc' ? -1 : 1;
            if (a[sortBy] > b[sortBy]) return sortOrder === 'asc' ? 1 : -1;
            return 0;
        });

    async function initializeDashboard() {
        try {
            await Promise.all([fetchProducts(), fetchCategories(), fetchProviders()]);
        } catch (error) {
            console.error('Failed to fetch data:', error);
        } finally {
            isLoading = false;
        }
    }

    async function fetchProducts() {
        try {
            products = await apiClient.fetchRows('view_product_details', {}, true);
        } catch (error) {
            console.error('Failed to fetch products:', error);
        }
    }

    async function fetchProviders() {
        try {
            const providerData = await apiClient.fetchRows('provider');
            providers = providerData.map(p => p.name);
        } catch (error) {
            console.error('Failed to fetch providers:', error);
        }
    }

    function handleSort(field: string) {
        if (sortBy === field) {
            sortOrder = sortOrder === 'asc' ? 'desc' : 'asc';
        } else {
            sortBy = field;
            sortOrder = 'asc';
        }
    }

    function handleAddToCart(event: CustomEvent) {
        const product = event.detail;
        addToCart(product);
    }

    function toggleFilters() {
        showFilters = !showFilters;
    }

    onMount(initializeDashboard);
</script>

<main class="container mx-auto p-4 space-y-8" in:fade={{ duration: 300 }}>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <UserCard />
        <div class="md:col-span-2">
            <h1 class="h1 mb-4">Product Dashboard</h1>
            <div class="card p-4 variant-soft-surface">
                <header class="card-header flex justify-between items-center">
                    <h2 class="h3">Filters and Sorting</h2>
                    <button class="btn variant-ghost-surface" on:click={toggleFilters}>
                        <Filter size={20} />
                        {showFilters ? 'Hide Filters' : 'Show Filters'}
                    </button>
                </header>
                {#if showFilters}
                    <section class="p-4 grid grid-cols-1 md:grid-cols-2 gap-4" in:slide={{ duration: 300 }}>
                        <InputChip bind:value={searchTerms} name="search" placeholder="Search products..." />
                        <select bind:value={selectedCategory} class="select select-bordered w-full">
                            <option value="">All Categories</option>
                            {#each categories as category}
                                <option value={category.name}>{category.name}</option>
                            {/each}
                        </select>
                        <select bind:value={selectedProvider} class="select select-bordered w-full">
                            <option value="">All Providers</option>
                            {#each providers as provider}
                                <option value={provider}>{provider}</option>
                            {/each}
                        </select>
                        <div class="flex items-center space-x-4">
                            <button on:click={() => handleSort('product_name')} class="btn variant-soft flex-grow">
                                Name {sortBy === 'product_name' ? (sortOrder === 'asc' ? '↑' : '↓') : ''}
                            </button>
                            <button on:click={() => handleSort('unit_price')} class="btn variant-soft flex-grow">
                                Price {sortBy === 'unit_price' ? (sortOrder === 'asc' ? '↑' : '↓') : ''}
                            </button>
                            <label class="flex items-center space-x-2 cursor-pointer">
                                <input type="checkbox" bind:checked={onlyInStock} class="checkbox" />
                                <span>In Stock</span>
                            </label>
                        </div>
                    </section>
                {/if}
            </div>
        </div>
    </div>

    <div class="flex justify-end mb-4" in:fly={{ y: 20, duration: 300 }}>
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
        <p class="text-center" in:fade>No products found matching the current filters.</p>
    {:else}
        <div class={viewMode === 'grid' ? 'grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6' : 'space-y-4'}
             in:fade={{ duration: 300, delay: 300 }}>
            {#each filteredAndSortedProducts as product (product.product_id)}
                <div in:fly={{ y: 20, duration: 300, delay: 300 + 50 * filteredAndSortedProducts.indexOf(product) }}>
                    <ProductCard productId={product.product_id} {viewMode} on:add-to-cart={handleAddToCart} />
                </div>
            {/each}
        </div>
    {/if}
</main>