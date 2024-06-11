import { writable, type Writable } from 'svelte/store';

export const api_url: Writable<string> = writable('http://127.0.0.1:8000');
export const current_schema: Writable<string> = writable('store');
export const current_table: Writable<string> = writable('some-table');
export const current_tab: Writable<string> = writable('some-tab');
export const current_view: Writable<string> = writable('some-view');

export function snakeToCamelWithSpaces(str: string): string {
    return str
        .split('_')
        .map(word => word.charAt(0).toUpperCase() + word.slice(1))
        .join(' ');
}

export async function fetchTableRows(apiUrl: string, table: string, setData: (data: any[]) => void): Promise<void> {
    const request_url = `${apiUrl}/${table.replace(/ /g, '_').toLowerCase()}/all`;
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
            setData(data);

            console.log(`Rows for ${table}:`, data);
        } else {
            throw new Error('Failed to fetch rows');
        }
    } catch (error) {
        console.error('Error:', error);
    }
}

export async function fetchTables(apiUrl: string, setTables: (tables: string[]) => void): Promise<void> {
    const request_url = `${apiUrl}/tables`;
    console.log('Request URL:', request_url);
    try {
        const response = await fetch(request_url, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });
        if (response.ok) {
            const data = await response.json();
            setTables(data);
        } else throw new Error('Failed to fetch tables');
    } catch (error) {
        console.error('Error:', error);
    }
}

export async function fetchViews(apiUrl: string, setViews: (views: string[]) => void): Promise<void> {
    // const request_url = `${apiUrl}/${schema}/views`;
    const request_url = `${apiUrl}/views`;
    console.log('Request URL:', request_url);
    try {
        const response = await fetch(request_url, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });
        if (response.ok) {
            const data = await response.json();
            setViews(data);
        } else {
            throw new Error('Failed to fetch views');
        }
    } catch (error) {
        console.error('Error:', error);
    }
}


export async function fetchViewRows(apiUrl: string, view: string, setData: (data: any[]) => void): Promise<void> {
    const request_url = `${apiUrl}/view/${view.replace(/ /g, '_').toLowerCase()}`;
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
            setData(data);
            console.log(`Rows for ${view}:`, data);
        } else {
            throw new Error('Failed to fetch rows');
        }
    } catch (error) {
        console.error('Error:', error);
    }
}
