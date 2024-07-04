import { writable, type Writable } from 'svelte/store';

// Store definitions
export const api_url: Writable<string> = writable('http://127.0.0.1:8000');
export const current_schema: Writable<string> = writable('store');
export const current_table: Writable<string> = writable('some-table');
export const current_tab: Writable<string> = writable('some-tab');
export const current_view: Writable<string> = writable('some-view');

/**
 * Converts a snake_case string to Title Case With Spaces.
 * @param str - The snake_case string to convert.
 * @returns The converted string in Title Case With Spaces.
 */
export function snakeToCamelWithSpaces(str: string): string {
    return str
        .split('_')
        .map(word => word.charAt(0).toUpperCase() + word.slice(1))
        .join(' ');
}

/**
 * Builds a URL with query parameters.
 * @param baseUrl - The base URL.
 * @param params - An object containing query parameters.
 * @returns The complete URL with query parameters.
 */
function buildUrl(baseUrl: string, params: Record<string, string>): string {
    const filteredParams = Object.fromEntries(
        Object.entries(params).filter(([_, value]) => value !== '')
    );
    const queryParams = new URLSearchParams(filteredParams).toString();
    return `${baseUrl}${queryParams ? `?${queryParams}` : ''}`;
}

/**
 * Handles API requests.
 * @param url - The URL to fetch from.
 * @param options - Fetch options.
 * @returns The response data.
 * @throws Error if the fetch fails or returns a non-OK status.
 */
async function apiRequest<T>(url: string, options: RequestInit = {}): Promise<T> {
    console.log('Request URL:', url);
    try {
        const response = await fetch(url, {
            ...options,
            headers: {
                'Content-Type': 'application/json',
                ...options.headers,
            },
        });
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        return await response.json();
    } catch (error) {
        console.error('API request error:', error);
        throw error;
    }
}

/**
 * Fetches rows from a table or view.
 * @param apiUrl - The base API URL.
 * @param name - The name of the table or view.
 * @param formData - The form data for filtering.
 * @param setData - A function to set the fetched data.
 * @param isView - Whether the target is a view (default: false).
 */
export async function fetchRows(
    apiUrl: string,
    name: string,
    formData: Record<string, string>,
    setData: (data: any[]) => void,
    isView: boolean = false
): Promise<void> {
    const urlPath = isView ? `view/${name}` : name;
    const url = buildUrl(`${apiUrl}/${urlPath.replace(/ /g, '_').toLowerCase()}`, formData);
    try {
        const data = await apiRequest<any[]>(url);
        setData(data);
        console.log(`Rows for ${isView ? 'view' : 'table'} ${name}:`, data);
    } catch (error) {
        console.error(`Failed to fetch rows for ${isView ? 'view' : 'table'} ${name}:`, error);
    }
}

/**
 * Fetches all tables.
 * @param apiUrl - The base API URL.
 * @param setTables - A function to set the fetched tables.
 */
export async function fetchTables(apiUrl: string, setTables: (tables: string[]) => void): Promise<void> {
    try {
        const data = await apiRequest<string[]>(`${apiUrl}/tables`);
        setTables(data);
    } catch (error) {
        console.error('Failed to fetch tables:', error);
    }
}

/**
 * Fetches all views.
 * @param apiUrl - The base API URL.
 * @param setViews - A function to set the fetched views.
 */
export async function fetchViews(apiUrl: string, setViews: (views: string[]) => void): Promise<void> {
    try {
        const data = await apiRequest<string[]>(`${apiUrl}/views`);
        setViews(data);
    } catch (error) {
        console.error('Failed to fetch views:', error);
    }
}

/**
 * Fetches columns for a table.
 * @param apiUrl - The base API URL.
 * @param table - The name of the table.
 * @param setColumns - A function to set the fetched columns.
 */
export async function fetchColumns(apiUrl: string, table: string, setColumns: (columns: string[]) => void): Promise<void> {
    try {
        const data = await apiRequest<string[]>(`${apiUrl}/${table.replace(/ /g, '_').toLowerCase()}/columns`);
        setColumns(data);
    } catch (error) {
        console.error(`Failed to fetch columns for table ${table}:`, error);
    }
}

// Alias functions for backward compatibility
export const fetchTableRows = (apiUrl: string, table: string, formData: any, setData: (data: any[]) => void) =>
    fetchRows(apiUrl, table, formData, setData, false);
export const fetchViewRows = (apiUrl: string, view: string, formData: any, setData: (data: any[]) => void) =>
    fetchRows(apiUrl, view, formData, setData, true);





















/**
 * Creates a new record in a table.
 * @param apiUrl - The base API URL.
 * @param tableName - The name of the table.
 * @param data - The data to create the new record.
 * @returns A promise that resolves with the created record data.
 */
export async function createRecord(
    apiUrl: string,
    tableName: string,
    data: Record<string, any>
): Promise<any> {
    const url = `${apiUrl}/${tableName.replace(/ /g, '_').toLowerCase()}`;
    try {
        const response = await apiRequest(url, {
            method: 'POST',
            body: JSON.stringify(data),
        });
        console.log(`Successfully created record in ${tableName}:`, response);
        return response;
    } catch (error) {
        console.error(`Failed to create record in ${tableName}:`, error);
        throw error;
    }
}







/**
 * Deletes a record from a table.
 * @param apiUrl - The base API URL.
 * @param tableName - The name of the table.
 * @param field - The field to use for identifying the record (usually 'id').
 * @param value - The value of the field to identify the record to delete.
 * @returns A promise that resolves when the delete operation is complete.
 */
export async function deleteRecord(
    apiUrl: string,
    tableName: string,
    field: string,
    value: string | number
): Promise<void> {
    const url = `${apiUrl}/${tableName.replace(/ /g, '_').toLowerCase()}/${field}=${value}`;
    try {
        await apiRequest(url, { method: 'DELETE' });
        console.log(`Successfully deleted record from ${tableName} where ${field} = ${value}`);
    } catch (error) {
        console.error(`Failed to delete record from ${tableName}:`, error);
        throw error;
    }
}

/**
 * Updates an existing record in a table.
 * @param apiUrl - The base API URL.
 * @param tableName - The name of the table.
 * @param field - The field to use for identifying the record (usually 'id').
 * @param value - The value of the field to identify the record to update.
 * @param data - The updated data for the record.
 * @returns A promise that resolves with the updated record data.
 */
export async function updateRecord(
    apiUrl: string,
    tableName: string,
    field: string,
    value: string | number,
    data: Record<string, any>
): Promise<any> {
    const url = `${apiUrl}/${tableName.replace(/ /g, '_').toLowerCase()}/${field}=${value}`;
    try {
        const response = await apiRequest(url, {
            method: 'PUT',
            body: JSON.stringify(data),
        });
        console.log(`Successfully updated record in ${tableName} where ${field} = ${value}:`, response);
        return response;
    } catch (error) {
        console.error(`Failed to update record in ${tableName}:`, error);
        throw error;
    }
}
