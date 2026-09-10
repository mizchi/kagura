import { test } from 'node:test';
import assert from 'node:assert/strict';
import { publishPaneTools } from '../web/plugin-webmcp.mjs';

function catalog() {
  let tools = []; const listeners = new Set();
  return {
    tools: () => tools,
    subscribeTools(fn) { listeners.add(fn); return () => listeners.delete(fn); },
    set(next) { tools = next; for (const fn of listeners) fn(); },
  };
}
const tool = name => ({ name, execute: async (_, { signal }) => ({ aborted: signal.aborted }) });
function context() {
  const registered = new Map([['unrelated', {}]]);
  return { registered, registerTool(definition, { signal }) {
    assert.equal(registered.has(definition.name), false, 'must unregister old generation first');
    registered.set(definition.name, definition);
    signal.addEventListener('abort', () => registered.delete(definition.name), { once: true });
  } };
}

test('publication isolates failed tools and replaces only its own registrations', async () => {
  const panes = catalog(), model = context(), parent = new AbortController();
  const register = model.registerTool;
  model.registerTool = (definition, options) => {
    if (definition.name === 'broken') throw new Error('Unsupported schema');
    return register(definition, options);
  };
  panes.set([tool('valid'), tool('broken')]);
  const publication = publishPaneTools(panes, model, parent.signal);
  await publication.settled();
  assert.deepEqual(publication.status(), { tools: ['valid'], errors: [{ name: 'broken', message: 'Unsupported schema' }] });
  const stale = model.registered.get('valid');
  panes.set([tool('valid')]); await publication.settled();
  assert.equal((await stale.execute({})).aborted, true);
  assert.notEqual(model.registered.get('valid'), stale);
  assert.deepEqual(publication.status().errors, []);
  publication.dispose();
  assert.deepEqual([...model.registered.keys()], ['unrelated']);
});

test('replacement during asynchronous registration never publishes the stale generation', async () => {
  const panes = catalog(), model = context(), parent = new AbortController();
  let finish; const register = model.registerTool;
  model.registerTool = (definition, options) => {
    register(definition, options);
    if (!finish) return new Promise(resolve => { finish = resolve; });
  };
  panes.set([tool('replace')]);
  const publication = publishPaneTools(panes, model, parent.signal);
  await Promise.resolve();
  const stale = model.registered.get('replace');
  panes.set([tool('replace')]); finish(); await publication.settled();
  assert.deepEqual(publication.status().tools, ['replace']);
  assert.notEqual(model.registered.get('replace'), stale);
  assert.equal((await stale.execute({})).aborted, true);
  parent.abort(); publication.dispose();
});

test('dispose during pending registration aborts immediately and prevents late publication', async () => {
  const panes = catalog(), model = context(), parent = new AbortController();
  let finish; const register = model.registerTool;
  model.registerTool = (definition, options) => { register(definition, options); return new Promise(resolve => { finish = resolve; }); };
  panes.set([tool('pending')]);
  const publication = publishPaneTools(panes, model, parent.signal);
  await Promise.resolve();
  publication.dispose();
  assert.deepEqual([...model.registered.keys()], ['unrelated']);
  finish(); await publication.settled();
  assert.deepEqual(publication.status().tools, []);
});
