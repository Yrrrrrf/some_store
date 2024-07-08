<script lang="ts">
    import { createEventDispatcher, onMount } from 'svelte';
    import { snakeToCamelWithSpaces } from '$lib/utils/stringUtils';
    import { ProgressRadial } from '@skeletonlabs/skeleton';
    import { apiClient } from '$lib/utils/api';

    export let tableName: string;
    export let editingItem: any = null;

    let columns: string[] = [];
    let formData: {[key: string]: any} = {};
    let foreignKeyOptions: {[key: string]: any[]} = {};
    let isLoading = true;
    let errorMessage = '';

    const dispatch = createEventDispatcher();

    let selectedFile: File | null = null;

    function getLocalImageUrl(file: File): string {
        return URL.createObjectURL(file);
    }

    function getTodayDate(): string {
        return new Date().toISOString().split('T')[0];
    }

    async function initializeForm() {
        isLoading = true;
        try {
            columns = await apiClient.fetchColumns(tableName);
            formData = columns.reduce((acc, col) => {
                if (isDateColumn(col)) {
                    return { ...acc, [col]: getTodayDate() };
                }
                return { ...acc, [col]: '' };
            }, {});

            await Promise.all(columns.map(async (column) => {
                if (column.endsWith('_id')) {
                    const referencedTable = column.slice(0, -3);
                    await fetchForeignKeyOptions(referencedTable);
                }
            }));

            if (editingItem) {
                formData = { ...editingItem };
                columns.forEach(column => {
                    if (isDateColumn(column) && formData[column]) {
                        formData[column] = formatDateForInput(formData[column]);
                    }
                });
            }
        } catch (error) {
            console.error('Error initializing form:', error);
            errorMessage = 'Failed to load form data. Please try again.';
        } finally {
            isLoading = false;
        }
    }

    async function fetchForeignKeyOptions(referencedTable: string) {
        try {
            const data = await apiClient.fetchRows(referencedTable);
            foreignKeyOptions[referencedTable] = data;
        } catch (error) {
            console.error(`Error fetching foreign key options for ${referencedTable}:`, error);
        }
    }

    function isIdColumn(column: string): boolean {
        return column.toLowerCase() === 'id';
    }

    function isDateColumn(column: string): boolean {
        return column.toLowerCase().includes('date');
    }

    function formatDateForInput(dateString: string): string {
        const date = new Date(dateString);
        return date.toISOString().split('T')[0];
    }

    function formatDateForSubmission(dateString: string): string {
        return dateString;
    }

    async function handleSubmit() {
        errorMessage = '';
        isLoading = true;
        try {
            const submissionData = { ...formData };
            columns.forEach(column => {
                if (isDateColumn(column) && submissionData[column]) {
                    submissionData[column] = formatDateForSubmission(submissionData[column]);
                }
            });

            delete submissionData['id'];

            if (tableName === 'sale' && !submissionData['reference']) {
                delete submissionData['reference'];
            }

            if (selectedFile && tableName === 'product') {
                const productCode = submissionData['code'] || 'default';
                const formData = new FormData();
                formData.append('file', selectedFile);

                const uploadResponse = await fetch(`${apiClient.baseUrl}/upload-image/${productCode}`, {
                    method: 'POST',
                    body: formData
                });

                if (uploadResponse.ok) {
                    const result = await uploadResponse.json();
                    submissionData['image_url'] = result.url;
                } else {
                    throw new Error('Image upload failed');
                }
            }

            let result;
            if (editingItem) {
                result = await apiClient.updateRecord(tableName, 'id', editingItem.id, submissionData);
            } else {
                result = await apiClient.createRecord(tableName, submissionData);
            }

            dispatch('submit', result);
        } catch (error) {
            console.error('Error submitting form:', error);
            errorMessage = 'An error occurred while submitting the form. Please try again.';
        } finally {
            isLoading = false;
        }
    }

    function handleCancel() {
        dispatch('cancel');
    }

    $: {
        if (tableName) {
            initializeForm();
        }
    }

    onMount(() => {
        initializeForm();
    });
</script>

<div class="card p-4 bg-surface-200-700-token shadow-lg">
    <h2 class="h3 mb-4">{editingItem ? 'Edit' : 'Create'} {snakeToCamelWithSpaces(tableName)} Record</h2>

    {#if isLoading}
        <div class="flex justify-center items-center h-32">
            <ProgressRadial stroke={100} meter="stroke-primary-500" track="stroke-primary-500/30" />
        </div>
    {:else}
        {#if errorMessage}
            <div class="alert variant-filled-error mb-4">
                <span>{errorMessage}</span>
            </div>
        {/if}
        <form on:submit|preventDefault={handleSubmit} class="space-y-4">
            {#each columns as column}
                {#if !isIdColumn(column)}
                    <div class="form-field">
                        <label for={column} class="label">
                            {snakeToCamelWithSpaces(column)}
                            {#if tableName === 'sale' && column === 'reference'}
                                <span class="text-sm text-gray-500 ml-2">(Optional)</span>
                            {/if}
                        </label>
                        {#if column.endsWith('_id') && foreignKeyOptions[column.slice(0, -3)]}
                            <select
                                    id={column}
                                    bind:value={formData[column]}
                                    class="select"
                            >
                                <option value="">Select an option</option>
                                {#each foreignKeyOptions[column.slice(0, -3)] as option}
                                    <option value={option.id}>{option.name || option.id}</option>
                                {/each}
                            </select>
                        {:else if isDateColumn(column)}
                            <input
                                    type="date"
                                    id={column}
                                    bind:value={formData[column]}
                                    class="input"
                            />
                        {:else if column.includes('price') || column.includes('amount')}
                            <input
                                    type="number"
                                    step="0.01"
                                    id={column}
                                    bind:value={formData[column]}
                                    class="input"
                            />
                        {:else if column.includes('image_url')}
                            <label for="image_upload" class="label">Image Upload</label>
                            <input
                                    type="file"
                                    id="image_upload"
                                    accept="image/*"
                                    on:change={(e) => selectedFile = e.target.files[0]}
                                    class="input"
                            />
                            {#if selectedFile}
                                <img src={getLocalImageUrl(selectedFile)} alt="Selected image preview" class="mt-2 max-w-full h-auto max-h-48 object-contain" />
                            {:else if formData['image_url']}
                                <img src={formData['image_url']} alt="Current product image" class="mt-2 max-w-full h-auto max-h-48 object-contain" />
                            {/if}
                        {:else}
                            <input
                                    type="text"
                                    id={column}
                                    bind:value={formData[column]}
                                    class="input"
                                    placeholder={tableName === 'sale' && column === 'reference' ? 'Leave empty for auto-generation' : ''}
                            />
                        {/if}
                    </div>
                {/if}
            {/each}
            <div class="flex justify-end space-x-2 mt-6">
                <button type="button" class="btn variant-soft-surface" on:click={handleCancel}>
                    Cancel
                </button>
                <button type="submit" class="btn variant-filled-primary">
                    {editingItem ? 'Update' : 'Create'} Record
                </button>
            </div>
        </form>
    {/if}
</div>