<script lang="ts">
    import { onMount } from 'svelte';
    import { fetchColumns, fetchTableRows, createRecord, updateRecord, deleteRecord } from '../../utils';
    import TableForm from './TableForm.svelte';
    import TableData from './TableData.svelte';
    import { ProgressRadial } from '@skeletonlabs/skeleton';

    export let apiUrl: string;
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

    /**
     * Loads table data and columns
     */
    async function loadTableData() {
        isLoading = true;
        showForm = false;
        editingItem = null;
        errorMessage = '';
        try {
            await Promise.all([
                fetchColumns(apiUrl, tableName, (data) => columns = data),
                fetchTableRows(apiUrl, tableName, {}, (data) => tableData = data)
            ]);
        } catch (error) {
            console.error('Error loading table data:', error);
            errorMessage = 'Failed to load table data. Please try again.';
        } finally {
            isLoading = false;
        }
    }

    /**
     * Handles form submission for creating or updating records
     * @param {CustomEvent} event - The form submission event
     */
    async function handleFormSubmit(event: CustomEvent) {
        const formData = event.detail;
        try {
            if (editingItem) {
                await updateRecord(apiUrl, tableName, 'id', editingItem.id, formData);
            } else {
                await createRecord(apiUrl, tableName, formData);
            }
            showForm = false;
            editingItem = null;
            await loadTableData();
        } catch (error) {
            console.error('Error submitting form:', error);
            errorMessage = 'Failed to save record. Please check your inputs and try again.';
        }
    }

    /**
     * Handles the edit action for a table item
     * @param {CustomEvent} event - The edit event
     */
    function handleEdit(event: CustomEvent) {
        editingItem = event.detail;
        showForm = true;
    }

    /**
     * Handles the delete action for a table item
     * @param {CustomEvent} event - The delete event
     */
    async function handleDelete(event: CustomEvent) {
        const itemToDelete = event.detail;
        try {
            await deleteRecord(apiUrl, tableName, 'id', itemToDelete.id);
            await loadTableData();
        } catch (error) {
            console.error('Error deleting record:', error);
            errorMessage = 'Failed to delete record. Please try again.';
        }
    }
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
                    on:submit={handleFormSubmit}
                    on:cancel={() => { showForm = false; editingItem = null; }}
            />
        {/if}

        <TableData {columns} data={tableData} on:edit={handleEdit} on:delete={handleDelete} />
    {/if}
</div>