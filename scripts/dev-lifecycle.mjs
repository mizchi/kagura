/** Keep signal ownership with the CLI and await the server/watchers' cleanup. */
export function closeOnSignal(close) {
  let stopping = false;
  const handlers = new Map();
  for (const [signal, code] of [['SIGINT', 130], ['SIGTERM', 143]]) {
    const handler = async () => {
      if (stopping) return;
      stopping = true;
      process.exitCode = code;
      try { await close(); }
      catch (error) { console.error(error.message); process.exitCode = 1; }
      finally { dispose(); }
    };
    handlers.set(signal, handler);
    process.on(signal, handler);
  }
  function dispose() {
    for (const [signal, handler] of handlers) process.off(signal, handler);
  }
  return dispose;
}
