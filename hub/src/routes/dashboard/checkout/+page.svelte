<script lang="ts">
    import { onMount } from 'svelte';
    import { apiClient } from '$lib/utils/api';
    import { current_user_id } from '$lib/stores/app';
    import { ProgressRadial } from '@skeletonlabs/skeleton';
    import { exportOrderToPDF } from '$lib/utils/pdfExport';
    import { ShoppingCart} from "lucide-svelte";

    interface CartItem {
        id: number;
        customer_id: number;
        product_id: number;
        quantity: number;
    }

    interface Product {
        id: number;
        description: string;
        unit_price: number;
        image_url: string;
    }

    let cartItems: CartItem[] = [];
    let productDetails: Map<number, Product> = new Map();
    let isLoading = true;
    let error: string | null = null;
    let total = 0;

    let address = '123 Main St, Anytown, USA'; // Example address
    const paymentMethods = ['Credit Card', 'PayPal', 'Bank Transfer'];
    let selectedPaymentMethod = paymentMethods[0];

    $: {
        if (cartItems && productDetails.size > 0) {
            total = cartItems.reduce((sum, item) => {
                const product = productDetails.get(item.product_id);
                return sum + (product ? item.quantity * product.unit_price : 0);
            }, 0);
        }
    }

    async function fetchProductDetails() {
        const productIds = [...new Set(cartItems.map(item => item.product_id))];
        for (const productId of productIds) {
            if (!productDetails.has(productId)) {
                try {
                    const [product] = await apiClient.fetchRows<Product>('product', { id: productId.toString() });
                    if (product) {
                        productDetails.set(productId, product);
                    }
                } catch (e) {
                    console.error(`Error fetching product details for ID ${productId}:`, e);
                }
            }
        }
        productDetails = new Map(productDetails); // Trigger reactivity
    }

    async function fetchCartItems() {
        isLoading = true;
        error = null;
        try {
            const response = await apiClient.fetchRows<CartItem>('cart', { customer_id: $current_user_id.toString() });
            cartItems = response;
            await fetchProductDetails();
        } catch (e) {
            console.error('Error fetching cart items:', e);
            error = 'Failed to load cart items';
        } finally {
            isLoading = false;
        }
    }

    function handleDownloadPDF() {
        const orderData = {
            cartItems: cartItems.map(item => ({
                product: productDetails.get(item.product_id),
                quantity: item.quantity
            })),
            total,
            address,
            paymentMethod: selectedPaymentMethod,
            orderDate: new Date().toISOString(),
            orderId: `ORD-${Math.random().toString(36).substr(2, 9).toUpperCase()}`
        };
        exportOrderToPDF(orderData).then(pdfUrl => {
            window.open(pdfUrl, '_blank');
        });
    }

    onMount(() => {
        fetchCartItems();
    });
</script>

<div class="card p-4 variant-ghost-surface">
    <header class="card-header flex justify-between items-center">
        <h3 class="h3 flex items-center gap-2">
            <ShoppingCart size={24} />
            Checkout
        </h3>
    </header>

    {#if isLoading}
        <div class="flex justify-center items-center h-32">
            <ProgressRadial />
        </div>
    {:else if error}
        <p class="text-error-500 p-4">{error}</p>
    {:else if cartItems.length === 0}
        <p class="p-4 text-center">Your cart is empty</p>
    {:else}
        <ul class="divide-y divide-gray-200">
            {#each cartItems as item (item.id)}
                {@const product = productDetails.get(item.product_id)}
                {#if product}
                    <li class="py-4 flex items-center justify-between" in:fade={{ duration: 300 }} out:fly={{ x: -50, duration: 300 }}>
                        <div class="flex items-center space-x-4">
                            <img src={product.image_url} alt={product.description} class="w-16 h-16 object-cover rounded"/>
                            <div>
                                <h4 class="font-semibold">{product.description}</h4>
                                <p class="text-sm text-gray-500">${product.unit_price.toFixed(2)} each</p>
                            </div>
                        </div>
                        <div class="flex items-center space-x-2">
                            <span class="font-semibold">{item.quantity}</span>
                            <span class="font-semibold">${(item.quantity * product.unit_price).toFixed(2)}</span>
                        </div>
                    </li>
                {/if}
            {/each}
        </ul>
        <div class="mt-4 p-4 bg-surface-100-800-token rounded-lg">
            <div class="flex justify-between items-center">
                <span class="text-lg font-semibold">Total:</span>
                <span class="text-xl font-bold">${total.toFixed(2)}</span>
            </div>
        </div>
        <button class="btn variant-filled-primary w-full mt-4" on:click={handleDownloadPDF}>
            Download Order PDF
        </button>
    {/if}
</div>
