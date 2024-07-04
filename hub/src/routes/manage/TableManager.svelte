<script lang="ts">
    import { onMount } from 'svelte';
    import { fetchColumns, fetchTableRows } from '../../utils';
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

    function handleFormSubmit(event: CustomEvent) {
        console.log('Form submitted:', event.detail);
        // TODO: Implement API call to create or update record
        showForm = false;
        editingItem = null;
        loadTableData();
    }

    function handleEdit(item: any) {
        editingItem = item;
        showForm = true;
    }

    function handleDelete(item: any) {
        // TODO: Implement delete functionality
        console.log('Delete item:', item);
        loadTableData();
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
            <TableForm {tableName} {editingItem} on:submit={handleFormSubmit} />
        {/if}

        <TableData {columns} data={tableData} on:edit={handleEdit} on:delete={handleDelete} />
    {/if}
</div>