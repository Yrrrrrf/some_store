<script lang="ts">
    import { onMount } from 'svelte';
    import { Avatar, ProgressRadial } from '@skeletonlabs/skeleton';
    import { User } from 'lucide-svelte';
    import { current_user_id } from '$lib/stores/app';
    import apiClient  from '$lib/utils/api';

    interface Customer {
        id: number;
        name: string;
    }

    let user: Customer | null = null;
    let isLoading = true;
    let error: string | null = null;

    async function fetchUserData(userId: number) {
        isLoading = true;
        error = null;
        try {
            const response = await apiClient.fetchRows<Customer>('customer', { id: userId.toString() });
            if (response.length > 0) {
                user = response[0];
            } else {
                error = 'User not found';
            }
        } catch (e) {
            console.error('Error fetching user data:', e);
            error = 'Failed to load user data';
        } finally {
            isLoading = false;
        }
    }

    onMount(() => {
        const unsubscribe = current_user_id.subscribe(userId => {
            fetchUserData(userId);
        });

        return unsubscribe;
    });
</script>

<div class="card p-4 variant-soft-surface">
    {#if isLoading}
        <div class="flex justify-center items-center h-32">
            <ProgressRadial />
        </div>
    {:else if error}
        <p class="text-error-500">{error}</p>
    {:else if user}
        <header class="card-header flex items-center gap-4">
            <Avatar width="w-12" rounded="rounded-full">
                <User size={24} />
            </Avatar>
            <div>
                <h3 class="h3">{user.name}</h3>
                <p class="text-sm opacity-70">Customer</p>
            </div>
        </header>
        <section class="p-4">
            <p><strong>ID:</strong> {user.id}</p>
        </section>
    {:else}
        <p>No user data available</p>
    {/if}
</div>
