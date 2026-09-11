import { createHeadlessRequest } from '../assets/web/kagura-headless-frame.js';

export function validateTransition(spec) {
  if (!spec || !Number.isInteger(spec.frames) || spec.frames < 3 || spec.frames > 600 ||
      !Number.isInteger(spec.settleFrame) || spec.settleFrame < 2 || spec.settleFrame >= spec.frames ||
      !Array.isArray(spec.inputs) || spec.inputs.length > spec.frames) {
    throw Error('Transition needs 3..600 frames, a settleFrame before the final frame and an input sequence');
  }
  createHeadlessRequest({ inputs: spec.inputs });
  return spec;
}

/** Each entry compares frame i+1 with i+2. Capture every tick, not just endpoints. */
export function analyzeTransition(spec, changedPixels) {
  validateTransition(spec);
  if (changedPixels.length !== spec.frames - 1 || changedPixels.some(n => !Number.isInteger(n) || n < 0)) {
    throw Error('Missing transition pixel measurement');
  }
  const findings = [];
  if (!changedPixels.slice(0, spec.settleFrame - 1).some(n => n > 0)) {
    findings.push({ kind: 'no-motion', detail: 'No pixel changed before the settling deadline' });
  }
  changedPixels.forEach((pixels, i) => {
    if (i + 1 >= spec.settleFrame && pixels > 0) findings.push({
      kind: 'not-settled', frame: i + 2, detail: `${pixels} pixels changed after frame ${spec.settleFrame}`,
    });
  });
  return findings;
}
