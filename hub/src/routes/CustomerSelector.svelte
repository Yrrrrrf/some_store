<script lang="ts">
    import { onMount } from 'svelte';
    import { ListBox, ListBoxItem, InputChip, ProgressRadial } from '@skeletonlabs/skeleton';
    import { apiClient } from '$lib/utils/api';
    import { current_user_id } from '$lib/stores/app';
    import { fade, fly } from 'svelte/transition';

    interface Customer {
        id: number;
        name: string;
    }

    let customers: Customer[] = [];
    let selectedCustomerId: number | null = null;
    let isLoading = true;
    let error: string | null = null;
    let newCustomerName: string = '';

    onMount(async () => {
        try {
            customers = await apiClient.fetchRows<Customer>('customer');
            isLoading = false;
        } catch (e) {
            console.error('Error fetching customers:', e);
            error = 'Failed to load customers';
            isLoading = false;
        }
    });

    function handleCustomerSelect(customerId: number) {
        selectedCustomerId = customerId;
        current_user_id.set(customerId);
    }

    async function handleCreateCustomer() {
        if (newCustomerName.trim().length > 0) {
            try {
                const newCustomer = await apiClient.createRecord<Customer>('customer', { name: newCustomerName.trim() });
                customers = [...customers, newCustomer];
                newCustomerName = '';
                handleCustomerSelect(newCustomer.id);
            } catch (e) {
                console.error('Error creating new customer:', e);
                error = 'Failed to create new customer';
            }
        }
    }
</script>

<style>
    .button-disabled {
        background-color: #ddd;
        cursor: not-allowed;
    }
    .button-enabled {
        background-color: #4caf50;
        color: white;
    }
</style>

<div class="card p-4 variant-ghost-surface">
    <header class="card-header">
        <h3 class="h3">Select or Create Customer</h3>
    </header>
    {#if isLoading}
        <div class="flex justify-center items-center h-32">
            <ProgressRadial />
        </div>
    {:else if error}
        <p class="text-error-500">{error}</p>
    {:else}
        <div class="p-4">
            <label class="label">
                <span>Select Existing Customer</span>
                <select
                        class="select"
                        bind:value={selectedCustomerId}
                        on:change={() => handleCustomerSelect(selectedCustomerId)}
                >
                    <option value={null}>Choose a customer...</option>
                    {#each customers as customer}
                        <option value={customer.id}>{customer.name}</option>
                    {/each}
                </select>
            </label>

            <div class="mt-4">
                <label class="label">
                    <span>New Customer Name</span>
                    <input
                            type="text"
                            class="input"
                            bind:value={newCustomerName}
                            on:input={() => newCustomerName = newCustomerName.trim()}
                    />
                </label>
                <button
                        class="btn mt-2 {newCustomerName.length > 0 ? 'button-enabled' : 'button-disabled'}"
                        on:click={handleCreateCustomer}
                        disabled={newCustomerName.length === 0}
                >
                    Create Customer
                </button>
            </div>
        </div>
    {/if}
</div>
