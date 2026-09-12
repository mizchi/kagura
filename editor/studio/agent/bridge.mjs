export const AGENT_EVENTS = Object.freeze([
  'prompt',
  'abort',
  'text_delta',
  'tool',
  'tool_result',
  'error',
  'done',
]);

export function catalogAgentEvents() {
  return [...AGENT_EVENTS];
}

function normalize(event) {
  if (event?.type === 'message_update' && event.assistantMessageEvent?.type === 'text_delta') {
    return { type: 'text_delta', delta: event.assistantMessageEvent.delta };
  }
  if (event?.type === 'tool_execution_start') {
    return {
      type: 'tool',
      id: event.toolCallId,
      name: event.toolName,
      args: event.args ?? event.input,
    };
  }
  if (event?.type === 'text_delta' || event?.type === 'tool' || event?.type === 'error') return event;
  return null;
}

/** Drive a coding-agent session and execute editor tools against the live host. */
export async function handleAgentMessage(message, { session, host, emit }) {
  if (message?.type === 'abort') {
    session.abort?.();
    emit({ type: 'done' });
    return;
  }
  if (message?.type !== 'prompt' || typeof message.text !== 'string') {
    emit({ type: 'error', message: 'Unknown agent message' });
    emit({ type: 'done' });
    return;
  }
  const pending = [];
  const unsubscribe = session.subscribe((event) => {
    const normalized = normalize(event);
    if (!normalized) return;
    emit(normalized);
    if (normalized.type !== 'tool') return;
    const execute = host[normalized.name];
    pending.push(
      Promise.resolve()
        .then(() => {
          if (typeof execute !== 'function') throw Error('Unknown editor tool: ' + normalized.name);
          return execute(normalized.args);
        })
        .then((result) => emit({ type: 'tool_result', name: normalized.name, result }))
        .catch((error) => emit({ type: 'error', message: error.message })),
    );
  });
  try {
    await session.prompt(message.text);
    await Promise.all(pending);
  } catch (error) {
    emit({ type: 'error', message: error.message });
  } finally {
    unsubscribe?.();
    emit({ type: 'done' });
  }
}
