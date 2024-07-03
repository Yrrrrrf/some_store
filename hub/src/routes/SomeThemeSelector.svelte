<script lang="ts">
    import { getContext } from 'svelte';
    import { Palette } from 'lucide-svelte';
    import { onMount } from 'svelte';

    const themes = [
        'skeleton',
        'modern',
        'hamlindigo',
        'vintage',
        'gold-nouveau',
        'seafoam',
        'crimson'
    ];

    let currentTheme = 'skeleton';
    let popupOpen = false;
    let popupRef;

    function setTheme(theme: string) {
        currentTheme = theme;
        document.body.setAttribute('data-theme', theme);
        closePopup();
    }

    function openPopup() {
        popupOpen = true;
    }

    function closePopup() {
        popupOpen = false;
    }

    onMount(() => {
        const handleClickOutside = (event) => {
            if (popupRef && !popupRef.contains(event.target)) {
                closePopup();
            }
        };
        document.addEventListener('click', handleClickOutside);
        return () => document.removeEventListener('click', handleClickOutside);
    });
</script>

<div class="relative" bind:this={popupRef}>
    <button class="btn btn-sm variant-ghost-surface" on:click|stopPropagation={openPopup}>
        <Palette size={20} />
        <span class="ml-2 hidden sm:inline">Theme</span>
    </button>
    {#if popupOpen}
        <div class="absolute right-0 mt-2 w-48 bg-surface-100-800-token rounded-lg shadow-lg z-50 popup">
            {#each themes as theme}
                <button
                        class="block w-full text-left px-4 py-2 hover:bg-primary-hover-token"
                        class:bg-primary-active-token={currentTheme === theme}
                        on:click={() => setTheme(theme)}
                >
                    {theme}
                </button>
            {/each}
        </div>
    {/if}
</div>

<style>
    .popup {
        animation: fadeIn 0.3s ease-out;
    }

    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(-10px); }
        to { opacity: 1; transform: translateY(0); }
    }
</style>
