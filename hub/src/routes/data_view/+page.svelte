<script lang="ts">
    import { onMount } from "svelte";
    import { TabGroup, Tab, ProgressRadial } from "@skeletonlabs/skeleton";
    import { fade } from 'svelte/transition';
    import TabContent from './TabContent.svelte';
    import { api_url, current_tab } from '$lib/stores/app';
    import type { Writable } from 'svelte/store';

    // Define the available tabs
    const tabs: string[] = ['tables', 'views', 'some'];

    let apiUrl: string;
    let currentTab: string;
    let tables: string[] = [];
    let views: string[] = [];
    let isLoading: boolean = true;

    // Subscribe to stores
    $: api_url.subscribe(value => apiUrl = value);
    $: current_tab.subscribe(value => currentTab = value);


    async function fetchTables(): Promise<string[]> {
        const response = await fetch(`${apiUrl}/tables`);
        console.log(response);
        return await response.json();
    }

    async function fetchViews(): Promise<string[]> {
        const response = await fetch(`${apiUrl}/views`);
        console.log(response);
        return await response.json();
    }

    onMount(async () => {
        try {
            isLoading = true;
            [tables, views] = await Promise.all([
                fetchTables(),
                fetchViews()
            ]);
        } catch (error) {
            console.error('Error fetching data:', error);
            // Handle error (e.g., show error message to user)
        } finally {
            isLoading = false;
        }
    });

    function handleTabChange(event: CustomEvent<string>) {
        current_tab.set(event.detail);
    }
</script>

<div class="container mx-auto p-4" in:fade="{{ duration: 300 }}">
    <h1 class="text-3xl font-bold mb-6">Data View</h1>

    <nav class="text-sm breadcrumbs mb-4">
        <ul>
            <li><a href="/dashboard">Dashboard</a></li>
            <li>{currentTab}</li>
        </ul>
    </nav>

    <TabGroup>
        {#each tabs as tab}
            <Tab bind:group={currentTab} name={tab} value={tab} on:click={() => handleTabChange(new CustomEvent('click', { detail: tab }))}>
                {tab.toUpperCase()}
            </Tab>
        {/each}
    </TabGroup>

    {#if isLoading}
        <div class="flex justify-center items-center h-64">
            <ProgressRadial stroke={100} meter="stroke-primary-500" track="stroke-primary-500/30" />
        </div>
    {:else}
        <TabContent tables="{tables}" views="{views}" />
    {/if}
</div>