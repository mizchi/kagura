import { installModelAssets } from '../assets/pane.mjs';
import { installSceneHierarchy } from './scene-hierarchy.mjs';
import { installRuntimeInspector } from './runtime-inspector.mjs';
import { installInspectorParts } from './inspector-parts.mjs';
import { agentChatPane } from './agent-chat.mjs';
import { terminalPane } from './terminal-pane.mjs';
import { buildSceneGraph, scenesFromManifest } from '../runtime/scene-graph.mjs';
import { installProjectTransport } from './project-transport.mjs';
import { decodeSceneFile } from '../scene/moonbit.mjs';
import * as app from '../_build/js/release/build/app/app.js';
import { createAPI } from './api.mjs';
import { createViewport } from './viewport.mjs';
import { createWorkspaceLayout } from './layout.mjs';
import { createPaneHost } from './panes.mjs';
import { createWorkspace } from './workspace.mjs';
import { registerWebMCP } from './webmcp.mjs';
import { createBrowserStorage, downloadBlob } from './storage.mjs';
import { storagePane } from './storage-pane.mjs';
import { createExtensionHost } from '../extensions/host.mjs';
import { editorExtensions, defaultEditor } from '../extensions/catalog.mjs';
import { installProjectUI } from '../projects/browser.mjs';
import { defineJSPlugin, fromJSONModule, fromWasm } from '../plugins/adapters.mjs';
import './style.css';
import './layout.css';

const LAYOUT = 'kagura.studio.layout.v1';
const api = createAPI(app);
let viewport, workspaceLayout, gameEditor, modelAssets;
const storage = createBrowserStorage(api);
try { const restored = await storage.restore(); if (restored) app.set_status(restored); }
catch (error) { app.set_status('Error · Saved scene could not be restored: ' + error.message); }

globalThis.kaguraHost = async (action, data) => {
  try {
    switch (action) {
      case 'save': {
        app.set_status('Saving…');
        const projectSaved = await gameEditor?.save();
        if (projectSaved) { app.set_status(projectSaved); break; }
        const result = await storage.save(storage.location(), api.snapshot().revision);
        app.set_status('Saved · ' + result.location.store + '/' + result.location.key); break;
      }
      case 'storage': panes.open('studio.storage'); break;
      case 'game-editor': await gameEditor.open(); break;
      case 'export': if (gameEditor?.active()) gameEditor.exportScene(); else downloadBlob(new Blob([data], { type: 'application/json' }), 'scene.kagura.json'); break;
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
          const document = decodeSceneFile(file.name, await file.text());
          if (gameEditor.project() || gameEditor.accepts(document)) await gameEditor.importScene(document, expectedRevision);
          else api.dispatch({ expectedRevision, commands: [{ op: 'document.replace', document }] });
        } finally { input.value = ''; }
        break;
      }
      case 'copy': await navigator.clipboard.writeText(data); app.set_status('Context copied'); break;
      case 'layout': workspaceLayout?.setLayout(data); localStorage.setItem(LAYOUT, data); break;
      case 'camera': if (gameEditor?.active()) gameEditor.view(data); else viewport?.view(data); break;
      case 'frame': if (gameEditor?.active()) gameEditor.frame(); else viewport?.frame(data); break;
      case 'play': viewport?.play(); break;
      case 'pause': viewport?.pause(); break;
    }
  } catch (error) { app.set_status('Error · ' + error.message); }
};
app.mount(document.getElementById('app'));
const panes = createPaneHost(document.querySelector('.agent'), api, app);
const workspace = createWorkspace();
panes.register(storagePane(storage, api, app.set_status));
const plugins = Object.freeze({ defineJSPlugin, fromJSONModule, fromWasm });
const runtime = Object.freeze({ ...Object.fromEntries(['snapshot', 'pause', 'resume', 'step', 'replace', 'inspect', 'edit'].map(method => [method, (...args) => gameEditor.debug(method, ...args)])), hierarchy: () => gameEditor.hierarchy() });
const assets = Object.freeze(Object.fromEntries(['list', 'preview', 'close', 'snapshot'].map(method => [method, (...args) => modelAssets[method](...args)])));
const browserAPI = Object.freeze({ ...api, panes, storage, plugins, runtime, assets });
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
gameEditor = createExtensionHost({ editor: api, panes, viewport, workspace, setStatus: app.set_status }, editorExtensions);
await gameEditor.useBuiltin(defaultEditor);
const projectTransport = installProjectTransport(gameEditor, app.set_status);
const runtimeInspector = installRuntimeInspector(gameEditor, app.set_status, workspace);
const inspectorParts = installInspectorParts(gameEditor, workspace);
const sceneHierarchy = installSceneHierarchy(gameEditor, app.set_status, runtimeInspector.selectSubject, api, workspace);
modelAssets = installModelAssets({ host: gameEditor, panes, viewport, setStatus: app.set_status });
const projectUI = installProjectUI({ host: gameEditor, panes, assets: modelAssets, setStatus: app.set_status });
function graph() {
  const debugging = gameEditor.transport().debugging;
  let inspection = null;
  try {
    if (debugging) inspection = gameEditor.debug('inspect');
  } catch { /* Play without an inspector still exposes the authored graph. */ }
  const snapshot = api.snapshot();
  return buildSceneGraph({
    sceneId: gameEditor.sceneId(),
    scenes: scenesFromManifest(gameEditor.project()?.manifest),
    hierarchy: debugging ? gameEditor.hierarchy() : null,
    inspection,
    document: snapshot.document,
    selection: snapshot.selection ? { kind: 'node', id: snapshot.selection } : undefined,
  });
}
globalThis.kagura = Object.freeze({
  ...globalThis.kagura,
  projects: { current: gameEditor.project },
  graph,
  selectScene: (id) => gameEditor.selectScene(id),
  workspace: Object.freeze({
    list: () => workspace.list(),
    active: (id) => workspace.slot(id).active(),
  }),
});
panes.register(agentChatPane(globalThis.kagura));
panes.register(terminalPane());
const keyboard = event => {
  if (event.target?.closest?.('input, textarea, select, [contenteditable]')) return;
  if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === 'z') {
    event.preventDefault();
    api[event.shiftKey ? 'redo' : 'undo'](api.snapshot().revision);
  }
  if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === 's') {
    event.preventDefault(); globalThis.kaguraHost('save', JSON.stringify(api.snapshot().document));
  }
  if (event.key.toLowerCase() === 'f') { if (gameEditor?.active()) gameEditor.frame(); else viewport?.frame(api.snapshot().selection); }
};
document.addEventListener('keydown', keyboard);
if (import.meta.hot) import.meta.hot.dispose(() => { projectTransport.dispose(); runtimeInspector.dispose(); inspectorParts.dispose(); sceneHierarchy.dispose(); projectUI.dispose(); modelAssets.dispose(); gameEditor.dispose(); webmcp.dispose(); panes.dispose(); workspace.dispose(); storage.dispose().catch(console.error); viewport?.dispose(); workspaceLayout?.dispose(); document.removeEventListener('keydown', keyboard); });
