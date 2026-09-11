import * as game from '../_build/js/release/build/mizchi/iron_yard/headless/headless.js';
import { validateSettings } from './contract.mjs';
import { runtimeRecipe } from './scene/runtime.mjs';
import { defaultScene } from './scene/document.ts';
import { validateAction } from './scene/contracts.ts';

export function simulateScene(document, { frames, forward = 0, boost = false, ai = false, fire = false }) {
  if (
    !Number.isInteger(frames) ||
    frames < 0 ||
    frames > 36000 ||
    !Number.isFinite(forward) ||
    Math.abs(forward) > 1 ||
    [boost, ai, fire].some((v) => typeof v !== 'boolean')
  )
    throw Error('Invalid simulation input');
  const instance = game.create_scene(JSON.stringify(runtimeRecipe(document)), ai);
  game.start_playing(instance);
  for (let i = 0; i < frames; i++)
    game.step(instance, forward, 0, boost, false, fire, false, 0, 0.25, 1 / 60);
  return JSON.parse(game.snapshot(instance));
}

export function replayAttack(action, time) {
  if (!Number.isFinite(time) || time < 0 || time > 1.5) throw Error('Attack time must be in [0, 1.5]');
  const doc = defaultScene();
  doc.action = validateAction(action);
  doc.stage.solids = [];
  doc.stage.spawn = [0, 0, 0];
  doc.stage.targets = [{ id: 'preview', position: [0, 0, 16], yaw: Math.PI }];
  doc.mission.waves = [{ id: 'preview-wave', targets: ['preview'] }];
  return JSON.parse(game.replay_attack(JSON.stringify(runtimeRecipe(doc)), time));
}

/** Each call owns its simulation. No live browser state or document mutation. */
export function simulate(settings, { frames, forward, boost }) {
  const config = validateSettings(settings);
  if (
    !Number.isInteger(frames) ||
    frames < 0 ||
    frames > 600 ||
    !Number.isFinite(forward) ||
    Math.abs(forward) > 1 ||
    typeof boost !== 'boolean'
  )
    throw Error('Invalid simulation input');
  const instance = game.create_configured(config.ai, config.spawnX, config.spawnZ, config.yaw);
  game.start_playing(instance);
  for (let i = 0; i < frames; i++)
    game.step(instance, forward, 0, boost, false, false, false, config.yaw, 0.25, 1 / 60);
  return JSON.parse(game.snapshot(instance));
}
