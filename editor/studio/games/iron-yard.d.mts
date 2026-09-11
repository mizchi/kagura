import type { Snapshot } from '../public/contract.d.ts';
import type { PanePlugin } from '../public/plugins.d.ts';
import type { IronYardSettings, IronYardSnapshot } from '../public/games.d.ts';
export const defaultSettings: Readonly<IronYardSettings>;
export const settingsId: 'iron-yard.settings';
export const previewId: 'iron-yard.preview';
export function readSettings(snapshot: Snapshot): IronYardSettings;
export function simulate(settings: IronYardSettings, input: { frames: number; forward: number; boost: boolean }): Promise<IronYardSnapshot>;
export function createIronYardPlugin(options?: { mount?: PanePlugin['mount']; inspect?: () => IronYardSnapshot | null; sessionId?: string; dispose?: () => void }): PanePlugin;
