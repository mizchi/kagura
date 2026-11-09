import { test } from "node:test";
import assert from "node:assert/strict";
import { createEditorTools } from "../agent/tools.mjs";
import { createRuntimeSession } from "../runtime/session.mjs";
import { fieldRuntime } from "./fixtures/field-runtime.mjs";

function host() {
  let document = {
    version: 1,
    name: "Arena",
    nodes: [{ id: "hero", name: "Hero" }],
  };
  let revision = 0;
  let selected = "";
  let sceneId = "training";
  const scenes = [
    { id: "training", path: "scenes/training.mbt", entry: true },
    { id: "second", path: "scenes/second.mbt" },
  ];
  let state = { y: 12, velocity: 3 };
  let paused = false;
  let runtimeRevision = 0;
  const adapter = {
    apiVersion: 1,
    game: "inspection",
    schema: { id: "test.state", version: 1 },
    read: () => ({ state, revision: runtimeRevision, paused }),
    pause: (value) => {
      paused = value;
      runtimeRevision++;
    },
    step: () => {
      runtimeRevision++;
    },
    replace: (value) => {
      state = value;
      runtimeRevision++;
    },
    inspector: {
      describe: (current) => [
        {
          id: "bird",
          name: "Bird",
          fields: [
            {
              id: "y",
              label: "Y",
              kind: "number",
              value: current.y,
              access: "runtime",
              unit: "px",
            },
          ],
        },
      ],
      reduce: (current, edit) => ({ ...current, y: edit.value }),
    },
  };
  const runtime = createRuntimeSession(adapter);
  return {
    snapshot: () => ({ revision, document, selection: selected }),
    dispatch({ expectedRevision, commands }) {
      if (expectedRevision !== revision) throw Error("conflict");
      for (const command of commands) {
        if (command.op === "node.rename") document.nodes[0].name = command.name;
      }
      revision++;
      return { ok: true, revision };
    },
    select(id) {
      selected = id;
      return { ok: true, selection: selected };
    },
    runtime,
    selectScene(id) {
      if (!scenes.some((scene) => scene.id === id))
        throw Error("Unknown scene");
      sceneId = id;
      return { ok: true, sceneId };
    },
    graph() {
      return {
        sceneId,
        scenes,
        subjects: runtime.inspect().subjects,
        view: [],
      };
    },
  };
}

function text(result) {
  return JSON.parse(result.content[0].text);
}

test("agent field tools pause, edit and resume without changing authoring state", async () => {
  const editor = host(),
    fields = fieldRuntime(),
    before = editor.snapshot();
  const tools = Object.fromEntries(
    createEditorTools({ ...editor, runtime: { fields } }).map((tool) => [
      tool.name,
      tool,
    ]),
  );
  const paused = text(await tools.runtime_fields_pause.execute());
  const edited = text(
    await tools.runtime_fields_edit.execute({
      ...paused,
      subject: "player",
      field: "x",
      value: 7,
    }),
  );
  assert.equal(edited.subjects[0].fields[0].value, 7);
  await assert.rejects(
    () =>
      tools.runtime_fields_edit.execute({
        ...paused,
        subject: "player",
        field: "x",
        value: 8,
      }),
    /conflict/,
  );
  assert.equal(
    text(await tools.runtime_fields_resume.execute(edited)).paused,
    false,
  );
  assert.deepEqual(editor.snapshot(), before);
});

test("asynchronous runtime hosts produce resolved JSON tool content", async () => {
  const expected = {
    session: "s",
    revision: 1,
    scope: "training",
    paused: true,
    subjects: [],
  };
  const tools = Object.fromEntries(
    createEditorTools({
      runtime: { fields: { inspect: async () => expected } },
    }).map((tool) => [tool.name, tool]),
  );
  const result = await tools.runtime_fields_inspect.execute();
  assert.deepEqual(text(result), expected);
  assert.deepEqual(result.details, expected);
});

test("agent tools snapshot, dispatch, select and switch scenes on the live editor", async () => {
  const tools = Object.fromEntries(
    createEditorTools(host()).map((tool) => [tool.name, tool]),
  );
  assert.deepEqual(Object.keys(tools).sort(), [
    "editor_dispatch",
    "editor_select",
    "editor_snapshot",
    "runtime_edit",
    "runtime_fields_edit",
    "runtime_fields_inspect",
    "runtime_fields_pause",
    "runtime_fields_resume",
    "runtime_inspect",
    "runtime_observe",
    "runtime_pause",
    "scene_graph",
    "select_scene",
  ]);
  const before = text(await tools.editor_snapshot.execute());
  assert.equal(before.document.nodes[0].name, "Hero");
  const renamed = text(
    await tools.editor_dispatch.execute({
      expectedRevision: before.revision,
      commands: [{ op: "node.rename", id: "hero", name: "Player" }],
    }),
  );
  assert.equal(renamed.ok, true);
  assert.equal(
    text(await tools.editor_snapshot.execute()).document.nodes[0].name,
    "Player",
  );
  assert.equal(
    text(await tools.editor_select.execute({ id: "hero" })).selection,
    "hero",
  );
  assert.equal(
    text(await tools.select_scene.execute({ id: "second" })).sceneId,
    "second",
  );
  assert.equal(text(await tools.scene_graph.execute()).sceneId, "second");
});

test("runtime tools pause then edit through the game inspector, never inventing a subject", async () => {
  const tools = Object.fromEntries(
    createEditorTools(host()).map((tool) => [tool.name, tool]),
  );
  const running = text(await tools.runtime_inspect.execute());
  await assert.rejects(() =>
    tools.runtime_edit.execute({
      subject: "bird",
      field: "y",
      value: 80,
      session: running.session,
      revision: running.revision,
    }),
  );
  const paused = text(await tools.runtime_pause.execute());
  const edited = text(
    await tools.runtime_edit.execute({
      subject: "bird",
      field: "y",
      value: 80,
      session: paused.session,
      revision: paused.revision,
    }),
  );
  assert.equal(edited.state.y, 80);
  const graph = text(await tools.scene_graph.execute());
  assert.equal(graph.subjects[0].id, "bird");
});
