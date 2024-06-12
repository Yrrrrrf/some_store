<script lang="ts">
	import { goto } from '$app/navigation';
</script>

<div class="container h-full mx-auto flex justify-center items-center">
	<div class="space-y-5">
<!--		<h1 class="h1 flex">Welcome to <div class="variant-filled-primary border-l-8">Some Store!</div></h1>-->
		<button class="btn variant-filled-primary" on:click={() => goto('/dashboard')}>Go to Dashboard</button>
	</div>
</div>
