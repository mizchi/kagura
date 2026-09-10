import type { Reply } from './contract.d.ts';

/** Serializable location. Credentials and file handles never enter scene documents. */
export interface StorageReference { store: string; key: string }
export type ResourceSource = StorageReference | { url: string };
export interface StorageMetadata {
  key: string;
  size: number;
  type: string;
  /** Opaque, quoted HTTP ETag for R2/IndexedDB. File System returns null. */
  etag: string | null;
  modified: string | null;
}
export interface StoredObject extends StorageMetadata { blob: Blob }
export interface ReadOptions { signal?: AbortSignal }
export interface WriteOptions extends ReadOptions {
  /** undefined: overwrite; null: create only; string: replace that object version. */
  ifMatch?: string | null;
}
export interface ListOptions extends ReadOptions { prefix?: string; cursor?: string | null; limit?: number }
export interface StoragePage { objects: StorageMetadata[]; cursor: string | null }
export interface StorageProvider {
  capabilities: { conditionalWrite: boolean };
  read(key: string, options?: ReadOptions): Promise<StoredObject>;
  write(key: string, blob: Blob, options?: WriteOptions): Promise<StorageMetadata>;
  remove(key: string, options?: ReadOptions): Promise<void>;
  list(options?: ListOptions): Promise<StoragePage>;
  dispose?(): void | Promise<void>;
}
export interface StorageRegistry {
  register(id: string, provider: StorageProvider): void;
  stores(): { id: string; capabilities: { conditionalWrite: boolean } }[];
  read(source: ResourceSource, options?: ReadOptions): Promise<StoredObject>;
  write(location: StorageReference, blob: Blob, options?: WriteOptions): Promise<StorageMetadata>;
  remove(location: StorageReference, options?: ReadOptions): Promise<void>;
  list(store: string, options?: ListOptions): Promise<StoragePage>;
  copy(source: ResourceSource, target: StorageReference, options?: WriteOptions): Promise<StorageMetadata>;
  dispose(): Promise<void>;
}
export interface SavedScene { location: StorageReference; object: StorageMetadata; revision: number }
export interface DocumentStorage {
  save(location: StorageReference, expectedRevision: number, options?: ReadOptions): Promise<SavedScene>;
  load(location: StorageReference, expectedRevision: number, options?: ReadOptions): Promise<Reply & { ok: true }>;
}
export interface BrowserStorage extends StorageRegistry, DocumentStorage {
  location(): StorageReference;
  save(location?: StorageReference, expectedRevision?: number, options?: ReadOptions): Promise<SavedScene>;
  load(location: StorageReference, expectedRevision?: number, options?: ReadOptions): Promise<Reply & { ok: true }>;
  download(source: ResourceSource, filename?: string, options?: ReadOptions): Promise<{ size: number; type: string }>;
  /** Without a handle, must be called directly from a user gesture. */
  connectDirectory(handle?: FileSystemDirectoryHandle): Promise<string>;
  /** Token stays in this session's memory. */
  connectWorker(options: { endpoint: string; token: string }): Promise<string>;
}
export type StorageErrorCode = 'invalid' | 'not_found' | 'conflict' | 'permission' | 'unsupported' | 'canceled' | 'quota' | 'too_large' | 'io';
