<script lang="ts">
    import { onMount } from 'svelte';
    import { current_user_id } from '$lib/stores/app';
    import { apiClient } from '$lib/utils/api';
    import { ProgressRadial } from '@skeletonlabs/skeleton';
    import { ShoppingBag } from 'lucide-svelte';
    import SalesHistory from '$lib/components/sales/SalesHistory.svelte';
    import SalesSummary from '$lib/components/sales/SalesSummary.svelte';
    import SalesChart from '$lib/components/sales/SalesChart.svelte';

    let sales: any[] = [];
    let isLoading = true;
    let error: string | null = null;

    onMount(async () => {
        try {
            // Fetch sales data for the current user
            sales = await apiClient.fetchRows('sale', { customer_id: $current_user_id.toString() });
            console.log('Sales data:', sales);
            isLoading = false;
        } catch (e) {
            console.error('Error fetching sales data:', e);
            error = 'Failed to load sales data';
            isLoading = false;
        }
    });
</script>

<div class="container mx-auto p-4">
    <header class="mb-8">
        <h1 class="h1 flex items-center gap-2">
            <ShoppingBag size={48} />
            Sales History
        </h1>
    </header>

    {#if isLoading}
        <div class="flex justify-center items-center h-64">
            <ProgressRadial />
        </div>
        asasas
    {:else if error}
        2
        <p class="text-error-500 p-4 text-center">{error}</p>
    {:else if sales.length === 0}
        333
        <p class="p-4 text-center text-xl">No sales history found</p>
    {:else}
        44444
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <div class="lg:col-span-2">
                <SalesHistory sales={sales} />
            </div>
<!--            <div class="space-y-8">-->
<!--                <SalesSummary {sales} />-->
<!--                <SalesChart {sales} />-->
<!--            </div>-->
        </div>
    {/if}
</div>