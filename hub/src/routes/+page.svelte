<script lang="ts">
	import { goto } from '$app/navigation';
	import { fade, fly } from 'svelte/transition';
	import { LayoutDashboard, ChevronsLeft, BarChart } from 'lucide-svelte';
</script>

<div class="container h-full mx-auto flex flex-col justify-center items-center" in:fade="{{ duration: 300 }}">
	<div class="space-y-5 mt-4" in:fly="{{ y: 20, duration: 500 }}">
		<button class="btn variant-filled-primary text-lg px-6 py-3 flex items-center" on:click={() => goto('/data_view')}>
			Go to Data View <BarChart class="ml-2" />
		</button>
	</div>

	<div class="space-y-5 mt-4" in:fly="{{ y: 20, duration: 500 }}">
		<button class="btn variant-filled-primary text-lg px-6 py-3 flex items-center" on:click={() => goto('/dashboard')}>
			Go to Dashboard <LayoutDashboard class="ml-2" />
		</button>
	</div>

	<div class="space-y-5 mt-4" in:fly="{{ y: 20, duration: 500 }}">
		<button class="btn variant-filled-primary text-lg px-6 py-3 flex items-center" on:click={() => goto('/manage')}>
			Go to Manage <ChevronsLeft class="ml-2" />
		</button>
	</div>

</div>
