import { WebSocketServer } from 'ws';
import { fileURLToPath } from 'node:url';
import { createRpcHost, resolveRpc } from './agent/rpc-host.mjs';
import { runAgentTurn } from './agent/session.mjs';
import { openShell } from './terminal/pty.mjs';
import { encodePtyBytes, readControl, selectGespenstProtocol } from './terminal/protocol.mjs';

const repoRoot = fileURLToPath(new URL('../..', import.meta.url));

export function attachStudioSidecar(httpServer, { cwd = repoRoot } = {}) {
  const ptyServer = new WebSocketServer({ noServer: true, handleProtocols: selectGespenstProtocol });
  const agentServer = new WebSocketServer({ noServer: true });
  function onUpgrade(request, socket, head) {
    const path = request.url?.split('?')[0];
    if (path === '/studio-pty') {
      ptyServer.handleUpgrade(request, socket, head, (ws) => ptyServer.emit('connection', ws));
    } else if (path === '/studio-agent') {
      agentServer.handleUpgrade(request, socket, head, (ws) => agentServer.emit('connection', ws));
    }
  }
  httpServer.on('upgrade', onUpgrade);
  const shells = new Set();
  ptyServer.on('connection', async (ws) => {
    const shell = await openShell({ cwd });
    shells.add(shell);
    const drop = () => {
      shells.delete(shell);
      shell.kill();
    };
    shell.onData((data) => {
      if (ws.readyState === ws.OPEN) ws.send(encodePtyBytes(data), { binary: true });
    });
    ws.on('message', (data, isBinary) => {
      if (!isBinary) {
        const message = readControl(data);
        if (message && (message.type === 'hello' || message.type === 'resize') && message.cols && message.rows) {
          shell.resize(message.cols, message.rows);
        }
        return;
      }
      shell.write(Buffer.isBuffer(data) ? data.toString('utf8') : Buffer.from(data).toString('utf8'));
    });
    ws.on('close', drop);
    ws.on('error', drop);
  });
  agentServer.on('connection', (ws) => {
    const pending = new Map();
    const send = (message) => {
      if (ws.readyState === ws.OPEN) ws.send(JSON.stringify(message));
    };
    const host = createRpcHost(send, pending);
    let busy = false;
    ws.on('message', async (data) => {
      let message;
      try {
        message = JSON.parse(String(data));
      } catch {
        send({ type: 'error', message: 'Invalid agent message' });
        return;
      }
      if (message.type === 'tool_result' || message.error) {
        resolveRpc(pending, message);
        return;
      }
      if (message.type !== 'prompt' || busy) return;
      busy = true;
      try {
        await runAgentTurn(message, { host, emit: send, cwd });
      } finally {
        busy = false;
      }
    });
  });
  return () => {
    httpServer.off('upgrade', onUpgrade);
    for (const shell of shells) shell.kill();
    shells.clear();
    for (const client of ptyServer.clients) client.close();
    for (const client of agentServer.clients) client.close();
    ptyServer.close();
    agentServer.close();
  };
}

function attachWhenListening(server) {
  return () => {
    if (!server.httpServer) return;
    const stop = attachStudioSidecar(server.httpServer);
    server.httpServer.on('close', stop);
  };
}

export function studioSidecarPlugin() {
  return {
    name: 'kagura-studio-sidecar',
    configureServer(server) {
      return attachWhenListening(server);
    },
    configurePreviewServer(server) {
      return attachWhenListening(server);
    },
  };
}
