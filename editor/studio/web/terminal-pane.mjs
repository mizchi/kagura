export function terminalPane() {
  return {
    id: 'studio.terminal',
    title: 'Terminal',
    workspace: true,
    mount({ element, signal }) {
      element.classList.add('studio-terminal-pane');
      const host = document.createElement('div');
      host.className = 'studio-terminal';
      host.setAttribute('aria-label', 'Terminal');
      const note = document.createElement('p');
      note.className = 'muted';
      note.textContent = 'Connecting Ghostty…';
      element.append(note, host);
      let terminal;
      (async () => {
        const [{ createTerminal }, { WebSocketAddon }] = await Promise.all([
          import('@gespenst/core'),
          import('@gespenst/websocket'),
        ]);
        await import('@gespenst/core/style.css');
        terminal = await createTerminal({
          container: host,
          worker: 'dedicated',
          fontFamily: 'ui-monospace, SFMono-Regular, Menlo, monospace',
          renderer: 'canvas2d',
        });
        terminal.fit();
        const socket = new WebSocketAddon(
          `${location.protocol === 'https:' ? 'wss' : 'ws'}://${location.host}/studio-pty`,
          { reconnect: { maxAttempts: 8 } },
        );
        socket.onStatusChange((status) => {
          note.textContent = status === 'connected' ? 'Ghostty · PTY' : 'Ghostty · ' + status;
        });
        terminal.loadAddon(socket);
        await socket.ready;
        terminal.fit();
      })().catch(async (error) => {
        note.textContent = 'PTY unavailable · ' + error.message;
        try {
          const { createTerminal } = await import('@gespenst/core');
          const { BrowserShellAddon } = await import('@gespenst/shell');
          host.replaceChildren();
          terminal = await createTerminal({
            container: host,
            worker: false,
            renderer: 'canvas2d',
          });
          const shell = new BrowserShellAddon({
            bashkit: { bash: { cwd: '/studio', files: { '/studio/README.md': 'Kagura Studio\n' } } },
          });
          terminal.loadAddon(shell);
          note.textContent = 'Terminal · browser shell (no OS PTY)';
        } catch (fallback) {
          note.textContent = 'Terminal unavailable · ' + fallback.message;
        }
      });
      signal.addEventListener(
        'abort',
        () => {
          try {
            terminal?.dispose?.();
          } catch {
            /* Gespenst dispose is best-effort when the pane unmounts. */
          }
        },
        { once: true },
      );
    },
  };
}
