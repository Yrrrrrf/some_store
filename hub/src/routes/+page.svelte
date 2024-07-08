<script lang="ts">
    import { AppShell } from '@skeletonlabs/skeleton';
    import { Zap, ShoppingCart, Database, BarChart } from 'lucide-svelte';
    import CustomerSelector from './CustomerSelector.svelte';

    const features = [
        { icon: ShoppingCart, title: 'Product Management', description: 'Easily manage your product catalog with intuitive tools.' },
        { icon: Database, title: 'Data Views', description: 'Access and analyze your data with customizable views.' },
        { icon: BarChart, title: 'Dashboard', description: 'Get insights at a glance with our comprehensive dashboard.' },
    ];
</script>

<main class="container mx-auto p-4 space-y-8">
    <header class="text-center space-y-4">
        <h1 class="h1">Welcome to Some Store</h1>
        <p class="text-xl">Your one-stop solution for store management</p>
    </header>

    <CustomerSelector />

    <section class="card p-4 variant-ghost-surface">
        <header class="card-header">
            <h2 class="h2">Get Started</h2>
        </header>
        <div class="p-4">
            <p class="mb-4">Explore our features and start managing your store efficiently:</p>
            <div class="flex flex-col space-y-2 md:flex-row md:space-y-0 md:space-x-2">
                <a class="btn variant-filled-primary" href="/dashboard">Go to Dashboard</a>
                <a class="btn variant-filled-secondary" href="/data_view">Explore Data Views</a>
                <a class="btn variant-filled-tertiary" href="/manage">Manage Products</a>
            </div>
        </div>
    </section>

    <section class="card p-4 variant-ghost-surface">
        <header class="card-header">
            <h2 class="h2 flex items-center">
                <Zap class="mr-2" />
                Key Features
            </h2>
        </header>
        <div class="p-4 grid grid-cols-1 md:grid-cols-3 gap-4">
            {#each features as feature}
                <div class="card p-4 variant-soft flex flex-col items-center text-center">
                    <svelte:component this={feature.icon} size={48} class="mb-2" />
                    <h3 class="h3">{feature.title}</h3>
                    <p>{feature.description}</p>
                </div>
            {/each}
        </div>
    </section>

</main>
