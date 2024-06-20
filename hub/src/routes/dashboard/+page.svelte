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

    let currentTab: string = '';
    $: current_tab.subscribe(value => currentTab = value);

    // ^ Defining the tabs
    let tabs: string[] = ['tables', 'views', 'some'];
    // ^ Defining the tables and views
    let tables: string[] = [];
    let views: string[] = [];
    // ^ Defining the table data (used to display the table rows)

    onMount(() => {
        fetchTables(apiUrl, (data) => tables = data);
        fetchViews(apiUrl, (data) => views = data);
    });

</script>

<h1 class="text-2xl">Data View</h1>

<TabGroup>
    {#each tabs as tab}
        <Tab bind:group={currentTab} name={tab} value={tab} on:change={() => current_tab.set(currentTab)}>
            {tab.toUpperCase()}
        </Tab>
    {/each}
</TabGroup>

{#if currentTab === 'views'}
    <TabContent items={views} t_type="views"/>
{/if}

{#if currentTab === 'tables'}
    <TabContent items={tables} t_type="tables"/>
{/if}
