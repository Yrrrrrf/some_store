<script lang="ts">
    export let currentItem: string = 'Some Table...'; // New prop to hold the current table name
    export let tableData: any[] = [];

    import { writable } from 'svelte/store';

    // Function to capitalize the first letter of the table name
    const capitalize = (str: string): string => str.charAt(0).toUpperCase() + str.slice(1);

    // Extract columns from the first row of the tableData
    let columns: string[] = [];
    $: {
        if (tableData.length > 0) {
            columns = Object.keys(tableData[0]);
        }
    }

    // Store for search term
    let searchTerm = writable('');
    $: searchTermValue = $searchTerm;

    // Store for sorting
    let sortColumn = writable('');
    let sortDirection = writable('asc');

    // Function to handle sorting
    function handleSort(column: string) {
        if ($sortColumn === column) {
            sortDirection.update(direction => direction === 'asc' ? 'desc' : 'asc');
        } else {
            sortColumn.set(column);
            sortDirection.set('asc');
        }
    }

    // Function to get sorted data
    function getSortedData(data: any[], column: string, direction: string) {
        return data.slice().sort((a, b) => {
            if (a[column] < b[column]) return direction === 'asc' ? -1 : 1;
            if (a[column] > b[column]) return direction === 'asc' ? 1 : -1;
            return 0;
        });
    }

    // Reactive statement for filtered and sorted data
    $: filteredData = tableData.filter(row => {
        return Object.values(row).some(value =>
            value.toString().toLowerCase().includes(searchTermValue.toLowerCase())
        );
    });

    $: sortedData = getSortedData(filteredData, $sortColumn, $sortDirection);

    function toUpperWithSpace(str: string): string {
    //     replace all the '_' with ' ' and capitalize the first letter of each word
        return str.replace(/_/g, ' ').replace(/\b\w/g, (char) => char.toUpperCase());
    }
</script>

<style>
    .sortable:hover {
        cursor: pointer;
        text-decoration: underline;
    }
</style>

<p>{toUpperWithSpace(currentItem)}</p>

<input
        type="text"
        placeholder="Search..."
        bind:value={$searchTerm}
        class="search-input mt-2 mb-4 p-2 border rounded "
/>

{#if tableData.length > 0}
    <div class="table-container">
        <table class="table table-hover">
            <thead>
            <tr>
                {#each columns as column}
                    <th class="sortable" on:click={() => handleSort(column)}>
                        {capitalize(column)}
                        {#if $sortColumn === column}
                            {#if $sortDirection === 'asc'} ↑ {/if}
                            {#if $sortDirection === 'desc'} ↓ {/if}
                        {/if}
                    </th>
                {/each}
            </tr>
            </thead>
            <tbody>
            {#each sortedData as row}
                <tr>
                    {#each columns as column}
                        <td>{row[column]}</td>
                    {/each}
                </tr>
            {/each}
            </tbody>
        </table>
    </div>
{:else}
    <div class="mt-4 text-gray-500 text-sm">No data available</div>
{/if}
