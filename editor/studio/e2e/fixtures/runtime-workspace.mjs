// Deterministic fixture for the real UI components; game semantics are covered by game E2E.
import { createRuntimeSession } from "../../runtime/session.mjs";
import { createRuntimeFieldSession } from "../../runtime/field-session.mjs";
import { createWorkspace } from "../../web/workspace.mjs";
import { createWorkspaceLayout } from "../../web/layout.mjs";
import { createPaneHost } from "../../web/panes.mjs";
import { installProjectTransport } from "../../web/project-transport.mjs";
import { installRuntimeInspector } from "../../web/runtime-inspector.mjs";
import { installInspectorParts } from "../../web/inspector-parts.mjs";
import { installSceneHierarchy } from "../../web/scene-hierarchy.mjs";
import { installRuntimeWorkspace } from "../../web/runtime-workspace.mjs";
const mode = new URLSearchParams(location.search).get("mode");
const partial = mode === "fields";
const observed = partial || mode === "observation";
let revision = 0,
  paused = false,
  playing = true,
  state = { y: 120, velocity: -2 };
const listeners = new Set();
const fieldSession = createRuntimeFieldSession({
  apiVersion: 1,
  game: "fixture",
  read() {
    const observation = host.observe();
    return {
      revision,
      paused,
      scope: observation.inspection.scope,
      subjects: observation.inspection.subjects.map((s) => ({
        ...s,
        fields: s.fields.map((f) => ({
          ...f,
          access: f.kind === "number" ? "runtime" : "readonly",
        })),
      })),
    };
  },
  pause(value) {
    if (value) runtime.pause();
    else runtime.resume(runtime.snapshot());
  },
  edit(edit) {
    if (!paused || !Number.isFinite(edit.value) || Math.abs(edit.value) > 10000)
      throw Error("Invalid fixture edit");
    if (edit.field === "position.x") state.x = edit.value;
    else if (edit.field === "position.y") state.y = edit.value;
    else if (edit.field === "velocity.y") state.velocity = edit.value;
    else throw Error("Unknown fixture field");
    revision++;
  },
});
const runtime = createRuntimeSession({
  apiVersion: 1,
  game: "fixture",
  schema: { id: "fixture", version: 1 },
  read: () => ({ revision, paused, state }),
  pause: (value) => {
    paused = value;
    revision++;
  },
  step: () => {
    state.y += state.velocity;
    revision++;
  },
  replace: (value) => {
    state = value;
    revision++;
  },
  inspector: {
    describe: (s) => [
      {
        id: "bird",
        name: "Bird",
        fields: [
          {
            id: "y",
            label: "Y",
            unit: "px",
            kind: "number",
            access: "runtime",
            value: s.y,
          },
          {
            id: "speed",
            label: "Speed",
            unit: "px/tick",
            kind: "number",
            access: "readonly",
            value: Math.abs(s.velocity),
          },
        ],
      },
    ],
    reduce: (s, e) => ({ ...s, y: e.value }),
  },
});
runtime.pause();
runtime.edit({ subject: "bird", field: "y", value: 80 }, runtime.snapshot());
const editor = {
  snapshot: () => ({
    revision: 0,
    document: { nodes: [], resources: [] },
    selection: null,
  }),
  subscribe: () => () => {},
  capabilities: () => ({}),
};
const host = {
  subscribe: (listener) => {
    listeners.add(listener);
    return () => listeners.delete(listener);
  },
  transport: () => ({
    available: true,
    canPlay: true,
    playing,
    debugging: playing && !observed,
    fieldEditing: playing && partial,
    canPause: true,
    paused,
  }),
  debug(method, ...args) {
    const result = runtime[method](...args);
    if (!["snapshot", "inspect", "history", "canUndo"].includes(method))
      for (const l of listeners) l();
    return result;
  },
  fields(method, ...args) {
    const result = fieldSession[method](...args);
    if (!["inspect", "history"].includes(method))
      for (const listener of listeners) listener();
    return result;
  },
  hierarchy: () => [
    {
      id: "world",
      name: "World",
      kind: "group",
      generated: false,
      children: [
        {
          id: "world/body",
          name: "Body",
          kind: "rect",
          generated: false,
          subject: observed ? "player" : "bird",
          children: [],
        },
      ],
    },
  ],
  sceneId: () => "",
  project: () => ({ manifest: {} }),
  observe: () =>
    observed && playing
      ? {
          game: "fixture",
          source: "scene",
          readonly: true,
          state: { ...state },
          inspection: {
            scope: "training",
            subjects: [
              {
                id: "player",
                name: "Player",
                fields: [
                  {
                    id: "position.x",
                    label: "Position X",
                    kind: "number",
                    value: state.x ?? 3,
                    unit: "m",
                    access: "readonly",
                  },
                  {
                    id: "position.y",
                    label: "Position Y",
                    kind: "number",
                    value: state.y,
                    unit: "m",
                    access: "readonly",
                  },
                  {
                    id: "velocity.y",
                    label: "Velocity Y",
                    kind: "number",
                    value: state.velocity,
                    unit: "m/s",
                    access: "readonly",
                  },
                  {
                    id: "grounded",
                    label: "Grounded",
                    kind: "boolean",
                    value: true,
                    unit: "",
                    access: "readonly",
                  },
                ],
              },
            ],
          },
        }
      : null,
  pause: () => host.debug("pause"),
  resume: () => host.debug("resume", runtime.snapshot()),
  stop: () => {
    playing = false;
    for (const l of listeners) l();
  },
  play: () => {
    playing = true;
    for (const l of listeners) l();
  },
  edit: () => host.stop(),
};
const panes = createPaneHost(document.querySelector(".agent"), editor, {}),
  workspace = createWorkspace();
createWorkspaceLayout(document.querySelector(".workspace"));
installProjectTransport(host, () => {});
const inspector = installRuntimeInspector(host, () => {}, workspace);
installInspectorParts(host, workspace);
const hierarchy = installSceneHierarchy(
  host,
  () => {},
  inspector.selectSubject,
  editor,
  workspace,
);
installRuntimeWorkspace(host, panes, hierarchy);
hierarchy.select(observed ? "player" : "bird");
const frame = document.createElement("iframe");
frame.className = "game-frame";
frame.title = "Fixture game";
frame.srcdoc = `<html><body style="margin:0;display:grid;place-items:center;background:#111a23"><canvas width="320" height="240"></canvas><script>const c=document.querySelector('canvas'),x=c.getContext('2d');x.fillStyle='#8bd0df';x.fillRect(0,0,320,240);x.fillStyle='#719670';x.fillRect(0,220,320,20);x.fillStyle='#efbb74';x.fillRect(60,80,12,12);window.kaguraExample={project:{display:{width:320,height:240}}};window.__kaguraUISnapshot={parsed:{nodes:[{path:'world>body',left:60,top:80,width:12,height:12,visible:true}]}};<\/script></body></html>`;
document.getElementById("viewport").classList.add("game-active");
document.getElementById("viewport").append(frame);
document.querySelector(".viewport-toolbar").classList.add("showing-game");
window.runtimeFixture = { host, runtime };
// Match the real host's Play notification after every shell component mounts.
for (const listener of listeners) listener();
