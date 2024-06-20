<script lang="ts">
    import SomeTable from './SomeTable.svelte';
    import { writable, get } from 'svelte/store';
    import { api_url, current_tab, current_table, current_view, fetchTableRows, fetchColumns, fetchViewRows } from "../../utils";
    import { onMount } from "svelte";

    // ^ Subscribing to the store values
    let apiUrl: string = '';
    $: api_url.subscribe(value => apiUrl = value);

    let currentTab: string = '';
    $: current_tab.subscribe(value => currentTab = value);

    export let items: string[] = [];
    export let t_type: string = '';

    let currentItem: string = '';
    let tableData: any[] = [];
    let formData = writable({});

    function handleInputChange(column, value) {
        formData.update(currentData => {
            currentData[column] = value;
            return currentData;
        });
    }

    function submitForm() {
        const formDataObj = get(formData);
        fetchData(apiUrl, currentItem, formDataObj, (data) => {
            tableData = data;
            formData.set({}); // Reset formData after fetching data
        });
    }

    function fetchData(apiUrl: string, item: string, formData: any, setData: (data: any[]) => void): Promise<void> {
        if (currentTab === 'tables') {
            return fetchTableRows(apiUrl, item, formData, setData);
        } else if (currentTab === 'views') {
            return fetchViewRows(apiUrl, item, formData, setData);
        }
        return Promise.resolve();
    }

    function resetTable(): void {
        tableData = [];
    }

    let columns: string[] = [];
    function updateSelectedButton(item: string): void {
        resetTable();
        currentItem = item;
        currentTab === 'tables' ? current_table.set(item) : current_view.set(item);
        fetchColumns(apiUrl, t_type === 'tables' ? `${item}` : `view/${item}`, (data) => columns = data);
    }

    // Reactive statement to reset formData and hide table when currentItem changes
    $: currentItem, formData.set({});
</script>

<!-- BUTTONS FOR EACH TABLE -->

<div class="mt-4 flex flex-wrap gap-4">
    {#each items as item}
        <button on:click={() => updateSelectedButton(item)} class="btn variant-filled-primary">
            {item}
        </button>
    {/each}
</div>

<!-- FORM FOR TABLE DATA (modify the query parameters) -->

{#if columns.length > 0}
    <div class="variant-glass-surface p-10 rounded-lg shadow-lg z-50 max-w-md w-full">
        <strong class="h3 uppercase flex justify-center">{currentItem} QUERY</strong>
        <form class="flex flex-col space-y-4">
            {#each columns as column}
                <div class="mb-2">
                    <label for={column} class="block font-medium text-gray-400 label">{column}</label>
                    <input
                            type="text"
                            id={column}
                            name={column}
                            bind:value={$formData[column]}
                            on:input={(e) => handleInputChange(column, e.target.value)}
                            class="input variant-ghost-secondary w-full p-2 border rounded-md"
                            placeholder="Enter the value for {column}"
                    />
                </div>
            {/each}

            <button type="button" on:click={submitForm} class="btn variant-filled-primary w-1/2 self-center mt-4">
                Submit
            </button>
        </form>
    </div>
{/if}

<SomeTable {currentItem} {tableData}/>
