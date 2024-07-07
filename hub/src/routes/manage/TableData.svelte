<script lang="ts">
    import { createEventDispatcher, onMount } from 'svelte';
    import { fade, slide } from 'svelte/transition';
    import { Trash2, Edit2, Image, X } from 'lucide-svelte';
    import { tooltip } from '$lib/tooltip';

    export let columns: string[];
    export let data: any[];

    const dispatch = createEventDispatcher();

    let deletingItem: any | null = null;
    let editingItem: any | null = null;
    let uploadingImage: any | null = null;
    let fileInput: HTMLInputElement;

    /**
     * Initializes the component
     */
    onMount(() => {
        // Any initialization logic can go here
    });

    /**
     * Handles the edit action for an item
     * @param {any} item - The item to be edited
     */
    function handleEdit(item: any) {
        editingItem = { ...item };
    }

    /**
     * Saves the edited item
     */
    function saveEdit() {
        if (editingItem) {
            const index = data.findIndex(item => item.id === editingItem.id);
            if (index !== -1) {
                data[index] = editingItem;
                dispatch('edit', editingItem);
            }
            editingItem = null;
        }
    }

    /**
     * Cancels the edit action
     */
    function cancelEdit() {
        editingItem = null;
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
     * Initiates the image upload process for an item
     * @param {any} item - The item to upload an image for
     */
    function initiateImageUpload(item: any) {
        uploadingImage = item;
        fileInput.click();
    }

    /**
     * Handles the image upload process
     * @param {Event} event - The file input change event
     */
    async function handleImageUpload(event: Event) {
        const target = event.target as HTMLInputElement;
        const file = target.files?.[0];
        if (file && uploadingImage) {
            const formData = new FormData();
            formData.append('file', file);

            try {
                const response = await fetch(`${apiUrl}/upload-image/${uploadingImage.code}`, {
                    method: 'POST',
                    body: formData,
                });

                if (response.ok) {
                    const result = await response.json();
                    const updatedItem = { ...uploadingImage, image_url: `/static/uploads/${result.filename}` }; // Update image URL to use the correct directory
                    const index = data.findIndex(item => item.id === uploadingImage.id);
                    if (index !== -1) {
                        data[index] = updatedItem;
                        dispatch('imageUpload', updatedItem);
                    }
                } else {
                    console.error('Image upload failed');
                    // Handle error (e.g., show an error message to the user)
                }
            } catch (error) {
                console.error('Error uploading image:', error);
                // Handle error (e.g., show an error message to the user)
            }

            uploadingImage = null;
        }
    }

    /**
     * Formats a value based on its type
     * @param {any} value - The value to format
     * @returns {string} The formatted value
     */
    function formatValue(value: any): string {
        if (typeof value === 'number') {
            return value.toLocaleString();
        } else if (value instanceof Date) {
            return value.toLocaleDateString();
        }
        return String(value);
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
                            <div class="relative">
                                <img src={item[column] ? item[column] : '/placeholder-image.png'} alt={item.description} class="w-16 h-16 object-cover rounded" />
                                <button
                                        class="absolute top-0 right-0 bg-primary-500 text-white rounded-full p-1"
                                        on:click={() => initiateImageUpload(item)}
                                        use:tooltip={{ content: 'Upload new image', position: 'top' }}
                                >
                                    <Image size={12} />
                                </button>
                            </div>
                        {:else if editingItem?.id === item.id}
                            <input
                                    type="text"
                                    bind:value={editingItem[column]}
                                    class="input input-bordered input-sm w-full"
                            />
                        {:else}
                            {formatValue(item[column])}
                        {/if}
                    </td>
                {/each}
                <td>
                    {#if editingItem?.id === item.id}
                        <button class="btn btn-sm variant-filled-primary mr-2" on:click={saveEdit}>
                            Save
                        </button>
                        <button class="btn btn-sm variant-soft-surface" on:click={cancelEdit}>
                            Cancel
                        </button>
                    {:else}
                        <button
                                class="btn btn-sm variant-soft-primary mr-2"
                                on:click={() => handleEdit(item)}
                                use:tooltip={{ content: 'Edit item', position: 'top' }}
                        >
                            <Edit2 size={16} />
                        </button>
                        <button
                                class="btn btn-sm variant-soft-error"
                                on:click={() => initiateDelete(item)}
                                use:tooltip={{ content: 'Delete item', position: 'top' }}
                        >
                            <Trash2 size={16} />
                        </button>
                    {/if}
                </td>
            </tr>
        {/each}
        </tbody>
    </table>
</div>

{#if deletingItem}
    <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center" transition:fade>
        <div class="bg-surface-100-800-token p-6 rounded-lg shadow-xl" transition:slide>
            <h3 class="text-lg font-semibold mb-4">Confirm Deletion</h3>
            <p>Are you sure you want to delete this item?</p>
            <div class="mt-4 flex justify-end space-x-2">
                <button class="btn variant-soft-surface" on:click={cancelDelete}>Cancel</button>
                <button class="btn variant-filled-error" on:click={confirmDelete}>Delete</button>
            </div>
        </div>
    </div>
{/if}

<input
        type="file"
        accept="image/*"
        style="display: none;"
        bind:this={fileInput}
        on:change={handleImageUpload}
/>
