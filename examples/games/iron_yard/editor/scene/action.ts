// Ported from mizchi/modeling-playground game/studio; scene-editor.html v1 contract.
import type { ActionDocument } from './contracts.ts';
export const DEFAULT_ACTION: ActionDocument = {
  version: 1,
  id: 'rifle',
  cooldown: 0.12,
  damage: 12,
  flashDuration: 0.035,
  flashColor: '#fff2bf',
  recoilDuration: 0.11,
  recoilStrength: 0.075,
  shotSound: 'sfx.blunt',
  hitSound: 'sfx.sword',
};
/** Sampling is side-effect free: editor scrubbing never fires a projectile or plays audio. */
export function sampleAction(action: ActionDocument, age: number) {
  return {
    flash: age >= 0 && age < action.flashDuration,
    recoil:
      age < 0 || age >= action.recoilDuration
        ? 0
        : action.recoilStrength *
          Math.sin((Math.PI * age) / action.recoilDuration) *
          Math.exp((-3 * age) / action.recoilDuration),
  };
}
