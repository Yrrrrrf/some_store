<script lang="ts">
    import { writable } from 'svelte/store';
    import { fade } from 'svelte/transition';

    export let currentItem: string = 'Some Table...';
    export let tableData: any[] = [];

    const capitalize = (str: string): string => str.charAt(0).toUpperCase() + str.slice(1);

    let columns: string[] = [];
    $: {
        if (tableData.length > 0) {
            columns = Object.keys(tableData[0]);
        }
    }

    let searchTerm = writable('');
    $: searchTermValue = $searchTerm;

    let sortColumn = writable('');
    let sortDirection = writable('asc');

    function handleSort(column: string) {
        if ($sortColumn === column) {
            sortDirection.update(direction => direction === 'asc' ? 'desc' : 'asc');
        } else {
            sortColumn.set(column);
            sortDirection.set('asc');
        }
    }

    function getSortedData(data: any[], column: string, direction: string) {
        return data.slice().sort((a, b) => {
            if (a[column] < b[column]) return direction === 'asc' ? -1 : 1;
            if (a[column] > b[column]) return direction === 'asc' ? 1 : -1;
            return 0;
        });
    }

    let columnFilters = writable<{ [key: string]: string }>({});
    $: columnFiltersValue = $columnFilters;

    $: filteredData = tableData.filter(row => {
        return Object.values(row).some(value =>
            value.toString().toLowerCase().includes(searchTermValue.toLowerCase())
        ) && Object.entries(columnFiltersValue).every(([column, filter]) => {
            return row[column]?.toString().toLowerCase().includes(filter.toLowerCase());
        });
    });

    $: sortedData = getSortedData(filteredData, $sortColumn, $sortDirection);

    function toUpperWithSpace(str: string): string {
        return str.replace(/_/g, ' ').replace(/\b\w/g, (char) => char.toUpperCase());
    }

    let currentPage = 1;
    let itemsPerPage = 10;
    $: totalPages = Math.ceil(sortedData.length / itemsPerPage);
    $: paginatedData = sortedData.slice((currentPage - 1) * itemsPerPage, currentPage * itemsPerPage);
</script>

<div in:fade="{{ duration: 300 }}">
    <input
            type="text"
            placeholder="Search..."
            bind:value={$searchTerm}
            class="input variant-form-material w-full mb-4"
    />

    {#if tableData.length > 0}
        <div class="table-container overflow-x-auto">
            <table class="table table-hover">
                <thead>
                <tr>
                    {#each columns as column}
                        <th class="sortable cursor-pointer" on:click={() => handleSort(column)}>
                            {toUpperWithSpace(column)}
                            {#if $sortColumn === column}
                                {$sortDirection === 'asc' ? '↑' : '↓'}
                            {/if}
                        </th>
                    {/each}
                </tr>
                <tr>
                    {#each columns as column}
                        <th>
                            <input
                                    type="text"
                                    placeholder={`Filter ${toUpperWithSpace(column)}`}
                                    bind:value={$columnFilters[column]}
                                    class="input variant-form-material w-full"
                            />
                        </th>
                    {/each}
                </tr>
                </thead>
                <tbody>
                {#each paginatedData as row}
                    <tr>
                        {#each columns as column}
                            <td>{row[column]}</td>
                        {/each}
                    </tr>
                {/each}
                </tbody>
            </table>
        </div>

        <div class="flex justify-between items-center mt-4">
            <div>
                Showing {(currentPage - 1) * itemsPerPage + 1} to {Math.min(currentPage * itemsPerPage, sortedData.length)} of {sortedData.length} entries
            </div>
            <div class="flex gap-2">
                <button class="btn variant-ghost" on:click={() => currentPage = Math.max(1, currentPage - 1)} disabled={currentPage === 1}>
                    Previous
                </button>
                <button class="btn variant-ghost" on:click={() => currentPage = Math.min(totalPages, currentPage + 1)} disabled={currentPage === totalPages}>
                    Next
                </button>
            </div>
        </div>
    {:else}
        <div class="mt-4 text-gray-500 text-sm">No data available</div>
    {/if}
</div>

<style>
    .sortable:hover {
        text-decoration: underline;
    }
</style>