<script lang="ts">
    import '../app.postcss';
    import { AppShell, AppBar, LightSwitch } from '@skeletonlabs/skeleton';
    import { setContext } from 'svelte';
    import { writable } from 'svelte/store';
    import SomeThemeSelector from './SomeThemeSelector.svelte';
    import { initializeHighlightJS, initializeFloatingUI } from '$lib/utils/initialization';

    // Create a store for the API URL and set it in the context
    const apiUrl = writable('http://127.0.0.1:8000');
    setContext('apiUrl', apiUrl);

    // Initialize Highlight.js and Floating UI
    initializeHighlightJS();
    initializeFloatingUI();
</script>

<svelte:head>
    <title>Some Store</title>
</svelte:head>

<AppShell>
    <svelte:fragment slot="header">
        <AppBar>
            <svelte:fragment slot="lead">
                <strong class="text-xl uppercase pr-2">Welcome to</strong>
                <strong class="text-xl uppercase variant-filled-primary p-2 rounded-xl">Some Store!</strong>
            </svelte:fragment>

            <svelte:fragment slot="trail">
                <SomeThemeSelector />
                <LightSwitch />
                <a
                class="btn btn-sm variant-ghost-primary"
                href="{$apiUrl}/docs"
                target="_blank"
                rel="noreferrer"
                >API Docs</a>
                <a
                class="btn btn-sm variant-ghost-surface"
                href="https://github.com/Yrrrrrf/some_store"
                target="_blank"
                rel="noreferrer"
                >GitHub</a>
            </svelte:fragment>
        </AppBar>
    </svelte:fragment>

    <slot />

    <svelte:fragment slot="footer">
        <div class="fixed bottom-0 left-0 p-2 bg-surface-500/10 text-surface-600-300-token text-sm">
            API URL: <code>{$apiUrl}</code>
        </div>
    </svelte:fragment>
</AppShell>