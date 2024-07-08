<script lang="ts">
    import { onMount } from 'svelte';
    import { current_user_id } from '$lib/stores/app';
    import { apiClient } from '$lib/utils/api';
    import { ProgressRadial } from '@skeletonlabs/skeleton';
    import { ShoppingBag, AlertCircle } from 'lucide-svelte';
    import SalesHistory from '$lib/components/sales/SalesHistory.svelte';
    import { fade, fly } from 'svelte/transition';

    let sales: any[] = [];
    let isLoading = true;
    let error: string | null = null;

    onMount(async () => {
        try {
            // Fetch sales data for the current user
            sales = await apiClient.fetchRows('sale', { customer_id: $current_user_id.toString() });
            // Fetch all sales data to filter out sales that don't exist
            const allSales = await apiClient.fetchRows('view_neo_sale', {}, true);
            // Filter out sales that don't exist
            sales = sales.filter(sale => allSales.some(s => s.sale_id === sale.id));
            console.log('Filtered sales data:', sales);
            // get the id list of this user's sales
            const saleIds = sales.map(sale => sale.id);

            // select from the allSales array only the sales that are in the saleIds list
            sales = allSales.filter(sale => saleIds.includes(sale.sale_id));

            isLoading = false;
        } catch (e) {
            console.error('Error fetching sales data:', e);
            error = 'Failed to load sales data';
            isLoading = false;
        }
    });
</script>

<div class="container mx-auto p-4" in:fade={{ duration: 300 }}>
    <header class="mb-8">
        <h1 class="h1 flex items-center gap-2">
            <ShoppingBag size={48} />
            Sales History
        </h1>
    </header>

    {#if isLoading}
        <div class="flex justify-center items-center h-64" in:fade>
            <ProgressRadial />
        </div>
    {:else if error}
        <div class="p-4 text-center" in:fly={{ y: 20, duration: 300 }}>
            <AlertCircle size={48} class="mx-auto mb-4 text-error-500" />
            <p class="text-error-500 text-xl">{error}</p>
        </div>
    {:else if sales.length === 0}
        <div class="p-4 text-center" in:fly={{ y: 20, duration: 300 }}>
            <ShoppingBag size={48} class="mx-auto mb-4 text-primary-500" />
            <p class="text-xl">No sales history found</p>
        </div>
    {:else}
        <div class="grid grid-cols-1 gap-8" in:fly={{ y: 20, duration: 300 }}>
            <SalesHistory {sales} />
        </div>
    {/if}
</div>