import Ajv from 'ajv';
export const ABI_VERSION = 1;
export const MAX_MESSAGE_BYTES = 4 * 1024 * 1024;
export class PluginError extends Error {
  constructor(code, message) { super(message); this.code = code; }
}
export function check(condition, message, code = 'invalid') { if (!condition) throw new PluginError(code, message); }
export function deepFreeze(value) {
  if (value && typeof value === 'object' && !Object.isFrozen(value)) {
    for (const child of Object.values(value)) deepFreeze(child);
    Object.freeze(value);
  }
  return value;
}
function object(value) { return value !== null && typeof value === 'object' && !Array.isArray(value); }
export function exact(value, allowed) { check(object(value) && Object.keys(value).every(key => allowed.includes(key)), 'Unexpected contract field'); }
export function encodeJSON(value) {
  const seen = new Set();
  function visit(item, depth) {
    check(depth <= 64, 'Plugin message nesting limit');
    if (item === null || typeof item === 'string' || typeof item === 'boolean') return;
    if (typeof item === 'number') { check(Number.isFinite(item), 'Expected finite JSON number'); return; }
    check(typeof item === 'object' && !seen.has(item), 'Expected acyclic JSON data');
    check(Array.isArray(item) || Object.getPrototypeOf(item) === Object.prototype || Object.getPrototypeOf(item) === null, 'Expected plain JSON data');
    seen.add(item); for (const child of Object.values(item)) visit(child, depth + 1); seen.delete(item);
  }
  visit(value, 0);
  const text = JSON.stringify(value);
  check(new TextEncoder().encode(text).length <= MAX_MESSAGE_BYTES, 'Plugin message exceeds 4 MiB');
  return text;
}
export function decodeJSON(source) {
  check(typeof source === 'string' && new TextEncoder().encode(source).length <= MAX_MESSAGE_BYTES, 'Invalid JSON transport message');
  const value = JSON.parse(source); encodeJSON(value); return value;
}
export function prepareManifest(source) {
  const manifest = decodeJSON(encodeJSON(source));
  exact(manifest, ['apiVersion', 'id', 'title', 'tools']);
  check(manifest.apiVersion === ABI_VERSION, 'Unsupported plugin API version');
  check(typeof manifest.id === 'string' && /^[a-zA-Z0-9_.-]{1,80}$/.test(manifest.id) && !['console', 'creator'].includes(manifest.id) && !manifest.id.startsWith('form.'), 'Invalid or reserved pane ID');
  check(typeof manifest.title === 'string' && manifest.title.trim() && manifest.title.length <= 120, 'Invalid pane title');
  check(Array.isArray(manifest.tools) && manifest.tools.length <= 32, 'Expected up to 32 tools');
  // One validator scope per registration prevents schema IDs leaking across plugins.
  const ajv = new Ajv({ strict: true, allErrors: false, addUsedSchema: false });
  const names = new Set(), validators = new Map();
  for (const tool of manifest.tools) {
    exact(tool, ['name', 'description', 'effect', 'inputSchema', 'outputSchema']);
    check(typeof tool.name === 'string' && /^[a-zA-Z0-9_-]{1,32}$/.test(tool.name) && !names.has(tool.name), 'Invalid or duplicate tool name'); names.add(tool.name);
    check(typeof tool.description === 'string' && tool.description.trim() && tool.description.length <= 1000, 'Expected tool description');
    check(['read', 'transaction'].includes(tool.effect), 'Expected read or transaction effect');
    check(object(tool.inputSchema) && tool.inputSchema.type === 'object', 'Tool inputSchema must describe an object');
    const input = ajv.compile(tool.inputSchema), output = tool.outputSchema === undefined ? null : ajv.compile(tool.outputSchema);
    check(!input.$async && !output?.$async, 'Async schemas are unsupported');
    validators.set(tool.name, { input, output });
  }
  return { manifest: deepFreeze(manifest), validators };
}
