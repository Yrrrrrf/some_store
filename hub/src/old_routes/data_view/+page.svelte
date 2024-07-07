<script lang="ts">
    import { Tab, TabGroup, ProgressRadial, LightSwitch } from "@skeletonlabs/skeleton";
    import { fade } from 'svelte/transition';
    import TabContent from './TabContent.svelte';
    import { api_url, current_view, current_schema, current_table, current_tab } from '$lib/utils/utils';
    import { snakeToCamelWithSpaces, fetchTables, fetchViews } from '$lib/utils/utils';
    import { onMount } from "svelte";

    let apiUrl: string = '';
    $: api_url.subscribe(value => apiUrl = value);

    let currentTab: string = 'tables';
    $: current_tab.subscribe(value => currentTab = value);

    let tabs: string[] = ['tables', 'views', 'some'];
    let tables: string[] = [];
    let views: string[] = [];
    let isLoading: boolean = true;

    onMount(async () => {
        isLoading = true;
        await Promise.all([
            fetchTables(apiUrl, (data) => tables = data),
            fetchViews(apiUrl, (data) => views = data)
        ]);
        isLoading = false;
    });
</script>

<div class="container mx-auto p-4" in:fade="{{ duration: 300 }}">
    <div class="flex justify-between items-center mb-6">
        <h1 class="text-3xl font-bold">Data View</h1>
    </div>

    <nav class="text-sm breadcrumbs mb-4">
        <ul>
            <li><a href="/dashboard">Dashboard</a></li>
            <li>{currentTab}</li>
        </ul>
    </nav>

    <TabGroup>
        {#each tabs as tab}
            <Tab bind:group={currentTab} name={tab} value={tab} on:change={() => current_tab.set(currentTab)}>
                {tab.toUpperCase()}
            </Tab>
        {/each}
    </TabGroup>

    {#if isLoading}
        <div class="flex justify-center items-center h-64">
            <ProgressRadial stroke={100} meter="stroke-primary-500" track="stroke-primary-500/30" />
        </div>
    {:else}
        {#if currentTab === 'views'}
            <TabContent items={views} t_type="views"/>
        {:else if currentTab === 'tables'}
            <TabContent items={tables} t_type="tables"/>
        {:else}
            <p>Content for '{currentTab}' tab is not implemented yet.</p>
        {/if}
    {/if}
</div>