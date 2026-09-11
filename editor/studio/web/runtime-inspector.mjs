import { downloadBlob } from './storage.mjs';

/** An explicit paused-state draft; it never writes authoring documents or source files. */
export function installRuntimeInspector(host, setStatus) {
  const container = document.querySelector('.inspector');
  let panel,
    text,
    caption,
    apply,
    file,
    base,
    dirty = false;
  const refreshDraft = (snapshot) => {
    base = snapshot;
    text.value = JSON.stringify(snapshot.state, null, 2);
    dirty = false;
  };
  function mount() {
    panel = document.createElement('section');
    panel.className = 'runtime-inspector';
    panel.setAttribute('aria-label', 'Runtime inspector');
    const heading = document.createElement('h2');
    heading.textContent = 'Runtime state';
    caption = document.createElement('p');
    const note = document.createElement('p');
    note.textContent = 'Pauseで実行状態を編集。Apply後はその状態から再開します。';
    text = document.createElement('textarea');
    text.setAttribute('aria-label', 'Runtime state JSON');
    text.spellcheck = false;
    text.addEventListener('input', () => {
      dirty = true;
    });
    const button = (label, action) => {
      const node = document.createElement('button');
      node.type = 'button';
      node.textContent = label;
      node.addEventListener('click', async () => {
        try {
          await action();
        } catch (error) {
          setStatus('Error · ' + error.message);
        }
      });
      return node;
    };
    apply = button('Apply state', () => {
      const next = host.debug('replace', JSON.parse(text.value), base);
      refreshDraft(next);
      setStatus('Runtime state applied · ソースは変更していません');
    });
    const read = button('Read state', () => refreshDraft(host.debug('snapshot')));
    const save = button('Export checkpoint', () => {
      const { game, schema, state } = host.debug('snapshot');
      downloadBlob(
        new Blob(
          [
            JSON.stringify(
              { format: 'kagura.checkpoint', version: 1, game, schema, state },
              null,
              2,
            ),
          ],
          { type: 'application/json' },
        ),
        game + '.kgrstate',
      );
    });
    file = document.createElement('input');
    file.type = 'file';
    file.accept = '.kgrstate,.json';
    file.setAttribute('aria-label', 'Import checkpoint');
    file.addEventListener('change', async () => {
      const target = panel,
        inputFile = file;
      try {
        const current = host.debug('snapshot');
        if (!current.paused) throw Error('Pause before importing a checkpoint');
        const selected = inputFile.files[0];
        if (!selected) return;
        if (selected.size > 4 * 1024 * 1024) throw Error('Checkpoint exceeds 4 MiB');
        const checkpoint = JSON.parse(await selected.text());
        if (panel !== target) throw Error('Runtime changed while loading checkpoint');
        const latest = host.debug('snapshot');
        if (latest.session !== current.session || latest.revision !== current.revision)
          throw Error('Runtime changed while loading checkpoint');
        if (
          checkpoint.format !== 'kagura.checkpoint' ||
          checkpoint.version !== 1 ||
          checkpoint.game !== current.game ||
          checkpoint.schema?.id !== current.schema.id ||
          checkpoint.schema?.version !== current.schema.version ||
          !Object.hasOwn(checkpoint, 'state')
        )
          throw Error('Incompatible checkpoint');
        base = current;
        text.value = JSON.stringify(checkpoint.state, null, 2);
        dirty = true;
        setStatus('Checkpoint loaded · Apply stateで適用');
      } catch (error) {
        setStatus('Error · ' + error.message);
      } finally {
        inputFile.value = '';
      }
    });
    panel.append(heading, caption, note, text, apply, read, save, file);
    container.append(panel);
    container.classList.add('runtime-inspecting');
  }
  function render() {
    if (!host.transport().debugging) {
      panel?.remove();
      panel = undefined;
      base = undefined;
      dirty = false;
      container.classList.remove('runtime-inspecting');
      return;
    }
    if (!panel) mount();
    const snapshot = host.debug('snapshot');
    caption.textContent =
      (snapshot.paused ? 'Paused' : 'Running') + ' · revision ' + snapshot.revision;
    text.disabled = apply.disabled = file.disabled = !snapshot.paused;
    if (!dirty || base?.session !== snapshot.session) refreshDraft(snapshot);
  }
  const unsubscribe = host.subscribe(render);
  render();
  return {
    dispose() {
      unsubscribe();
      panel?.remove();
      container.classList.remove('runtime-inspecting');
    },
  };
}
