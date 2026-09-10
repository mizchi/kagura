/** Parent-owned publication. Each plugin generation has its own registration lifetime. */
export function publishPaneTools(panes, modelContext, parentSignal) {
  const published = new Map(), errors = new Map();
  const lifetime = new AbortController();
  const hostSignal = AbortSignal.any([lifetime.signal, parentSignal]);
  let queue = Promise.resolve();
  async function sync() {
    if (hostSignal.aborted) return;
    const wanted = new Map(panes.tools().map(tool => [tool.name, tool]));
    for (const [name, entry] of published) if (wanted.get(name) !== entry.definition) {
      entry.controller.abort(); published.delete(name); errors.delete(name);
    }
    for (const [name, definition] of wanted) {
      if (hostSignal.aborted) return;
      if (published.get(name)?.definition === definition) continue;
      const controller = new AbortController(), signal = AbortSignal.any([controller.signal, hostSignal]);
      try {
        await modelContext.registerTool({ ...definition, execute(input, options = {}) {
          const executionSignal = options.signal ? AbortSignal.any([signal, options.signal]) : signal;
          return definition.execute(input, { signal: executionSignal });
        } }, { signal });
        if (signal.aborted || !panes.tools().includes(definition)) { controller.abort(); continue; }
        published.set(name, { controller, definition }); errors.delete(name);
      } catch (error) { controller.abort(); if (!hostSignal.aborted) errors.set(name, error.message); }
    }
    for (const name of errors.keys()) if (!wanted.has(name)) errors.delete(name);
  }
  function schedule() { queue = queue.then(sync); return queue; }
  const unsubscribe = panes.subscribeTools(schedule);
  schedule();
  return Object.freeze({
    settled: () => queue,
    status: () => ({ tools: [...published.keys()], errors: [...errors].map(([name, message]) => ({ name, message })) }),
    dispose() { lifetime.abort(); unsubscribe(); for (const entry of published.values()) entry.controller.abort(); published.clear(); errors.clear(); },
  });
}
