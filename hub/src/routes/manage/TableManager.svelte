<script lang="ts">
    import { onMount } from 'svelte';
    import { fetchColumns, fetchTableRows, createRecord, updateRecord } from '../../utils';
    import TableForm from './TableForm.svelte';
    import TableData from './TableData.svelte';

    export let apiUrl: string;
    export let tableName: string;

    let columns: string[] = [];
    let tableData: any[] = [];
    let isLoading = true;
    let showForm = false;
    let editingItem: any = null;

    $: {
        if (tableName) {
            loadTableData();
        }
    }

    async function loadTableData() {
        isLoading = true;
        showForm = false;
        editingItem = null;
        await fetchColumns(apiUrl, tableName, (data) => columns = data);
        await fetchTableRows(apiUrl, tableName, {}, (data) => tableData = data);
        isLoading = false;
    }

    async function handleFormSubmit(event: CustomEvent) {
        const formData = event.detail;
        try {
            if (editingItem) {
                // Update existing record
                await updateRecord(apiUrl, tableName, 'id', editingItem.id, formData);
            } else {
                // Create new record
                await createRecord(apiUrl, tableName, formData);
            }
            showForm = false;
            editingItem = null;
            await loadTableData(); // Refresh the table data
        } catch (error) {
            console.error('Error submitting form:', error);
            // Handle the error (e.g., show an error message to the user)
        }
    }

    function handleEdit(item: any) {
        editingItem = item;
        showForm = true;
    }

    async function handleDelete(item: any) {
        // Implementation for delete (you can keep your existing delete logic here)
    }
</script>

<div>
    <h2 class="text-2xl font-semibold mb-4">{tableName}</h2>

    {#if isLoading}
        <p>Loading...</p>
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
