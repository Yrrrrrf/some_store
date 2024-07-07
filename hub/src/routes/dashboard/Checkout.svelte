<script lang="ts">
    import { ProgressRadial, InputChip, Select } from '@skeletonlabs/skeleton';
    import { apiClient } from '$lib/utils/api';
    import { current_user_id } from '$lib/stores/app';
    import { exportOrderToPDF } from '$lib/utils/pdfExport';

    interface CartItem {
        id: number;
        product_id: number;
        quantity: number;
        product: {
            description: string;
            unit_price: number;
        };
    }

    let cartItems: CartItem[] = [];
    let isLoading = true;
    let error: string | null = null;
    let total = 0;

    let address = '';
    const paymentMethods = ['Credit Card', 'PayPal', 'Bank Transfer'];
    let selectedPaymentMethod = paymentMethods[0];

    async function fetchCartItems() {
        isLoading = true;
        error = null;
        try {
            const response = await apiClient.fetchRows<CartItem>('cart', { customer_id: $current_user_id.toString() });
            cartItems = await Promise.all(response.map(async (item) => {
                const [product] = await apiClient.fetchRows('product', { id: item.product_id.toString() });
                return { ...item, product };
            }));
            total = cartItems.reduce((sum, item) => sum + item.quantity * item.product.unit_price, 0);
            isLoading = false;
        } catch (e) {
            console.error('Error fetching cart items:', e);
            error = 'Failed to load cart items';
            isLoading = false;
        }
    }

    function handleDownloadPDF() {
        const orderData = {
            cartItems,
            total,
            address,
            paymentMethod: selectedPaymentMethod,
            orderDate: new Date().toISOString(),
            orderId: `ORD-${Math.random().toString(36).substr(2, 9).toUpperCase()}`
        };
        exportOrderToPDF(orderData);
    }

    $: if ($current_user_id) {
        fetchCartItems();
    }
</script>

<div class="card p-4 variant-ghost-surface">
    <h2 class="h2 mb-4">Checkout</h2>

    {#if isLoading}
        <div class="flex justify-center items-center h-32">
            <ProgressRadial />
        </div>
    {:else if error}
        <p class="text-error-500">{error}</p>
    {:else}
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
                <h3 class="h3 mb-2">Cart Summary</h3>
                <ul class="list">
                    {#each cartItems as item}
                        <li class="flex justify-between items-center py-2">
                            <span>{item.product.description} x {item.quantity}</span>
                            <span>${(item.quantity * item.product.unit_price).toFixed(2)}</span>
                        </li>
                    {/each}
                </ul>
                <div class="flex justify-between items-center mt-4 font-bold">
                    <span>Total:</span>
                    <span>${total.toFixed(2)}</span>
                </div>
            </div>
            <div>
                <h3 class="h3 mb-2">Shipping & Payment</h3>
                <label class="label">
                    <span>Address</span>
                    <InputChip bind:value={address} name="address" placeholder="Enter your address..." />
                </label>
                <label class="label mt-4">
                    <span>Payment Method</span>
                    <Select bind:value={selectedPaymentMethod}>
                        {#each paymentMethods as method}
                            <option value={method}>{method}</option>
                        {/each}
                    </Select>
                </label>
            </div>
        </div>
        <button class="btn variant-filled-primary w-full mt-4" on:click={handleDownloadPDF}>
            Download Order PDF
        </button>
    {/if}
</div>