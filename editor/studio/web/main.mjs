import * as app from '../_build/js/release/build/app/app.js';
import { createAPI } from './api.mjs';
import { createViewport } from './viewport.mjs';
import { createWorkspaceLayout } from './layout.mjs';
import { createPaneHost } from './panes.mjs';
import { registerWebMCP } from './webmcp.mjs';
import { createBrowserStorage, downloadBlob } from './storage.mjs';
import { storagePane } from './storage-pane.mjs';
import { defineJSPlugin, fromJSONModule, fromWasm } from '../plugins/adapters.mjs';
import './style.css';
import './layout.css';

const LAYOUT = 'kagura.studio.layout.v1';
const api = createAPI(app);
let viewport, workspaceLayout;
const storage = createBrowserStorage(api);
try { const restored = await storage.restore(); if (restored) app.set_status(restored); }
catch (error) { app.set_status('Error · Saved scene could not be restored: ' + error.message); }

globalThis.kaguraHost = async (action, data) => {
  try {
    switch (action) {
      case 'save': {
        app.set_status('Saving…');
        const result = await storage.save(storage.location(), api.snapshot().revision);
        app.set_status('Saved · ' + result.location.store + '/' + result.location.key); break;
      }
      case 'storage': panes.open('studio.storage'); break;
      case 'export': downloadBlob(new Blob([data], { type: 'application/json' }), 'scene.kagura.json'); break;
      case 'glb': {
        // Export an authoring copy, never the animated preview graph.
        const root = app.build_scene();
        try {
          const { GLTFExporter } = await import('three/addons/exporters/GLTFExporter.js');
          const bytes = await new GLTFExporter().parseAsync(root, { binary: true });
          downloadBlob(new Blob([bytes], { type: 'model/gltf-binary' }), 'scene.glb');
          app.set_status('Exported authoring scene as GLB');
        } finally {
          root.traverse(n => { n.geometry?.dispose(); n.material?.dispose(); });
        }
        break;
      }
      case 'import': {
        const input = document.getElementById('import-scene');
        const file = input.files[0];
        if (!file) break;
        const expectedRevision = api.snapshot().revision;
        try {
          if (file.size > 4 * 1024 * 1024) throw new Error('Scene exceeds 4 MiB');
          const document = JSON.parse(await file.text());
          api.dispatch({ expectedRevision, commands: [{ op: 'document.replace', document }] });
        } finally { input.value = ''; }
        break;
      }
      case 'copy': await navigator.clipboard.writeText(data); app.set_status('Context copied'); break;
      case 'layout': workspaceLayout?.setLayout(data); localStorage.setItem(LAYOUT, data); break;
      case 'camera': viewport?.view(data); break;
      case 'frame': viewport?.frame(data); break;
      case 'play': viewport?.play(); break;
      case 'pause': viewport?.pause(); break;
    }
  } catch (error) { app.set_status('Error · ' + error.message); }
};
app.mount(document.getElementById('app'));
const panes = createPaneHost(document.querySelector('.agent'), api, app);
panes.register(storagePane(storage, api, app.set_status));
const plugins = Object.freeze({ defineJSPlugin, fromJSONModule, fromWasm });
const browserAPI = Object.freeze({ ...api, panes, storage, plugins });
const webmcp = registerWebMCP(browserAPI, document.modelContext);
globalThis.kagura = Object.freeze({ ...browserAPI, webmcp });
const webmcpStatus = document.createElement('p');
webmcpStatus.className = 'panel-note';
webmcpStatus.setAttribute('aria-label', 'WebMCP status');
document.querySelector('.agent .panel-body').append(webmcpStatus);
webmcp.ready.then(() => {
  const status = webmcp.status();
  webmcpStatus.textContent = status.state === 'ready' ? 'WebMCP · AI tools ready' : status.state === 'unsupported' ? 'WebMCP · unavailable in this browser' : 'WebMCP · ' + status.message;
});
workspaceLayout = createWorkspaceLayout(document.querySelector('.workspace'));
try {
  app.set_layout(localStorage.getItem(LAYOUT) ?? 'scene');
} catch (error) { app.set_status('Error · Layout could not be restored: ' + error.message); }
try { viewport = createViewport(document.getElementById('viewport'), app, api); }
catch (error) { app.set_status('Error · 3D viewport: ' + error.message); }
const keyboard = event => {
  if (event.target.closest('input, textarea, select, [contenteditable]')) return;
  if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === 'z') {
    event.preventDefault();
    api[event.shiftKey ? 'redo' : 'undo'](api.snapshot().revision);
  }
  if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === 's') {
    event.preventDefault(); globalThis.kaguraHost('save', JSON.stringify(api.snapshot().document));
  }
  if (event.key.toLowerCase() === 'f') viewport?.frame(api.snapshot().selection);
};
document.addEventListener('keydown', keyboard);
if (import.meta.hot) import.meta.hot.dispose(() => { webmcp.dispose(); panes.dispose(); storage.dispose().catch(console.error); viewport?.dispose(); workspaceLayout?.dispose(); document.removeEventListener('keydown', keyboard); });
