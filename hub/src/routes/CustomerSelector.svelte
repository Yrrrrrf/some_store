<script lang="ts">
    import { onMount } from 'svelte';
    import { ProgressRadial } from '@skeletonlabs/skeleton';
    import { apiClient } from '$lib/utils/api';
    import { current_user_id } from '$lib/stores/app';
    import { fade, fly, slide } from 'svelte/transition';
    import { UserPlus, ArrowRight } from 'lucide-svelte';
    import { goto } from "$app/navigation";

    interface Customer {
        id: number;
        name: string;
    }

    let customers: Customer[] = [];
    let selectedCustomerId: number | null = null;
    let isLoading = true;
    let error: string | null = null;
    let newCustomerName: string = '';
    let showNewCustomerInput = false;
    let dashboardButton: HTMLButtonElement;

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
        const trimmedName = newCustomerName.trim();
        if (trimmedName.length > 0) {
            try {
                const newCustomer = await apiClient.createRecord<Customer>('customer', { name: trimmedName });
                customers = [...customers, newCustomer];
                newCustomerName = '';
                handleCustomerSelect(newCustomer.id);
                showNewCustomerInput = false;
                // Focus on the 'Go To Dashboard' button after creating a new customer
                setTimeout(() => dashboardButton.focus(), 0);
            } catch (e) {
                console.error('Error creating new customer:', e);
                error = 'Failed to create new customer';
            }
        }
    }

    function toggleNewCustomerInput() {
        showNewCustomerInput = !showNewCustomerInput;
        if (!showNewCustomerInput) {
            newCustomerName = '';
        }
    }

    function handleSelectChange(event: Event) {
        const target = event.target as HTMLSelectElement;
        const customerId = parseInt(target.value);
        handleCustomerSelect(customerId);
    }
</script>

<div class="card p-4 variant-ghost-surface" in:fade={{ duration: 300 }}>
    <header class="card-header">
        <h3 class="h3">Select Customer or Register New</h3>
    </header>
    {#if isLoading}
        <div class="flex justify-center items-center h-32">
            <ProgressRadial />
        </div>
    {:else if error}
        <p class="text-error-500">{error}</p>
    {:else}
        <div class="p-4 space-y-4">
            <div class="flex items-center space-x-2">
                <select
                        class="select flex-grow"
                        bind:value={selectedCustomerId}
                        on:change={handleSelectChange}
                >
                    <option value={null}>Choose a customer...</option>
                    {#each customers as customer}
                        <option value={customer.id}>{customer.name}</option>
                    {/each}
                </select>
                <button
                        class="btn variant-filled-primary"
                        on:click={() => goto('/dashboard')}
                        disabled={!selectedCustomerId}
                        bind:this={dashboardButton}
                >
                    Go To Dashboard
                    <ArrowRight class="ml-2" size={16} />
                </button>
            </div>

            <div class="flex items-center space-x-2">
                {#if showNewCustomerInput}
                    <div class="flex-grow" in:slide={{ duration: 300 }}>
                        <input
                                type="text"
                                class="input w-full"
                                placeholder="Enter new customer name"
                                bind:value={newCustomerName}
                                on:keypress={(e) => e.key === 'Enter' && handleCreateCustomer()}
                        />
                    </div>
                {/if}
                <button
                        class="btn variant-filled-secondary"
                        on:click={showNewCustomerInput ? handleCreateCustomer : toggleNewCustomerInput}
                        disabled={showNewCustomerInput && newCustomerName.trim().length === 0}
                >
                    {#if showNewCustomerInput}
                        Register Customer
                    {:else}
                        <UserPlus class="mr-2" size={16} />
                        New Customer
                    {/if}
                </button>
                {#if showNewCustomerInput}
                    <button
                            class="btn variant-soft-surface"
                            on:click={toggleNewCustomerInput}
                            in:fade={{ duration: 300 }}
                    >
                        Cancel
                    </button>
                {/if}
            </div>
        </div>
    {/if}
</div>