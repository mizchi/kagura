/** Input prepared without DOM/GPU. Bytes are detached from the backing project store. */
export interface PreparedModel {
  format: 'gltf' | 'obj';
  json: string;
  text: string;
  buffers: Uint8Array[];
  warnings: string[];
}
export interface ModelResources { read(path: string): Promise<Blob>; }
export function modelFormat(path: unknown): 'glb' | 'gltf' | 'obj' | null;
export function dependencyPath(model: string, uri: string): string;
export function prepareModel(resources: ModelResources, path: string): Promise<PreparedModel>;
