<script lang="ts">
    import { ProgressRadial } from '@skeletonlabs/skeleton';
    import { Filter } from 'lucide-svelte';
    import { fly } from 'svelte/transition';
    import { snakeToCamelWithSpaces } from '$lib/utils/stringUtils';
    import SomeTable from './SomeTable.svelte';
    import {exportDataToPDF} from "$lib/utils/pdfExport";

    export let selectedItem: string;
    export let showFilterForm: boolean;
    export let columns: string[];
    export let formData: { [key: string]: string };
    export let handleSubmit: () => Promise<void>;
    export let isLoading: boolean;
    export let tableData: any[];

    async function handleExportData() {
        try {
            await exportDataToPDF(tableData, selectedItem!, formData);
        } catch (error) {
            console.error("Error exporting PDF:", error);
            // Handle the error (e.g., show an error message to the user)
        }
    }
</script>

<div in:fly="{{ y: 50, duration: 300 }}" class="mt-8">
    <div class="flex justify-between items-center mb-4">
        <h2 class="text-2xl font-semibold">{snakeToCamelWithSpaces(selectedItem)}</h2>
        <div class="flex space-x-2">
            <button class="btn variant-filled-secondary" on:click={() => showFilterForm = !showFilterForm}>
                <Filter size={20} />
                {showFilterForm ? 'Hide Filters' : 'Show Filters'}
            </button>
            <button class="btn variant-filled-primary" on:click={handleExportData}>
                Export Data
            </button>
        </div>
    </div>

    {#if showFilterForm}
        <form on:submit|preventDefault={handleSubmit} class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mb-4">
            {#each columns as column}
                <div class="form-control">
                    <label for={column} class="label">
                        <span class="label-text">{snakeToCamelWithSpaces(column)}</span>
                    </label>
                    <input
                            type="text"
                            id={column}
                            bind:value={formData[column]}
                            class="input variant-form-material"
                            placeholder={`Enter ${snakeToCamelWithSpaces(column)}`}
                    />
                </div>
            {/each}
            <div class="col-span-full flex justify-end mt-4">
                <button type="submit" class="btn variant-filled-primary">Apply Filters</button>
            </div>
        </form>
    {/if}

    {#if isLoading}
        <div class="flex justify-center items-center h-64">
            <ProgressRadial stroke={100} meter="stroke-primary-500" track="stroke-primary-500/30" />
        </div>
    {:else}
        <SomeTable currentItem={selectedItem} tableData={tableData} />
    {/if}
</div>