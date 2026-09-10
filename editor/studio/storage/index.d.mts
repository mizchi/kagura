import type { StorageRegistry, StorageProvider, DocumentStorage, StorageErrorCode } from '../public/storage.d.ts';
import type { StudioAPI } from '../public/contract.d.ts';
export type * from '../public/storage.d.ts';
export function createStorageRegistry(): StorageRegistry;
export function createDocumentStorage(editor: StudioAPI, storage: StorageRegistry): DocumentStorage;
export function createIndexedDBStore(options?: { name?: string; indexedDB?: IDBFactory }): StorageProvider;
export function createFileSystemStore(directory: FileSystemDirectoryHandle): StorageProvider;
export function createWorkerStore(options: { endpoint: string; getToken?: () => string | Promise<string>; fetch?: typeof fetch }): StorageProvider;
export class StorageError extends Error { code: StorageErrorCode; constructor(code: StorageErrorCode, message: string) }
export const MAX_OBJECT_BYTES: number;
