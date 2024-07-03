<script lang="ts">
    import { Search } from 'lucide-svelte';
    export let searchTerm: string;
    export let t_type: string;
</script>

<div class="relative flex-1 max-w-md">
    <Search class="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-500" size={18} />
    <input
            type="text"
            placeholder="Search {t_type}..."
            bind:value={searchTerm}
            class="input pl-10 pr-4 py-2 w-full variant-form-material"
    />
</div>