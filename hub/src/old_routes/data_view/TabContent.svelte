<script lang="ts">
    import { fade, fly } from 'svelte/transition';
    import { snakeToCamelWithSpaces, fetchTableRows, fetchViewRows, fetchColumns } from '$lib/utils/utils';
    import { api_url, current_view, current_table } from '$lib/utils/utils';
    import { exportDataToPDF } from '$lib/utils/export_pdf';

    import SomeSearchBar from './SomeSearchBar.svelte';
    import SomeViewToggle from './SomeViewToggle.svelte';
    import SomeItemList from './SomeItemList.svelte';
    import SomeSelectedItemView from './SomeSelectedItemView.svelte';

    export let items: string[] = [];
    export let t_type: 'tables' | 'views';

    let apiUrl: string;
    api_url.subscribe(value => apiUrl = value);

    let searchTerm = '';
    let selectedItem: string | null = null;
    let tableData: any[] = [];
    let isLoading = false;
    let viewMode: 'grid' | 'list' = 'grid';
    let columns: string[] = [];
    let formData: { [key: string]: string } = {};
    let showFilterForm = false;

    $: filteredItems = filterItems(items, searchTerm);

    function normalizeString(str: string): string {
        return str.toLowerCase().replace(/[_\s]/g, '');
    }

    function filterItems(items: string[], term: string): string[] {
        const normalizedTerm = normalizeString(term);
        return items.filter(item => normalizeString(item).includes(normalizedTerm));
    }

    async function handleItemClick(item: string) {
        isLoading = true;
        selectedItem = item;
        formData = {};
        showFilterForm = false;

        const store = t_type === 'tables' ? current_table : current_view;
        store.set(item);

        if (t_type === 'tables') {
            await fetchColumns(apiUrl, item, setColumns);
            await fetchTableRows(apiUrl, item, {}, setTableData);
        } else {
            await fetchViewRows(apiUrl, item, {}, (data) => {
                setTableData(data);
                setColumns(Object.keys(data[0] || {}));
            });
        }

        isLoading = false;
    }

    function setColumns(data: string[]) {
        columns = data;
        columns.forEach(col => formData[col] = '');
    }

    function setTableData(data: any[]) {
        tableData = data;
    }

    async function handleSubmit() {
        isLoading = true;
        const fetchFunction = t_type === 'tables' ? fetchTableRows : fetchViewRows;
        await fetchFunction(apiUrl, selectedItem!, formData, setTableData);
        isLoading = false;
    }
</script>

<div in:fade="{{ duration: 300 }}" class="space-y-4">
    <div class="flex items-center justify-between">
        <SomeSearchBar bind:searchTerm {t_type} />
        <SomeViewToggle bind:viewMode />
    </div>

    <SomeItemList
            {viewMode}
            filteredItems={filteredItems}
            {t_type}
            handleItemClick={handleItemClick}
    />

    {#if selectedItem}
        <SomeSelectedItemView
                {selectedItem}
                bind:showFilterForm
                {columns}
                bind:formData
                {handleSubmit}
                {isLoading}
                {tableData}
        />
    {/if}
</div>
