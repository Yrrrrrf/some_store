<script lang="ts">
    import { ShoppingCart, Database, BarChart, Zap } from 'lucide-svelte';
    import CustomerSelector from './CustomerSelector.svelte';
    import { current_user_id } from '$lib/stores/app';

    /**
     * Defines the structure for a feature button
     * @typedef {Object} FeatureButton
     * @property {typeof import('lucide-svelte').Icon} icon - The Lucide icon component
     * @property {string} title - The title of the feature
     * @property {string} description - A brief description of the feature
     * @property {string} href - The URL to navigate to when the button is clicked
     */

    /**
     * Array of feature buttons to be displayed on the homepage
     * @type {FeatureButton[]}
     */
    const featureButtons = [
        {
            icon: ShoppingCart,
            title: 'Product Management',
            description: 'Easily manage your product catalog with intuitive tools.',
            href: '/manage'
        },
        {
            icon: Database,
            title: 'Data Views',
            description: 'Access and analyze your data with customizable views.',
            href: '/data_view'
        },
        {
            icon: BarChart,
            title: 'Dashboard',
            description: 'Get insights at a glance with our comprehensive dashboard.',
            href: '/dashboard'
        },
    ];

    /**
     * Reactive variable to check if a user is selected
     * @type {boolean}
     */
    $: isUserSelected = $current_user_id !== null && $current_user_id !== undefined;
</script>

<style lang="postcss">
    @keyframes wave {
        0%, 100% {
            transform: translateY(0);
        }
        50% {
            transform: translateY(-10px);
        }
    }

    .feature-button {
        position: relative;
        overflow: hidden;
    }

    .feature-button::after {
        content: '';
        position: absolute;
        bottom: -50%;
        left: -10%;
        right: -10%;
        height: 100%;
        background: radial-gradient(ellipse at center, rgba(255,255,255,0.3) 0%, rgba(255,255,255,0) 70%);
        animation: wave 3s infinite ease-in-out;
    }

    .feature-button:hover::after {
        animation: wave 1.5s infinite ease-in-out;
    }

    .feature-button:nth-child(2)::after {
        animation-delay: -0.5s;
    }

    .feature-button:nth-child(3)::after {
        animation-delay: -1s;
    }
</style>

<main class="container mx-auto p-4 space-y-8">
    <header class="text-center space-y-4">
        <h1 class="h1">Welcome to Some Store</h1>
        <p class="text-xl">Your one-stop solution for store management</p>
    </header>

    <CustomerSelector />

    <section class="card p-4 variant-ghost-surface">
        <header class="card-header flex items-center mb-4">
            <Zap size={36} class="text-primary-500" />
            <h2 class="h2 pl-4">
                Get Started
            </h2>
        </header>

        <div class="p-4">
            <p class="mb-4">Explore our features and start managing your store efficiently:</p>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                {#each featureButtons as button, index}
                    <a href={button.href} class="feature-button card p-4 variant-soft hover:variant-soft-primary transition-all duration-200 flex flex-col items-center text-center group">
                        <svelte:component this={button.icon} size={48} class="mb-2 group-hover:text-primary-500 transition-colors duration-200" />
                        <h3 class="h3 mb-2">{button.title}</h3>
                        <p>{button.description}</p>
                    </a>
                {/each}
            </div>
        </div>
    </section>
</main>