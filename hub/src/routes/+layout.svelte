<script lang="ts">
	import '../app.postcss';

    import { AppShell, AppBar, LightSwitch } from '@skeletonlabs/skeleton';

    import { api_url } from '../utils';

    let apiUrl: string = '';
    $: api_url.subscribe(value => apiUrl = value);

	// Highlight JS
	import hljs from 'highlight.js/lib/core';
	import 'highlight.js/styles/github-dark.css';
	import { storeHighlightJs } from '@skeletonlabs/skeleton';
	import xml from 'highlight.js/lib/languages/xml'; // for HTML
	import css from 'highlight.js/lib/languages/css';
	import javascript from 'highlight.js/lib/languages/javascript';
	import typescript from 'highlight.js/lib/languages/typescript';

	hljs.registerLanguage('xml', xml); // for HTML
	hljs.registerLanguage('css', css);
	hljs.registerLanguage('javascript', javascript);
	hljs.registerLanguage('typescript', typescript);
	storeHighlightJs.set(hljs);

	// Floating UI for Popups
	import { computePosition, autoUpdate, flip, shift, offset, arrow } from '@floating-ui/dom';
	import { storePopup } from '@skeletonlabs/skeleton';
	storePopup.set({ computePosition, autoUpdate, flip, shift, offset, arrow });
</script>

<svelte:head>
    <title>Some Store</title>
    <link rel="icon" type="image/png" href="/img/favicon.png" />
</svelte:head>

<AppShell>
    <svelte:fragment slot="header">
        <!-- App Bar -->
        <AppBar>
            <svelte:fragment slot="lead">
                <strong class="text-xl uppercase pr-2">Welcome to</strong>
                <strong class="text-xl uppercase variant-filled-primary p-2 rounded-xl">Some Store!</strong>
            </svelte:fragment>

            <svelte:fragment slot="trail">
                <LightSwitch />
                <a
                        class="btn btn-sm variant-ghost-primary"
                        href="{apiUrl}/docs"
                        target="_blank"
                        rel="noreferrer"
                >API Docs</a>
                <!-- todo: Update the href to the actual API documentation URL-->
                <a
                        class="btn btn-sm variant-ghost-surface"
                        href="https://github.com/Yrrrrrf/academic_hub"
                        target="_blank"
                        rel="noreferrer"
                >GitHub</a>
            </svelte:fragment>

        </AppBar>
    </svelte:fragment>

    <slot />  <!-- Page Route Content -->

</AppShell>


<div class="fixed bottom-0 left-0 p-2 bg-soft-tertiary text-white text-sm">API URL: <code>{apiUrl}</code></div>
