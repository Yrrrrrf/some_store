<script lang="ts">
    import {
        Table, BarChart, PieChart, LineChart, ScatterChart,
        Database, FileCog, FileText, FolderOpen, Gauge
    } from 'lucide-svelte';
    import { fly } from 'svelte/transition';
    import { snakeToCamelWithSpaces } from '../../utils';
    import { tooltip } from '$lib/tooltip';

    export let viewMode: 'grid' | 'list';
    export let filteredItems: string[];
    export let t_type: 'tables' | 'views';
    export let handleItemClick: (item: string) => void;

    function getItemColor(item: string): string {
        const colors = ['bg-primary-500', 'bg-secondary-500', 'bg-tertiary-500', 'bg-success-500', 'bg-warning-500', 'bg-error-500'];
        return colors[item.charCodeAt(0) % colors.length];
    }

    // todo: Assign this icons depending on the item
    // todo: This for your own app...
    function getIcon(item: string) {
        const icons = [Table, BarChart, PieChart, LineChart, ScatterChart, Database, FileCog, FileText, FolderOpen, Gauge];
        return icons[item.charCodeAt(0) % icons.length];
    }
</script>

{#if viewMode === 'grid'}
    <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4" in:fly="{{ y: 20, duration: 300 }}">
        {#each filteredItems as item}
            <div use:tooltip={{ content: `View details for ${snakeToCamelWithSpaces(item)}`, position: 'top' }}>
                <button
                        class="btn variant-soft-surface h-24 w-full flex flex-col items-center justify-center text-center transition-all duration-200 hover:scale-105"
                        on:click={() => handleItemClick(item)}
                >
                    <div class={`rounded-full p-2 mb-2 ${getItemColor(item)}`}>
                        <svelte:component this={getIcon(item)} class="w-5 h-5 text-white" />
                    </div>
                    <span class="text-sm font-medium overflow-hidden overflow-ellipsis whitespace-nowrap px-2">
                        {snakeToCamelWithSpaces(item)}
                    </span>
                </button>
            </div>
        {/each}
    </div>
{:else}
    <div class="space-y-2" in:fly="{{ y: 20, duration: 300 }}">
        {#each filteredItems as item}
            <button
                    class="btn variant-soft-surface w-full flex items-center justify-between px-4 py-3 transition-all duration-200 hover:scale-102"
                    on:click={() => handleItemClick(item)}
                    use:tooltip={{ content: `View details for ${snakeToCamelWithSpaces(item)}`, position: 'left' }}
            >
                <div class="flex items-center">
                    <div class={`rounded-full p-2 mr-3 ${getItemColor(item)}`}>
                        <svelte:component this={getIcon(item)} class="w-4 h-4 text-white" />
                    </div>
                    <span class="font-medium">{snakeToCamelWithSpaces(item)}</span>
                </div>
                <span class="text-sm text-gray-500">{t_type === 'tables' ? 'Table' : 'View'}</span>
            </button>
        {/each}
    </div>
{/if}