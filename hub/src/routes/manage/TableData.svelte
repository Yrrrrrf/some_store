<script lang="ts">
    import { createEventDispatcher } from 'svelte';

    export let columns: string[];
    export let data: any[];

    const dispatch = createEventDispatcher();

    function handleEdit(item: any) {
        dispatch('edit', item);
    }

    function handleDelete(item: any) {
        dispatch('delete', item);
    }

    function isImageColumn(column) {
        return column === 'image_url';
    }

    function generateImageUrl(url) {
        const timestamp = new Date().getTime();
        return `${url}&t=${timestamp}`;
    }
</script>

<div class="overflow-x-auto">
    <table class="table table-compact w-full">
        <thead>
        <tr>
            {#each columns as column}
                <th>{column}</th>
            {/each}
            <th>Actions</th>
        </tr>
        </thead>
        <tbody>
        {#each data as item}
            <tr>
                {#each columns as column}
                    <td>
                        {#if isImageColumn(column)}
                            <img src={generateImageUrl(item[column])} alt={item.Description} class="w-16 h-16 object-cover" />
                        {:else}
                            {item[column]}
                        {/if}
                    </td>
                {/each}
                <td>
                    <button class="btn btn-sm variant-soft-primary mr-2" on:click={() => handleEdit(item)}>Edit</button>
                    <button class="btn btn-sm variant-soft-error" on:click={() => handleDelete(item)}>Delete</button>
                </td>
            </tr>
        {/each}
        </tbody>
    </table>
</div>

<style>
    .table th,
    .table td {
        text-align: left;
        padding: 8px;
    }
    .w-16 {
        width: 4rem;
    }
    .h-16 {
        height: 4rem;
    }
    .object-cover {
        object-fit: cover;
    }
    .variant-soft-primary {
        background-color: #007bff;
        color: #fff;
    }
    .variant-soft-error {
        background-color: #dc3545;
        color: #fff;
    }
</style>
