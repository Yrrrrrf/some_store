<script lang="ts">
    import { createEventDispatcher, onMount } from 'svelte';
    import { fetchTableRows, fetchColumns, snakeToCamelWithSpaces, createRecord, updateRecord } from '../../utils';
    import { api_url } from '../../utils';
    import { ProgressRadial } from '@skeletonlabs/skeleton';

    export let tableName: string;
    export let editingItem: any = null;

    let columns: string[] = [];
    let formData: {[key: string]: any} = {};
    let foreignKeyOptions: {[key: string]: any[]} = {};
    let apiUrl: string;
    let isLoading = true;
    let errorMessage = '';

    api_url.subscribe(value => apiUrl = value);

    const dispatch = createEventDispatcher();

    let selectedFile: File | null = null;

    /**
     * Generates a local URL for the uploaded file
     * @param {File} file - The uploaded file
     * @returns {string} Local URL for the file
     */
    function getLocalImageUrl(file: File): string {
        return URL.createObjectURL(file);
    }

    /**
     * Gets today's date in YYYY-MM-DD format
     * @returns {string} Today's date
     */
    function getTodayDate(): string {
        return new Date().toISOString().split('T')[0];
    }

    /**
     * Initializes the form with data
     */
    async function initializeForm() {
        isLoading = true;
        try {
            await fetchColumns(apiUrl, tableName, (data) => {
                columns = data;
                formData = columns.reduce((acc, col) => {
                    if (isDateColumn(col)) {
                        return { ...acc, [col]: getTodayDate() };
                    }
                    return { ...acc, [col]: '' };
                }, {});
            });

            await Promise.all(columns.map(async (column) => {
                if (column.endsWith('_id')) {
                    const referencedTable = column.slice(0, -3);
                    await fetchForeignKeyOptions(referencedTable);
                }
            }));

            if (editingItem) {
                formData = { ...editingItem };
                // Format date fields
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

    /**
     * Fetches foreign key options for a referenced table
     * @param {string} referencedTable - The name of the referenced table
     */
    async function fetchForeignKeyOptions(referencedTable: string) {
        try {
            await fetchTableRows(apiUrl, referencedTable, {}, (data) => {
                foreignKeyOptions[referencedTable] = data;
            });
        } catch (error) {
            console.error(`Error fetching foreign key options for ${referencedTable}:`, error);
        }
    }

    /**
     * Checks if a column is an ID column
     * @param {string} column - The column name
     * @returns {boolean} True if it's an ID column, false otherwise
     */
    function isIdColumn(column: string): boolean {
        return column.toLowerCase() === 'id';
    }

    /**
     * Checks if a column is a date column
     * @param {string} column - The column name
     * @returns {boolean} True if it's a date column, false otherwise
     */
    function isDateColumn(column: string): boolean {
        return column.toLowerCase().includes('date');
    }

    /**
     * Formats a date string for input fields
     * @param {string} dateString - The date string to format
     * @returns {string} Formatted date string
     */
    function formatDateForInput(dateString: string): string {
        const date = new Date(dateString);
        return date.toISOString().split('T')[0];
    }

    /**
     * Formats a date string for submission
     * @param {string} dateString - The date string to format
     * @returns {string} Formatted date string
     */
    function formatDateForSubmission(dateString: string): string {
        return dateString; // 'yyyy-mm-dd' format is already correct for submission
    }

    /**
     * Handles form submission
     */
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

            // Remove empty 'reference' field for 'sale' table
            if (tableName === 'sale' && !submissionData['reference']) {
                delete submissionData['reference'];
            }

            // Handle image upload
            if (selectedFile && tableName === 'product') {
                const productCode = submissionData['code'] || 'default';
                const formData = new FormData();
                formData.append('file', selectedFile);

                const uploadResponse = await fetch(`${apiUrl}/upload-image/${productCode}`, {
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

            console.log('Form submitted:', submissionData);

            let result;
            if (editingItem) {
                result = await updateRecord(apiUrl, tableName, 'id', editingItem.id, submissionData);
            } else {
                result = await createRecord(apiUrl, tableName, submissionData);
            }

            dispatch('submit', result);
        } catch (error) {
            console.error('Error submitting form:', error);
            if (error.response && error.response.status === 422) {
                const responseData = await error.response.json();
                errorMessage = responseData.detail || 'Validation error occurred. Please check your inputs.';
            } else {
                errorMessage = 'An error occurred while submitting the form. Please try again.';
            }
        } finally {
            isLoading = false;
        }
    }

    /**
     * Handles form cancellation
     */
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