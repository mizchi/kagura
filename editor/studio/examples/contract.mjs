// Pure authoring contract: UI, WebMCP and headless use the same resource transactions.
export const launchId = 'kagura.example';
export function validateLaunch(input) {
  if (
    !input ||
    Object.keys(input).some((k) => !['example', 'query'].includes(k)) ||
    typeof input.example !== 'string' ||
    !/^[a-z][a-z0-9_]{0,79}$/.test(input.example) ||
    !input.query ||
    typeof input.query !== 'object' ||
    Array.isArray(input.query) ||
    Object.keys(input.query).length > 64
  )
    throw Error('Invalid example launch settings');
  for (const [key, value] of Object.entries(input.query)) {
    if (
      !/^[a-z][a-z0-9_]{0,79}$/.test(key) ||
      !(
        typeof value === 'boolean' ||
        (typeof value === 'number' && Number.isFinite(value)) ||
        (typeof value === 'string' && value.length <= 2048)
      )
    )
      throw Error('Invalid launch parameter: ' + key);
  }
  return structuredClone(input);
}
export function readLaunch(snapshot) {
  const resource = snapshot.document.resources.find((r) => r.id === launchId);
  if (resource?.kind !== launchId || resource?.version !== 1)
    throw Error('Missing example launch resource');
  return validateLaunch(resource.data);
}
export function launchCommand(input) {
  return {
    op: 'resource.put',
    resource: { id: launchId, kind: launchId, version: 1, data: validateLaunch(input) },
  };
}
export async function invokeLaunch(tool, args, snapshot) {
  const config = readLaunch(snapshot);
  if (tool === 'launch_read') return { result: config };
  if (tool !== 'launch_update') throw Error('Unknown example tool');
  const next = validateLaunch({ ...config, query: args.query });
  return { result: next, commands: [launchCommand(next)] };
}
export const launchTools = [
  {
    name: 'launch_read',
    description: 'Read example launch settings.',
    effect: 'read',
    inputSchema: { type: 'object', properties: {}, additionalProperties: false },
  },
  {
    name: 'launch_update',
    description:
      'Replace URL parameters consumed by this example. Takes effect on next Play. Does not convert generic nodes into a game level.',
    effect: 'transaction',
    inputSchema: {
      type: 'object',
      properties: {
        query: {
          type: 'object',
          maxProperties: 64,
          additionalProperties: {
            anyOf: [{ type: 'string' }, { type: 'number' }, { type: 'boolean' }],
          },
        },
      },
      required: ['query'],
      additionalProperties: false,
    },
  },
];
