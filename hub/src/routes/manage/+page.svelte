<script lang="ts">
    import { onMount } from 'svelte';
    import { fetchTables, api_url } from '../../utils';
    import TableManager from './TableManager.svelte';

    let tables: string[] = [];
    let selectedTable: string | null = null;
    let apiUrl: string;

    api_url.subscribe(value => apiUrl = value);

    onMount(async () => {
        await fetchTables(apiUrl, (data) => tables = data);
    });
</script>

<div class="container mx-auto p-4">
    <h1 class="text-3xl font-bold mb-6">Data Management</h1>

    <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div class="md:col-span-1">
            <h2 class="text-xl font-semibold mb-4">Tables</h2>
            <ul class="space-y-2">
                {#each tables as table}
                    <li>
                        <button
                                class="btn variant-soft-primary w-full text-left"
                                class:variant-filled-primary={selectedTable === table}
                                on:click={() => selectedTable = table}
                        >
                            {table}
                        </button>
                    </li>
                {/each}
            </ul>
        </div>

        <div class="md:col-span-3">
            {#if selectedTable}
                <TableManager {apiUrl} tableName={selectedTable} />
            {:else}
                <p class="text-center text-gray-500">Select a table to manage its data</p>
            {/if}
        </div>
    </div>
</div>