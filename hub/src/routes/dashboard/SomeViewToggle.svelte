<script lang="ts">
    import { Grid, List } from 'lucide-svelte';
    export let viewMode: 'grid' | 'list';
</script>

<div class="flex space-x-2">
    <button class="btn variant-ghost-surface" on:click={() => viewMode = 'grid'}>
        <div class:text-primary-500={viewMode === 'grid'}>
            <Grid size={20} />
        </div>
    </button>
    <button class="btn variant-ghost-surface" on:click={() => viewMode = 'list'}>
        <div class:text-primary-500={viewMode === 'list'}>
            <List size={20} />
        </div>
    </button>
</div>