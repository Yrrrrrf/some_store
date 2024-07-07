<script lang="ts">
    import '../app.postcss';

    import {AppBar, AppShell, LightSwitch, initializeStores } from '@skeletonlabs/skeleton';
    import { initializeFloatingUI, initializeHighlightJS } from "$lib/utils/initialization";
    import ThemeSelector from "$lib/components/common/ThemeSelector.svelte";

    initializeFloatingUI();  // Initialize floating UI elements (popups, tooltips, etc.)
    initializeHighlightJS();  // Initialize Highlight.js for code blocks

    // use the api_url var declared on the $lib/utils/app_stores.ts file
    import { api_url } from "$lib/utils/app_stores";
    import {goto} from "$app/navigation";

    $: apiUrl = api_url;

    // Initialize the stores
    initializeStores();

</script>

<svelte:head>
    <title>Some Store</title>
</svelte:head>

<AppShell>
    <svelte:fragment slot="header">
        <AppBar>
            <svelte:fragment slot="lead">
                <strong class="text-xl uppercase pr-2">Welcome to</strong>
                <a href="/" class="text-xl variant-filled-primary p-2 rounded-xl uppercase">Some Store</a>
            </svelte:fragment>

            <svelte:fragment slot="trail">
                <ThemeSelector />
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