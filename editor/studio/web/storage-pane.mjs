/** Storage browser is an ordinary plugin; the editor core has no provider dependencies. */
export function storagePane(storage, editor, setStatus) {
  return { id: 'studio.storage', title: 'Storage', mount({ element, signal }) {
    const heading = document.createElement('h2'); heading.textContent = 'Resource storage';
    const message = document.createElement('p'); message.setAttribute('role', 'status');
    const source = document.createElement('select'); source.setAttribute('aria-label', 'Storage provider');
    const key = input('Resource key', storage.location().key);
    const prefix = input('Resource prefix', '');
    const rows = document.createElement('div'); rows.className = 'storage-rows';
    let cursor = null, generation = 0;
    function input(label, value = '', type = 'text') { const field = document.createElement('input'); field.type = type; field.value = value; field.setAttribute('aria-label', label); field.placeholder = label; return field; }
    function field(label, node) { const wrapper = document.createElement('label'); wrapper.className = 'custom-field'; const name = document.createElement('span'); name.textContent = label; wrapper.append(name, node); return wrapper; }
    function button(label, action) {
      const node = document.createElement('button'); node.type = 'button'; node.textContent = label;
      node.addEventListener('click', () => {
        node.disabled = true;
        let result; try { result = action(); } catch (error) { result = Promise.reject(error); }
        Promise.resolve(result).catch(error => { if (!signal.aborted) message.textContent = error.code === 'canceled' || error.name === 'AbortError' ? 'Canceled' : 'Error · ' + error.message; }).finally(() => { node.disabled = node === next && !cursor; });
      }, { signal }); return node;
    }
    function updateProviders(selected = source.value || storage.location().store) {
      source.replaceChildren(...storage.stores().map(({ id }) => { const option = document.createElement('option'); option.value = id; option.textContent = id; return option; })); source.value = selected;
    }
    function ref() { return { store: source.value, key: key.value }; }
    async function list(more = false) {
      const ticket = ++generation, provider = source.value;
      const result = await storage.list(provider, { prefix: prefix.value, cursor: more ? cursor : null, signal });
      if (signal.aborted || ticket !== generation) return;
      if (!more) rows.replaceChildren();
      cursor = result.cursor; next.disabled = !cursor;
      for (const object of result.objects) {
        const row = document.createElement('div'); row.className = 'storage-row';
        const choose = button(object.key, () => { key.value = object.key; }); choose.title = object.key;
        const download = button('Download ' + object.key, () => storage.download({ store: provider, key: object.key }, undefined, { signal })); download.textContent = '↓'; download.setAttribute('aria-label', 'Download ' + object.key);
        const size = document.createElement('span'); size.className = 'muted'; size.textContent = object.size + ' B';
        row.append(choose, size, download); rows.append(row);
      }
      message.textContent = rows.children.length + ' resources';
    }
    source.addEventListener('change', () => { cursor = null; rows.replaceChildren(); next.disabled = true; generation++; }, { signal });
    const refresh = button('List resources', () => list());
    const next = button('More resources', () => list(true)); next.disabled = true;
    const save = button('Save scene here', async () => {
      const result = await storage.save(ref(), editor.snapshot().revision, { signal });
      setStatus('Saved · ' + result.location.store + '/' + result.location.key); await list();
    });
    const load = button('Load scene', async () => { await storage.load(ref(), editor.snapshot().revision, { signal }); setStatus('Loaded scene'); });
    const download = button('Download resource', () => storage.download(ref(), undefined, { signal }));
    const upload = input('Upload resource', '', 'file');
    upload.addEventListener('change', () => {
      const file = upload.files[0]; if (!file) return;
      const target = { store: source.value, key: prefix.value + file.name };
      storage.write(target, file, { signal, ...(storage.stores().find(s => s.id === target.store).capabilities.conditionalWrite ? { ifMatch: null } : {}) })
        .then(() => { key.value = target.key; return list(); }).catch(error => { message.textContent = 'Error · ' + error.message; }).finally(() => { upload.value = ''; });
    }, { signal });
    const folder = button('Open folder', async () => { const id = await storage.connectDirectory(); if (!signal.aborted) { updateProviders(id); await list(); } });
    const endpoint = input('Worker endpoint', new URL('/api/storage/objects', location.href).href);
    const token = input('Worker token', '', 'password'); token.autocomplete = 'off';
    const remote = button('Connect R2', async () => { const id = await storage.connectWorker({ endpoint: endpoint.value, token: token.value }); token.value = ''; if (!signal.aborted) { updateProviders(id); await list(); } });
    const url = input('Resource URL', '', 'url');
    const urlDownload = button('Download URL', () => storage.download({ url: url.value }, undefined, { signal }));
    element.append(heading, field('Store', source), field('Key', key), save, load, download,
      field('Prefix', prefix), refresh, next, rows, field('Upload', upload), folder,
      field('Worker endpoint', endpoint), field('Worker token', token), remote, field('Resource URL', url), urlDownload, message);
    updateProviders();
  } };
}
