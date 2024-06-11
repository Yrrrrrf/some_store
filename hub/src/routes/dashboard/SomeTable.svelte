<script lang="ts">
    export let currentItem: string = 'Some Table...'; // New prop to hold the current table name
    export let tableData: any[] = [];

    // Function to capitalize the first letter of the table name
    const capitalize = (str: string): string => str.charAt(0).toUpperCase() + str.slice(1);

    // Extract columns from the first row of the tableData
    let columns: string[] = [];
    $: {
        if (tableData.length > 0) {
            columns = Object.keys(tableData[0]);
        }
    }
</script>

<p>{currentItem}</p>

{#if tableData.length > 0}
    <div class="table-container">
        <table class="table table-hover">
            <thead>
            <tr>
                {#each columns as column}
                    <th>{capitalize(column)}</th>
                {/each}
            </tr>
            </thead>
            <tbody>
            {#each tableData as row}
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
