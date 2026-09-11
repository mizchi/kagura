// Ported from mizchi/modeling-playground game/studio; scene-editor.html v1 contract.
import type { StageDefinition, Vec3 } from '../types.ts';

export type SoundId = 'sfx.confirm' | 'sfx.cancel' | 'sfx.explosion' | 'sfx.sword' | 'sfx.blunt';
export interface ActionDocument {
  version: 1;
  id: 'rifle';
  cooldown: number;
  damage: number;
  flashDuration: number;
  flashColor: string;
  recoilDuration: number;
  recoilStrength: number;
  shotSound: SoundId;
  hitSound: SoundId;
}
export interface SceneDocument {
  version: 1;
  id: string;
  name: string;
  units: 'meters';
  up: 'Y';
  forward: '+Z';
  assets: { player: 'model.strix'; enemy: 'model.bastion'; bgm: 'bgm.battle' };
  stage: StageDefinition;
  camera: { fov: number };
  lighting: { skyColor: string; sunIntensity: number };
  action: ActionDocument;
  mission: { timeLimit: number; waves: { id: string; targets: string[] }[] };
}
/** Engine-neutral, simulation-owned events. IDs increase within one run; clear consumers on reset. */
export interface GameEvent {
  version: 1;
  id: number;
  time: number;
  kind: 'shot' | 'impact' | 'destroyed' | 'player_hit' | 'lock_ready';
  position: Vec3;
  entityId: string | null;
  weapon: 'rifle' | 'missile' | 'enemy' | null;
}
export interface FramePacket {
  version: 1;
  runId: number;
  tick: number;
  events: GameEvent[];
}
function fail(path: string): never {
  throw Error(`設定が不正です: ${path}`);
}
function object(value: unknown, keys: string[], path: string): Record<string, unknown> {
  if (!value || typeof value !== 'object' || Array.isArray(value)) fail(path);
  const result = value as Record<string, unknown>;
  if (Object.keys(result).some((k) => !keys.includes(k)) || keys.some((k) => !(k in result))) fail(path);
  return result;
}
function number(value: unknown, min: number, max: number, path: string): number {
  if (typeof value !== 'number' || !Number.isFinite(value) || value < min || value > max) fail(path);
  return value;
}
function string(value: unknown, path: string, limit = 80): string {
  if (typeof value !== 'string' || !value.trim() || value.length > limit) fail(path);
  return value;
}
const id = (value: unknown, path: string) => {
  const text = string(value, path, 64);
  if (!/^[\w-]+$/.test(text) || text in Object.prototype || ['spawn', 'player', 'prototype'].includes(text))
    fail(path);
  return text;
};
const color = (value: unknown, path: string) => {
  if (typeof value !== 'string' || !/^#[0-9a-f]{6}$/i.test(value)) fail(path);
};
function array(value: unknown, min: number, max: number, path: string): unknown[] {
  if (!Array.isArray(value) || value.length < min || value.length > max) fail(path);
  return value;
}
function vector(value: unknown, path: string, min = -1000, max = 1000): Vec3 {
  return array(value, 3, 3, path).map((v) => number(v, min, max, path)) as Vec3;
}
const sounds: SoundId[] = ['sfx.confirm', 'sfx.cancel', 'sfx.explosion', 'sfx.sword', 'sfx.blunt'];
export function validateAction(input: unknown): ActionDocument {
  const a = object(
    input,
    [
      'version',
      'id',
      'cooldown',
      'damage',
      'flashDuration',
      'flashColor',
      'recoilDuration',
      'recoilStrength',
      'shotSound',
      'hitSound',
    ],
    'action',
  );
  if (a.version !== 1 || a.id !== 'rifle') fail('action.version/id');
  number(a.cooldown, 0.06, 1, 'cooldown');
  number(a.damage, 1, 180, 'damage');
  number(a.flashDuration, 0.005, 0.15, 'flashDuration');
  number(a.recoilDuration, 0.03, 0.5, 'recoilDuration');
  number(a.recoilStrength, 0, 0.3, 'recoilStrength');
  color(a.flashColor, 'flashColor');
  for (const field of ['shotSound', 'hitSound']) if (!sounds.includes(a[field] as SoundId)) fail(field);
  return structuredClone(input) as ActionDocument;
}
export function validateSceneDocument(input: unknown): SceneDocument {
  const d = object(
    input,
    [
      'version',
      'id',
      'name',
      'units',
      'up',
      'forward',
      'assets',
      'stage',
      'camera',
      'lighting',
      'action',
      'mission',
    ],
    'scene',
  );
  if (d.version !== 1 || d.units !== 'meters' || d.up !== 'Y' || d.forward !== '+Z')
    fail('version / coordinates');
  id(d.id, 'id');
  string(d.name, 'name');
  const assets = object(d.assets, ['player', 'enemy', 'bgm'], 'assets');
  if (assets.player !== 'model.strix' || assets.enemy !== 'model.bastion' || assets.bgm !== 'bgm.battle')
    fail('assets');
  const stage = object(d.stage, ['bounds', 'spawn', 'solids', 'targets'], 'stage');
  const bounds = object(stage.bounds, ['minX', 'maxX', 'minZ', 'maxZ'], 'bounds');
  for (const k of Object.keys(bounds)) number(bounds[k], -100, 100, `bounds.${k}`);
  const b = bounds as StageDefinition['bounds'];
  if (b.maxX - b.minX < 24 || b.maxZ - b.minZ < 24) fail('bounds size');
  const inside = (p: Vec3) =>
    p[0] >= b.minX + 3 && p[0] <= b.maxX - 3 && p[2] >= b.minZ + 3 && p[2] <= b.maxZ - 3;
  const spawn = vector(stage.spawn, 'spawn');
  if (spawn[1] !== 0 || !inside(spawn)) fail('spawn');
  const ids = new Set<string>();
  for (const [i, value] of array(stage.solids, 0, 80, 'solids').entries()) {
    const s = object(value, ['id', 'kind', 'center', 'size', 'color'], `solid ${i}`),
      name = id(s.id, 'solid.id');
    if (ids.has(name)) fail('duplicate solid id');
    ids.add(name);
    if (!['warehouse', 'container', 'barrier', 'tower', 'wall'].includes(s.kind as string))
      fail('solid.kind');
    vector(s.center, 'center');
    vector(s.size, 'size', 0.2, 220);
    color(s.color, 'solid.color');
  }
  const targetIds = new Set<string>(),
    targets = array(stage.targets, 1, 24, 'targets');
  for (const value of targets) {
    const t = object(value, ['id', 'position', 'yaw'], 'target'),
      name = id(t.id, 'target.id'),
      position = vector(t.position, 'target.position');
    if (ids.has(name) || targetIds.has(name)) fail('duplicate target id');
    targetIds.add(name);
    if (position[1] !== 0 || !inside(position)) fail('target bounds');
    number(t.yaw, -Math.PI * 2, Math.PI * 2, 'yaw');
  }
  // Prevent an edited spawn or enemy from being buried inside collision geometry.
  const typedStage = stage as unknown as StageDefinition;
  for (const point of [spawn, ...typedStage.targets.map((t) => t.position)])
    for (const s of typedStage.solids) {
      if (s.center[1] - s.size[1] / 2 >= 6 || s.center[1] + s.size[1] / 2 <= 0) continue;
      if (
        Math.abs(point[0] - s.center[0]) < s.size[0] / 2 + 2.8 &&
        Math.abs(point[2] - s.center[2]) < s.size[2] / 2 + 2.8
      )
        fail('配置が障害物と重なっています');
    }
  const camera = object(d.camera, ['fov'], 'camera');
  number(camera.fov, 40, 85, 'fov');
  const lighting = object(d.lighting, ['skyColor', 'sunIntensity'], 'lighting');
  color(lighting.skyColor, 'skyColor');
  number(lighting.sunIntensity, 0.1, 6, 'sunIntensity');
  validateAction(d.action);
  const mission = object(d.mission, ['timeLimit', 'waves'], 'mission');
  number(mission.timeLimit, 10, 600, 'timeLimit');
  const assigned = new Set<string>(),
    waveIds = new Set<string>();
  for (const value of array(mission.waves, 1, 8, 'waves')) {
    const wave = object(value, ['id', 'targets'], 'wave'),
      name = id(wave.id, 'wave.id');
    if (waveIds.has(name)) fail('duplicate wave');
    waveIds.add(name);
    for (const target of array(wave.targets, 1, 8, 'wave.targets')) {
      if (typeof target !== 'string' || !targetIds.has(target) || assigned.has(target))
        fail('wave target reference');
      assigned.add(target);
    }
  }
  if (assigned.size !== targets.length) fail('unassigned targets');
  return structuredClone(input) as SceneDocument;
}
