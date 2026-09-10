/** A local trusted plugin: import and install without rebuilding the editor. */
export function install(api) {
  const id = 'my-game.tools';
  api.panes.register({
    id, title: 'Game tools',
    mount({ element, editor, subscribe, signal }) {
      const context = document.createElement('pre');
      const add = document.createElement('button'); add.textContent = 'Add spawn marker';
      add.addEventListener('click', () => {
        const snapshot = editor.snapshot();
        editor.dispatch({ expectedRevision: snapshot.revision, commands: [{
          op: 'node.add', id: 'spawn.' + crypto.randomUUID(), name: 'Spawn marker', asset: 'group',
        }] });
      }, { signal });
      const render = snapshot => { context.textContent = JSON.stringify({ revision: snapshot.revision, selected: snapshot.selection, resources: snapshot.document.resources.map(r => r.id) }, null, 2); };
      render(editor.snapshot()); subscribe(render);
      element.append(add, context);
      // Return a disposer here for timers, observers, GPU objects, etc.
    },
  });
  api.panes.open(id);
  return () => api.panes.unregister(id);
}
