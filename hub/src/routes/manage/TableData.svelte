<script lang="ts">
    import { createEventDispatcher } from 'svelte';
    import { fade } from 'svelte/transition';
    import { Trash2, Edit2 } from 'lucide-svelte';

    export let columns: string[];
    export let data: any[];

    const dispatch = createEventDispatcher();

    let deletingItem: any | null = null;

    /**
     * Handles the edit action for an item
     * @param {any} item - The item to be edited
     */
    function handleEdit(item: any) {
        dispatch('edit', item);
    }

    /**
     * Initiates the delete process for an item
     * @param {any} item - The item to be deleted
     */
    function initiateDelete(item: any) {
        deletingItem = item;
    }

    /**
     * Confirms and dispatches the delete action for an item
     */
    function confirmDelete() {
        if (deletingItem) {
            dispatch('delete', deletingItem);
            deletingItem = null;
        }
    }

    /**
     * Cancels the delete action
     */
    function cancelDelete() {
        deletingItem = null;
    }

    /**
     * Checks if a column is an image column
     * @param {string} column - The column name to check
     * @returns {boolean} True if it's an image column, false otherwise
     */
    function isImageColumn(column: string): boolean {
        return column === 'image_url';
    }

    /**
     * Generates a unique image URL to prevent caching
     * @param {string} url - The original image URL
     * @returns {string} The image URL with a timestamp appended
     */
    function generateImageUrl(url: string): string {
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
        {#each data as item (item.id)}
            <tr>
                {#each columns as column}
                    <td>
                        {#if isImageColumn(column)}
                            <img src={generateImageUrl(item[column])} alt={item.description} class="w-16 h-16 object-cover" />
                        {:else}
                            {item[column]}
                        {/if}
                    </td>
                {/each}
                <td>
                    <button class="btn btn-sm variant-soft-primary mr-2" on:click={() => handleEdit(item)}>
                        <Edit2 size={16} />
                        Edit
                    </button>
                    <button class="btn btn-sm variant-soft-error" on:click={() => initiateDelete(item)}>
                        <Trash2 size={16} />
                        Delete
                    </button>
                </td>
            </tr>
        {/each}
        </tbody>
    </table>
</div>

{#if deletingItem}
    <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center" transition:fade>
        <div class="bg-surface-100-800-token p-6 rounded-lg shadow-xl">
            <h3 class="text-lg font-semibold mb-4">Confirm Deletion</h3>
            <p>Are you sure you want to delete this item?</p>
            <div class="mt-4 flex justify-end space-x-2">
                <button class="btn variant-soft-surface" on:click={cancelDelete}>Cancel</button>
                <button class="btn variant-filled-error" on:click={confirmDelete}>Delete</button>
            </div>
        </div>
    </div>
{/if}
