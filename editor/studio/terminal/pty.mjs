import { spawn } from 'node:child_process';
import os from 'node:os';

export async function openShell({ cwd, cols = 80, rows = 24 } = {}) {
  const shell = process.env.SHELL || (os.platform() === 'win32' ? 'powershell.exe' : '/bin/zsh');
  try {
    const pty = await import('node-pty');
    const spawnPty = pty.default?.spawn ?? pty.spawn;
    const term = spawnPty(shell, [], {
      name: 'xterm-256color',
      cols,
      rows,
      cwd,
      env: process.env,
    });
    return {
      onData: (listener) => term.onData(listener),
      write: (data) => term.write(data),
      resize: (nextCols, nextRows) => term.resize(nextCols, nextRows),
      kill: () => {
        try {
          term.kill();
        } catch {
          /* Already exited. */
        }
      },
    };
  } catch {
    const child = spawn(shell, ['-i'], {
      cwd,
      env: { ...process.env, TERM: 'xterm-256color' },
      stdio: ['pipe', 'pipe', 'pipe'],
    });
    return {
      onData: (listener) => {
        child.stdout.on('data', listener);
        child.stderr.on('data', listener);
      },
      write: (data) => child.stdin.write(data),
      resize() {},
      kill: () => {
        child.kill('SIGKILL');
      },
    };
  }
}
