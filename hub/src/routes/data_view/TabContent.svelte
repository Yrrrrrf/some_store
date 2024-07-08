<script lang="ts">
    import { fade } from 'svelte/transition';
    import { current_table, current_view, current_tab } from '$lib/stores/app';
    import { apiClient } from '$lib/utils/api';
    import SomeSearchBar from './SomeSearchBar.svelte';
    import SomeViewToggle from './SomeViewToggle.svelte';
    import SomeItemList from './SomeItemList.svelte';
    import SomeSelectedItemView from './SomeSelectedItemView.svelte';


    let showFilterForm = false;
    let columns: string[] = [];
    let formData: { [key: string]: string } = {};

    async function handleSubmit() {
        // Implement filter logic here
        await loadItemData(formData);
    }

    async function loadItemData(filters = {}) {
        isLoading = true;
        try {
            if (currentTab === 'tables') {
                itemData = await apiClient.fetchRows(selectedItem, filters);
            } else if (currentTab === 'views') {
                itemData = await apiClient.fetchRows(selectedItem, filters, true);
            }
            // Update columns based on the first item in itemData
            if (itemData.length > 0) {
                columns = Object.keys(itemData[0]);
                formData = Object.fromEntries(columns.map(col => [col, '']));
            }
        } catch (error) {
            console.error('Error loading item data:', error);
        } finally {
            isLoading = false;
        }
    }

    let currentTab: string;

    $: currentTab = $current_tab;

    export let tables: string[] = [];
    export let views: string[] = [];

    let searchTerm = '';
    let viewMode: 'grid' | 'list' = 'grid';
    let selectedItem: string;
    let itemData: any[] = [];
    let isLoading = false;

    $: items = currentTab === 'tables' ? tables : currentTab === 'views' ? views : [];
    $: filteredItems = filterItems(items, searchTerm);
    $: {
        if (currentTab === 'tables') {
            selectedItem = $current_table;
        } else if (currentTab === 'views') {
            selectedItem = $current_view;
        }
        if (selectedItem) {
            loadItemData();
        }
    }

    function filterItems(items: string[], term: string): string[] {
        const normalizedTerm = term.toLowerCase().replace(/[_\s]/g, '');
        return items.filter(item => item.toLowerCase().replace(/[_\s]/g, '').includes(normalizedTerm));
    }

    async function handleItemClick(item: string) {
        if (currentTab === 'tables') {
            current_table.set(item);
        } else if (currentTab === 'views') {
            current_view.set(item);
        }
        selectedItem = item;
        await loadItemData();
    }

</script>

<div in:fade="{{ duration: 300 }}" class="space-y-4">
    {#if currentTab !== 'some'}
        <div class="flex items-center justify-between">
            <SomeSearchBar bind:searchTerm t_type={currentTab} />
            <SomeViewToggle bind:viewMode />
        </div>

        <SomeItemList
                {viewMode}
                filteredItems={filteredItems}
                t_type={currentTab}
                {handleItemClick}
        />

        {#if selectedItem}
            <SomeSelectedItemView
                    {selectedItem}
                    tableData={itemData}
                    {isLoading}
                    {showFilterForm}
                    {columns}
                    {formData}
                    {handleSubmit}
            />
        {/if}
    {:else}
        <p>Content for 'Some' tab is not implemented yet.</p>
    {/if}
</div>