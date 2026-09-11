import { defineJSPlugin } from '../../../../../editor/studio/plugins/adapters.mjs';
import { defaultSettings, settingsSchema, validateSettings } from '../contract.mjs';
import { sceneTools, invokeScene, readScene, sceneId } from './scene-plugin.mjs';
export { defaultSettings };
export const settingsId = 'iron-yard.settings';
export const previewId = 'iron-yard.preview';
const object = (properties) => ({
  type: 'object',
  properties,
  required: Object.keys(properties),
  additionalProperties: false,
});

export function readSettings(snapshot) {
  const resource = snapshot.document.resources.find((r) => r.id === settingsId);
  if (!resource) return { ...defaultSettings };
  if (resource.kind !== settingsId || resource.version !== 1)
    throw Error('Unsupported IRON YARD settings kind/version');
  return validateSettings(resource.data);
}
export async function simulate(settings, input) {
  const runtime = await import('../headless.mjs');
  return runtime.simulate(settings, input);
}
export function createIronYardPlugin({ mount, inspect, sessionId, dispose } = {}) {
  return defineJSPlugin({
    manifest: {
      apiVersion: 1,
      id: 'iron-yard',
      title: 'IRON YARD',
      tools: [
        ...sceneTools,
        {
          name: 'inspect',
          description: 'Read the saved IRON YARD scene, settings and current preview status.',
          effect: 'read',
          inputSchema: object({}),
        },
        {
          name: 'configure',
          description:
            'Save trial AI mode and legacy deployment settings. An authored scene takes precedence for spawn; use scene_edit to change its positions.',
          effect: 'transaction',
          inputSchema: settingsSchema,
        },
        {
          name: 'preview',
          description:
            'Play, pause or reset the browser game preview. Headless hosts record the request without launching a renderer.',
          effect: 'transaction',
          inputSchema: object({ action: { enum: ['play', 'pause', 'reset'] } }),
        },
        {
          name: 'simulate',
          description:
            'Run an isolated headless simulation at 60 Hz using the saved scene and AI mode, or legacy settings when no scene exists (up to 600 frames).',
          effect: 'read',
          inputSchema: object({
            frames: { type: 'integer', minimum: 0, maximum: 600 },
            forward: { type: 'number', minimum: -1, maximum: 1 },
            boost: { type: 'boolean' },
          }),
        },
      ],
    },
    mount,
    dispose,
    async invoke({ tool, arguments: args, snapshot }) {
      if (sceneTools.some((t) => t.name === tool)) return invokeScene(tool, args, snapshot);
      if (tool === 'inspect')
        return {
          result: {
            settings: readSettings(snapshot),
            scene: snapshot.document.resources.some((r) => r.id === sceneId) ? readScene(snapshot) : null,
            preview: inspect?.() ?? null,
          },
        };
      if (tool === 'simulate') {
        if (snapshot.document.resources.some((r) => r.id === sceneId)) {
          const { simulateScene } = await import('../headless.mjs');
          return { result: simulateScene(readScene(snapshot), { ...args, ai: readSettings(snapshot).ai }) };
        }
        return { result: await simulate(readSettings(snapshot), args) };
      }
      if (tool === 'configure') {
        const settings = validateSettings(args);
        return {
          result: settings,
          commands: [
            {
              op: 'resource.put',
              resource: { id: settingsId, kind: settingsId, version: 1, data: settings },
            },
          ],
        };
      }
      if (tool === 'preview')
        return {
          result: args,
          commands: [
            {
              op: 'resource.put',
              resource: { id: settingsId, kind: settingsId, version: 1, data: readSettings(snapshot) },
            },
            {
              op: 'resource.put',
              resource: {
                id: previewId,
                kind: previewId,
                version: 1,
                data: {
                  action: args.action,
                  token: snapshot.revision + 1,
                  ...(sessionId ? { session: sessionId } : {}),
                },
              },
            },
          ],
        };
      throw Error('Unknown IRON YARD tool');
    },
  });
}
