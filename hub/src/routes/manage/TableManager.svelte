<script lang="ts">
    import { onMount } from 'svelte';
    import { apiClient } from '$lib/utils/api';
    import TableForm from './TableForm.svelte';
    import TableData from './TableData.svelte';
    import { ProgressRadial } from '@skeletonlabs/skeleton';

    export let tableName: string;

    let columns: string[] = [];
    let tableData: any[] = [];
    let isLoading = true;
    let showForm = false;
    let editingItem: any = null;
    let errorMessage: string = '';

    $: {
        if (tableName) {
            loadTableData();
        }
    }

    async function loadTableData() {
        isLoading = true;
        showForm = false;
        editingItem = null;
        errorMessage = '';
        try {
            columns = await apiClient.fetchColumns(tableName);
            tableData = await apiClient.fetchRows(tableName);
        } catch (error) {
            console.error('Error loading table data:', error);
            errorMessage = 'Failed to load table data. Please try again.';
        } finally {
            isLoading = false;
        }
    }

    function handleEdit(event: CustomEvent) {
        editingItem = event.detail;
        showForm = true;
    }

    async function handleDelete(event: CustomEvent) {
        const itemToDelete = event.detail;
        try {
            await apiClient.deleteRecord(tableName, 'id', itemToDelete.id);
            await loadTableData();
        } catch (error) {
            console.error('Error deleting record:', error);
            errorMessage = 'Failed to delete record. Please try again.';
        }
    }

    onMount(loadTableData);
</script>

<div>
    <h2 class="text-2xl font-semibold mb-4">{tableName}</h2>

    {#if errorMessage}
        <div class="alert variant-filled-error mb-4">
            <span>{errorMessage}</span>
        </div>
    {/if}

    {#if isLoading}
        <div class="flex justify-center items-center h-32">
            <ProgressRadial stroke={100} meter="stroke-primary-500" track="stroke-primary-500/30" />
        </div>
    {:else}
        <button class="btn variant-filled-primary mb-4" on:click={() => {showForm = !showForm; editingItem = null;}}>
            {showForm ? 'Hide Form' : 'Add New Record'}
        </button>

        {#if showForm}
            <TableForm
                    {tableName}
                    {editingItem}
                    on:submit={loadTableData}
                    on:cancel={() => { showForm = false; editingItem = null; }}
            />
        {/if}

        <TableData {columns} data={tableData} on:edit={handleEdit} on:delete={handleDelete} />
    {/if}
</div>