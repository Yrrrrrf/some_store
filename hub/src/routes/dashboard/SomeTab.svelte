<script>
    import { onMount } from 'svelte';
    import SomeTable from './SomeTable.svelte';

    export let type;
    export let name;
    export let fetchUrl;
    export let currentSchema;

    let columns = [];
    let tableData = [];

    async function fetchData() {
        const request_url = `${fetchUrl}`;
        console.log('Request URL:', request_url);
        try {
            const response = await fetch(request_url, {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json',
                }
            });
            if (response.ok) {
                const data = await response.json();
                tableData = data;
                columns = Object.keys(data[0] || {}); // Keep original keys
                console.log(`Rows for ${name}:`, data);
            } else {
                throw new Error('Failed to fetch rows');
            }
        } catch (error) {
            console.error('Error:', error);
        }
    }

    $: fetchData();

    onMount(() => {
        fetchData();
    });
</script>

<h2 class="text-xl">{name} Data</h2>
<SomeTable {columns} {tableData}/>
