<script lang="ts">
    import { createEventDispatcher, onMount } from 'svelte';
    import { fetchTableRows, fetchColumns } from '../../utils';
    import { api_url } from '../../utils';

    export let tableName: string;
    export let editingItem: any = null;

    let columns: string[] = [];
    let formData: {[key: string]: any} = {};
    let foreignKeyOptions: {[key: string]: any[]} = {};
    let apiUrl: string;

    api_url.subscribe(value => apiUrl = value);

    const dispatch = createEventDispatcher();

    async function initializeForm() {
        // Fetch columns for the current table
        await fetchColumns(apiUrl, tableName, (data) => {
            columns = data;
            // Initialize formData with empty values for each column
            formData = columns.reduce((acc, col) => ({ ...acc, [col]: '' }), {});
        });

        // Fetch foreign key options for relevant fields
        await Promise.all(columns.map(async (column) => {
            if (column.endsWith('_id')) {
                const referencedTable = column.slice(0, -3);
                await fetchForeignKeyOptions(referencedTable);
            }
        }));

        // If editing an existing item, populate the form
        if (editingItem) {
            formData = { ...editingItem };
        }
    }

    async function fetchForeignKeyOptions(referencedTable: string) {
        await fetchTableRows(apiUrl, referencedTable, {}, (data) => {
            foreignKeyOptions[referencedTable] = data;
        });
    }

    function handleSubmit() {
        dispatch('submit', formData);
    }

    // Re-initialize the form when the table changes
    $: {
        if (tableName) {
            initializeForm();
        }
    }

    onMount(() => {
        initializeForm();
    });
</script>

<form on:submit|preventDefault={handleSubmit} class="space-y-4">
    {#each columns as column}
        <div>
            <label for={column} class="block text-sm font-medium text-gray-700">{column}</label>
            {#if column.endsWith('_id') && foreignKeyOptions[column.slice(0, -3)]}
                <select
                        id={column}
                        bind:value={formData[column]}
                        class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50"
                >
                    <option value="">Select an option</option>
                    {#each foreignKeyOptions[column.slice(0, -3)] as option}
                        <option value={option.id}>{option.name || option.id}</option>
                    {/each}
                </select>
            {:else}
                <input
                        type="text"
                        id={column}
                        bind:value={formData[column]}
                        class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50"
                />
            {/if}
        </div>
    {/each}
    <button type="submit" class="btn variant-filled-primary">
        {editingItem ? 'Update' : 'Create'} Record
    </button>
</form>