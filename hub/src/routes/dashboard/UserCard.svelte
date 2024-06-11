<script>
    import { onMount } from 'svelte';
    import { api_url , user_type } from '../../../../../academic_hub/hub/src/stores.js';
    import { Avatar } from "@skeletonlabs/skeleton";

    export let token;

    let userData = null;
    let errorMessage = '';
    let apiUrl;
    let userType;

    $: user_type.subscribe(value => userType = value);
    $: api_url.subscribe(value => apiUrl = value);


    onMount(async () => {
        try {
            const response = await fetch(`${apiUrl}/users/me`, {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                }
            });

            if (response.ok) {
                userData = await response.json();
            } else {
                errorMessage = 'Failed to fetch user data';
                console.error('Fetch error:', response.statusText);
            }
        } catch (error) {
            errorMessage = 'An error occurred';
            console.error('Error:', error);
        }
    });


    function handleLogOut(){
        localStorage.clear();
        location.reload();
    }
</script>

{#if errorMessage}
    <div class="mt-4 text-red-500 text-sm">{errorMessage}</div>
{:else if userData}
    <div class="max-w-md mx-auto shadow-md">
        <div class="flex items-center rounded-t-2xl variant-filled-surface p-4">
            <Avatar background="bg-tertiary-500" border="border-4 border-surface-300-600-token hover:!border-primary-500" cursor="cursor-pointer">
                <span class="text-2xl font-bold leading-10 tracking-tight uppercase">{userData.name.charAt(0)}</span>
            </Avatar>
            <div class="flex-1 text-center">
                <h2 class="text-2xl font-bold mb-2">{userData.name}</h2>
                <p class="text-lg text-gray-400">{userData.email}</p>
            </div>
        </div>
        <div class="bg-gray-300 p-6 text-xl text-black rounded-b-2xl">
            <h3 class="pb-4">Logged In as: {userType.toUpperCase()}</h3>
            <button class="btn variant-glass-primary" on:click={handleLogOut}>Logout</button>

            <div class="pt-4">
                <h3 class="font-semibold">Additional Info</h3>
                {#if userData.additional_info && Object.keys(userData.additional_info).length > 0}
                    <p>{JSON.stringify(userData.additional_info)}</p>
                {:else}
                    <p>No additional data available...</p>
                {/if}
            </div>

        </div>
    </div>
{:else}
    <div class="mt-4 text-gray-500 text-sm">Loading...</div>
{/if}
