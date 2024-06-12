<script lang="ts">
    import { Tab, TabGroup } from "@skeletonlabs/skeleton";
    import SomeTable from './SomeTable.svelte';
    import TabContent from './TabContent.svelte';
    import { api_url, current_view, current_schema, current_table, current_tab } from '../../utils';
    import { snakeToCamelWithSpaces, fetchTableRows, fetchTables, fetchViews, fetchViewRows } from '../../utils';
    import { onMount } from "svelte";

    // ^ Subscribing to the store values
    let apiUrl: string = '';
    $: api_url.subscribe(value => apiUrl = value);

    let currentView: string = '';
    $: current_view.subscribe(value => currentView = value);

    let currentTab: string = '';
    $: current_tab.subscribe(value => currentTab = value);

    let currentTable: string = '';
    $: current_table.subscribe(value => currentTable = value);

    // ^ Defining the tabs
    let tabs: string[] = ['views', 'tables', 'some'];
    // ^ Defining the tables and views
    let tables: string[] = [];
    let views: string[] = [];
    // ^ Defining the table data (used to display the table rows)
    let tableData: any[] = [];

    onMount(() => {
        fetchTables(apiUrl, (data) => tables = data);
        fetchViews(apiUrl, (data) => views = data);
    });

    function resetTable(): void {
        tableData = [];
    }

    function updateSelectedTab(): void {
        resetTable();
        current_tab.set(currentTab);
    }

    function updateSelectedView(view: string): void {
        current_view.set(view);
        fetchViewRows(apiUrl, view, (data) => tableData = data);
    }

    function updateSelectedTable(table: string): void {
        current_table.set(table);
        fetchTableRows(apiUrl, table, (data) => tableData = data);
    }
</script>

<h1 class="text-2xl">Data View</h1>

<TabGroup>
    {#each tabs as tab}
        <Tab bind:group={currentTab} name={tab} value={tab} on:change={updateSelectedTab}>
            {tab.toUpperCase()}
        </Tab>
    {/each}
</TabGroup>

{#if currentTab === 'tables'}
    <TabContent items={tables} currentItem={currentTable} updateSelectedItem={updateSelectedTable} {tableData}/>
{/if}

{#if currentTab === 'views'}
    <TabContent items={views} currentItem={currentView} updateSelectedItem={updateSelectedView} {tableData}/>
{/if}
