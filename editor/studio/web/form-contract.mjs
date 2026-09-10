export const FORM_KIND = 'kagura.form-pane';
export const validId = value => typeof value === 'string' && /^[a-zA-Z0-9_.-]{1,80}$/.test(value);
const object = value => value !== null && typeof value === 'object' && !Array.isArray(value);
function check(condition, message) { if (!condition) throw new Error(message); }
function exact(value, keys) { check(object(value) && Object.keys(value).every(k => keys.includes(k)), 'Unexpected form property'); }

/** JSON-only descriptors are portable; executable mounts remain local trusted code. */
export function validateForm(definition) {
  exact(definition, ['id', 'gameId', 'title', 'fields', 'values']);
  check(validId(definition.id) && validId(definition.gameId), 'Invalid form or game ID');
  check(typeof definition.title === 'string' && definition.title.trim() && definition.title.length <= 120, 'Invalid pane title');
  check(Array.isArray(definition.fields) && definition.fields.length <= 64, 'Expected up to 64 fields');
  check(object(definition.values), 'Expected form values');
  const keys = new Set();
  for (const field of definition.fields) {
    exact(field, ['key', 'label', 'type', 'min', 'max', 'step', 'options']);
    check(validId(field.key) && !['__proto__', 'constructor', 'prototype'].includes(field.key) && !keys.has(field.key), 'Invalid or duplicate field key');
    keys.add(field.key);
    check(typeof field.label === 'string' && field.label.trim() && field.label.length <= 120, 'Invalid field label');
    check(['text', 'number', 'boolean', 'select'].includes(field.type), 'Unknown field type');
    exact(field, ['key', 'label', 'type', ...(field.type === 'number' ? ['min', 'max', 'step'] : field.type === 'select' ? ['options'] : [])]);
    if (field.type === 'number') {
      for (const key of ['min', 'max', 'step']) check(field[key] === undefined || Number.isFinite(field[key]), 'Invalid number constraint');
      check((field.min ?? -Infinity) <= (field.max ?? Infinity) && (field.step ?? 1) > 0, 'Invalid number range');
    }
    if (field.type === 'select') check(Array.isArray(field.options) && field.options.length > 0 && field.options.length <= 100 && field.options.every(o => typeof o === 'string'), 'Expected select options');
    check(validValue(field, definition.values[field.key]), 'Invalid value for ' + field.key);
  }
  check(Object.keys(definition.values).every(key => keys.has(key)), 'Unknown form value');
  return structuredClone(definition);
}
export function validValue(field, value) {
  switch (field.type) {
    case 'text': return typeof value === 'string' && value.length <= 4096;
    case 'boolean': return typeof value === 'boolean';
    case 'number': return Number.isFinite(value) && value >= (field.min ?? -Infinity) && value <= (field.max ?? Infinity);
    case 'select': return field.options.includes(value);
    default: return false;
  }
}
export const exampleForm = {
  id: 'mission.settings', gameId: 'my-game', title: 'Mission settings',
  fields: [
    { key: 'name', label: 'Mission name', type: 'text' },
    { key: 'enemies', label: 'Enemy count', type: 'number', min: 0, max: 1000, step: 1 },
    { key: 'friendlyFire', label: 'Friendly fire', type: 'boolean' },
    { key: 'difficulty', label: 'Difficulty', type: 'select', options: ['easy', 'normal', 'hard'] },
  ],
  values: { name: 'First mission', enemies: 5, friendlyFire: false, difficulty: 'normal' },
};
