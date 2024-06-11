<script lang="ts">
    import SomeTable from './SomeTable.svelte';

    export let items: string[] = [];
    export let currentItem: string;
    export let updateSelectedItem: (item: string) => void;
    export let tableData: any[] = [];
</script>

<div class="mt-4 flex flex-wrap gap-4">
    {#each items as item}
        <button on:click={() => updateSelectedItem(item)} class="btn variant-filled-primary">
            {item}
        </button>
    {/each}
</div>
<SomeTable {currentItem} {tableData}/>
