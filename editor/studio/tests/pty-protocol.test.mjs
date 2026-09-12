import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createServer } from 'node:http';
import { WebSocket } from 'ws';
import { attachStudioSidecar } from '../sidecar.mjs';
import { encodePtyBytes, isPtyControl } from '../terminal/protocol.mjs';

test('pty output is always a binary buffer, never a JSON text frame', () => {
  const bytes = encodePtyBytes('kagura % ');
  assert.equal(Buffer.isBuffer(bytes), true);
  assert.equal(bytes.toString('utf8'), 'kagura % ');
  assert.equal(isPtyControl({ type: 'hello', version: 1, cols: 80, rows: 24 }), true);
  assert.equal(isPtyControl({ type: 'resize', cols: 40, rows: 12 }), true);
  assert.equal(isPtyControl('kagura % '), false);
});

test('studio pty websocket accepts gespenst.v1 and replies with binary PTY bytes', { timeout: 8000 }, async () => {
  const server = createServer();
  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  const stop = attachStudioSidecar(server, { cwd: process.cwd() });
  const { port } = server.address();
  const ws = new WebSocket(`ws://127.0.0.1:${port}/studio-pty`, 'gespenst.v1');
  ws.binaryType = 'arraybuffer';
  try {
    await new Promise((resolve, reject) => {
      ws.once('open', resolve);
      ws.once('error', reject);
      setTimeout(() => reject(Error('PTY websocket did not open')), 3000);
    });
    assert.equal(ws.protocol, 'gespenst.v1');
    const first = new Promise((resolve, reject) => {
      const timer = setTimeout(() => reject(Error('No PTY output')), 4000);
      ws.on('message', (data, isBinary) => {
        if (!isBinary && typeof data === 'string') {
          clearTimeout(timer);
          reject(Error('PTY sent a text frame: ' + data.slice(0, 80)));
          return;
        }
        clearTimeout(timer);
        resolve(Buffer.from(data));
      });
    });
    ws.send(JSON.stringify({ type: 'hello', version: 1, cols: 80, rows: 24 }));
    const output = await first;
    assert.ok(output.byteLength > 0, 'expected shell output');
  } finally {
    ws.close();
    stop();
    await new Promise((resolve) => server.close(resolve));
  }
});
