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
                    <td>{item[column]}</td>
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