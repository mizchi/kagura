import { createEditorTools } from './tools.mjs';
import { handleAgentMessage } from './bridge.mjs';
import { editorTurnContext, formatEditorTurn } from './context.mjs';

function unavailableSession(reason) {
  return {
    subscribe(listener) {
      this.listener = listener;
      return () => {
        this.listener = undefined;
      };
    },
    async prompt() {
      this.listener?.({ type: 'text_delta', delta: reason });
    },
  };
}

async function createPiSession(host, cwd) {
  const mod = await import('@mariozechner/pi-coding-agent');
  const { Type } = await import('typebox');
  const Any = Type.Object({}, { additionalProperties: true });
  const Id = Type.Object({ id: Type.String() });
  const schemas = {
    editor_snapshot: Type.Object({}),
    editor_dispatch: Type.Object({
      expectedRevision: Type.Number(),
      commands: Type.Array(Any),
    }),
    editor_select: Id,
    select_scene: Id,
    scene_graph: Type.Object({}),
    runtime_inspect: Type.Object({}),
    runtime_pause: Type.Object({}),
    runtime_edit: Type.Object({
      subject: Type.String(),
      field: Type.String(),
      value: Type.Union([Type.Number(), Type.String(), Type.Boolean()]),
      session: Type.String(),
      revision: Type.Number(),
    }),
  };
  const customTools = createEditorTools(host).map((tool) =>
    mod.defineTool({
      name: tool.name,
      label: tool.name,
      description: tool.description,
      parameters: schemas[tool.name] ?? Any,
      execute: async (_id, params) => tool.execute(params),
    }),
  );
  const { session } = await mod.createAgentSession({
    cwd,
    tools: ['read', 'grep', 'find', 'ls'],
    customTools,
    sessionManager: mod.SessionManager.inMemory(),
  });
  return session;
}

export async function runAgentTurn(message, { host, emit, cwd, createSession }) {
  let session;
  try {
    session = await (createSession ?? createPiSession)(host, cwd);
  } catch (error) {
    session = unavailableSession(
      'Coding agent is not configured (' +
        error.message +
        '). Set ANTHROPIC_API_KEY or ~/.pi/agent/auth.json.',
    );
  }
  if (message?.type === 'prompt' && typeof message.text === 'string') {
    try {
      message = { ...message, text: formatEditorTurn(message.text, editorTurnContext(host)) };
    } catch {
      /* A host without snapshot still receives the raw prompt. */
    }
  }
  const tools = Object.fromEntries(
    createEditorTools(host).map((tool) => [
      tool.name,
      async (args) => {
        const result = await tool.execute(args);
        return result.details;
      },
    ]),
  );
  await handleAgentMessage(message, { session, host: tools, emit });
}
