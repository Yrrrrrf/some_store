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

    function getTodayDate(): string {
        return new Date().toISOString().split('T')[0];
    }

    async function initializeForm() {
        isLoading = true;
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
        isLoading = false;
    }

    api_url.subscribe(value => apiUrl = value);

    async function fetchForeignKeyOptions(referencedTable: string) {
        await fetchTableRows(apiUrl, referencedTable, {}, (data) => {
            foreignKeyOptions[referencedTable] = data;
        });
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
        return dateString; // 'yyyy-mm-dd' format is already correct for submission
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
            console.log('Form submitted:', submissionData);

            let result;
            if (editingItem) {
                result = await updateRecord(apiUrl, tableName, 'id', editingItem.id, submissionData);
            } else {
                result = await createRecord(apiUrl, tableName, submissionData);
            }
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
                        <label for={column} class="label">{snakeToCamelWithSpaces(column)}</label>
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
                        {:else}
                            <input
                                    type="text"
                                    id={column}
                                    bind:value={formData[column]}
                                    class="input"
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
