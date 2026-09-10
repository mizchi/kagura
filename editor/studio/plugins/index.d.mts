import type { StudioAPI } from '../public/contract.d.ts';
import type { PluginSDK, PluginHost } from '../public/plugins.d.ts';
export type * from '../public/plugins.d.ts';
export const defineJSPlugin: PluginSDK['defineJSPlugin'];
export const fromJSONModule: PluginSDK['fromJSONModule'];
export const fromWasm: PluginSDK['fromWasm'];
export function createPluginHost(editor: StudioAPI): PluginHost;
export const ABI_VERSION: 1;
export const MAX_MESSAGE_BYTES: number;
export class PluginError extends Error { code: string; constructor(code: string, message: string) }
