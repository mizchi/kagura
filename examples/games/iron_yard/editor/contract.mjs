/** Portable authoring contract. Spawn coordinates stay inside the unobstructed deployment area. */
export const defaultSettings = Object.freeze({ ai: true, spawnX: 0, spawnZ: -36, yaw: 0 });
export const settingsSchema = {
  type: 'object', additionalProperties: false, required: Object.keys(defaultSettings),
  properties: {
    ai: { type: 'boolean' },
    spawnX: { type: 'number', minimum: -10, maximum: 10 },
    spawnZ: { type: 'number', minimum: -52, maximum: -35 },
    yaw: { type: 'number', minimum: -Math.PI, maximum: Math.PI },
  },
};
export function validateSettings(value) {
  if (!value || typeof value !== 'object' || Array.isArray(value) || Object.keys(value).length !== 4) throw Error('Invalid IRON YARD settings');
  for (const [key, rule] of Object.entries(settingsSchema.properties)) {
    if (typeof value[key] !== rule.type || rule.type === 'number' && (!Number.isFinite(value[key]) || value[key] < rule.minimum || value[key] > rule.maximum)) throw Error('Invalid IRON YARD setting: ' + key);
  }
  return { ai: value.ai, spawnX: value.spawnX, spawnZ: value.spawnZ, yaw: value.yaw };
}
