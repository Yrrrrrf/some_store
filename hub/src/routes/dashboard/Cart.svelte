<script lang="ts">
    import { ShoppingCart } from 'lucide-svelte';
    import { cartStore, cartItemCount, cartTotal } from '$lib/stores/storeManager';

    export let userId = 1; // Default to user with ID 1 for testing

    $: userCart = $cartStore.filter(item => item.customer_id === userId);
</script>

<div class="card p-4 variant-soft-surface">
    <header class="card-header flex items-center justify-between">
        <h3 class="h3 flex items-center gap-2">
            <ShoppingCart size={24} />
            Cart
        </h3>
        <span class="badge variant-filled-primary">{$cartItemCount}</span>
    </header>
    <section class="p-4">
        {#if userCart.length === 0}
            <p>Your cart is empty</p>
        {:else}
            <ul class="list-disc list-inside">
                {#each userCart as item}
                    <li>{item.description} - ${item.unit_price.toFixed(2)} x {item.quantity}</li>
                {/each}
            </ul>
            <p class="mt-4 font-bold">Total: ${$cartTotal.toFixed(2)}</p>
        {/if}
    </section>
</div>