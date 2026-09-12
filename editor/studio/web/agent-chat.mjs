import { createEditorTools } from '../agent/tools.mjs';

function kaguraHost(kagura) {
  return {
    snapshot: () => kagura.snapshot(),
    dispatch: (transaction) => {
      const reply = kagura.dispatch(transaction);
      if (reply && reply.ok === false) throw Error(reply.error?.message ?? 'Dispatch failed');
      return reply;
    },
    select: (id) => kagura.select(id),
    selectScene: (id) => kagura.selectScene(id),
    graph: () => kagura.graph(),
    runtime: kagura.runtime,
  };
}

function line(kind, text) {
  const row = document.createElement('p');
  row.className = 'agent-line agent-line-' + kind;
  row.textContent = text;
  return row;
}

export function agentChatPane(kagura) {
  return {
    id: 'studio.agent',
    title: 'Agent',
    workspace: true,
    mount({ element, signal }) {
      element.classList.add('studio-agent-pane');
      const status = document.createElement('p');
      status.className = 'agent-status';
      status.textContent = 'Connecting…';
      const log = document.createElement('div');
      log.className = 'agent-log';
      log.setAttribute('aria-label', 'Agent transcript');
      const empty = document.createElement('p');
      empty.className = 'agent-empty';
      empty.textContent = 'Ask to inspect, rename, or switch scenes.';
      log.append(empty);
      const form = document.createElement('form');
      form.className = 'agent-compose';
      const input = document.createElement('textarea');
      input.setAttribute('aria-label', 'Agent message');
      input.placeholder = 'Message';
      input.rows = 2;
      const send = document.createElement('button');
      send.type = 'submit';
      send.textContent = 'Send';
      send.className = 'primary';
      form.append(input, send);
      element.append(status, log, form);
      const tools = createEditorTools(kaguraHost(kagura));
      const url = `${location.protocol === 'https:' ? 'wss' : 'ws'}://${location.host}/studio-agent`;
      let socket;
      try {
        socket = new WebSocket(url);
      } catch (error) {
        log.append(line('error', error.message));
        return;
      }
      socket.addEventListener('open', () => { status.textContent = 'Connected'; }, { signal });
      socket.addEventListener('close', () => { status.textContent = 'Disconnected'; }, { signal });
      socket.addEventListener(
        'message',
        async (event) => {
          const message = JSON.parse(typeof event.data === 'string' ? event.data : await event.data.text());
          if (message.type === 'text_delta') {
            const last = log.lastElementChild;
            if (last?.classList.contains('agent-line-assistant')) last.textContent += message.delta;
            else log.append(line('assistant', message.delta));
          } else if (message.type === 'tool') {
            log.append(line('tool', message.name));
          } else if (message.type === 'tool_call') {
            log.append(line('tool', message.name));
            const tool = tools.find((entry) => entry.name === message.name);
            try {
              if (!tool) throw Error('Unknown editor tool: ' + message.name);
              const result = await tool.execute(message.args ?? {});
              socket.send(JSON.stringify({ type: 'tool_result', id: message.id, result: result.details }));
            } catch (error) {
              socket.send(
                JSON.stringify({ type: 'tool_result', id: message.id, error: error.message }),
              );
              log.append(line('error', error.message));
            }
          } else if (message.type === 'error') log.append(line('error', message.message));
          else if (message.type === 'done') send.disabled = false;
          log.scrollTop = log.scrollHeight;
        },
        { signal },
      );
      form.addEventListener(
        'submit',
        (event) => {
          event.preventDefault();
          const text = input.value.trim();
          if (!text || socket.readyState !== WebSocket.OPEN) return;
          empty.remove();
          log.append(line('user', text));
          send.disabled = true;
          socket.send(JSON.stringify({ type: 'prompt', text }));
          input.value = '';
        },
        { signal },
      );
      signal.addEventListener('abort', () => socket.close(), { once: true });
    },
  };
}
