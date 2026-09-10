// JSON Schema contracts for browser agents. MoonBit remains authoritative for domain invariants.
export const record = (properties, required = Object.keys(properties)) => ({ type: 'object', properties, required, additionalProperties: false });
const text = { type: 'string' };
const id = { type: 'string', pattern: '^[a-zA-Z0-9_.-]{1,80}$' };
export const revision = { type: 'integer', minimum: 0, maximum: 2147483647 };
const number = { type: 'number' };
const vector = { type: 'array', items: number, minItems: 3, maxItems: 3 };
const asset = { type: 'string', enum: ['primitive.box', 'primitive.sphere', 'primitive.cylinder', 'group'] };
const color = { type: 'integer', minimum: 0, maximum: 16777215 };
const action = record({ target: text, duration: number, flashDuration: number, recoilDuration: number, recoilStrength: number });
const resource = record({ id, kind: id, version: { ...revision, minimum: 1 }, data: { type: 'object', additionalProperties: true } });
const documentSchema = record({ version: { const: 1 }, name: text, units: { const: 'meters' }, up: { const: 'Y' }, forward: { const: '+Z' },
  nodes: { type: 'array', maxItems: 2000, items: record({ id, name: text, asset, parent: text, position: vector, rotation: vector, scale: vector, color }) },
  action, resources: { type: 'array', maxItems: 128, items: resource },
}, ['version', 'name', 'units', 'up', 'forward', 'nodes', 'action']);
const command = (op, properties, required) => record({ op: { const: op }, ...properties }, ['op', ...(required ?? Object.keys(properties))]);
export const transactionSchema = record({ expectedRevision: revision, commands: { type: 'array', minItems: 1, maxItems: 100, items: { oneOf: [
  command('node.add', { id, name: text, asset, parent: text }, ['id', 'name', 'asset']),
  command('node.remove', { id }), command('node.rename', { id, name: text }),
  command('node.reparent', { id, parent: text }), command('node.material', { id, color }),
  command('node.transform', { id, position: vector, rotation: vector, scale: vector }),
  command('action.set', { action }), command('document.replace', { document: documentSchema }),
  command('resource.put', { resource }), command('resource.remove', { id }),
] } } });
const baseField = { key: id, label: text };
export const formSchema = record({ id, gameId: id, title: { type: 'string', minLength: 1, maxLength: 120 },
  fields: { type: 'array', maxItems: 64, items: { oneOf: [
    record({ ...baseField, type: { enum: ['text', 'boolean'] } }),
    record({ ...baseField, type: { const: 'number' }, min: number, max: number, step: { type: 'number', exclusiveMinimum: 0 } }, ['key', 'label', 'type']),
    record({ ...baseField, type: { const: 'select' }, options: { type: 'array', minItems: 1, maxItems: 100, items: text } }),
  ] } }, values: { type: 'object', additionalProperties: { type: ['string', 'number', 'boolean'] } },
});
