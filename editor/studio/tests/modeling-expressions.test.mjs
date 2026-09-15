import test from "node:test";
import assert from "node:assert/strict";
import {
  createModelEditor,
  kawaiikoDocument,
  evaluateModel,
} from "../modeling/model.mjs";
import { modelObject, disposeObject } from "../modeling/geometry.mjs";

const human = () => ({
  version: 1,
  format: "kagura.mesh",
  name: "Human face",
  source: "",
  nodes: [
    {
      id: "face",
      name: "Face",
      color: 0xcc9977,
      position: [0, 1, 0],
      vertices: [
        [-1, 0, 0],
        [1, 0, 0],
        [1, 2, 0],
        [-1, 2, 0],
      ],
      faces: [[0, 1, 2, 3]],
    },
  ],
});
const move = (editor, value) => {
  editor.request({ op: "begin", kind: "move" });
  editor.request({ op: "preview", value });
  editor.request({ op: "confirm" });
};

test("kawaiiko has visible eyebrow meshes and neutral-relative facial presets", () => {
  const doc = kawaiikoDocument();
  for (const side of ["left", "right"]) {
    const brow = doc.nodes.find((n) => n.id === `brow.${side}`);
    const eye = doc.nodes.find((n) => n.id === `eye.${side}`);
    assert.ok(brow && brow.position[1] > eye.position[1]);
  }
  for (const id of ["happy", "angry", "sad", "surprised", "blink"]) {
    assert.ok(doc.expressions.find((e) => e.id === id)?.targets.length);
    assert.notDeepEqual(evaluateModel(doc, { [id]: 1 }).nodes, doc.nodes);
  }
  assert.deepEqual(evaluateModel(doc, {}).nodes, doc.nodes);
});

test("expression previews blend from the base without accumulating or modifying history", () => {
  const editor = createModelEditor();
  const initial = editor.snapshot();
  editor.request({
    op: "expression.preview",
    weights: { happy: 0.5, blink: 0.4 },
  });
  const preview = editor.snapshot();
  assert.deepEqual(preview.document, initial.document);
  assert.equal(preview.revision, initial.revision);
  assert.equal(preview.canUndo, false);
  assert.notDeepEqual(preview.previewNodes, initial.document.nodes);
  editor.request({
    op: "expression.preview",
    weights: { happy: 0.5, blink: 0.4 },
  });
  assert.deepEqual(editor.snapshot().previewNodes, preview.previewNodes);
  assert.throws(
    () => editor.request({ op: "begin", kind: "move" }),
    /preview|neutral/i,
  );
  editor.request({ op: "expression.preview", weights: {} });
  assert.deepEqual(editor.snapshot().previewNodes, initial.document.nodes);
  const before = editor.snapshot();
  for (const weights of [
    { missing: 1 },
    { happy: -1 },
    { happy: 1.5 },
    { happy: null },
  ]) {
    assert.throws(() => editor.request({ op: "expression.preview", weights }));
    assert.deepEqual(editor.snapshot(), before);
  }
});

test("legacy human meshes can author, cancel, save, edit and undo reusable vertex expressions", () => {
  const editor = createModelEditor(human());
  const base = editor.snapshot();
  assert.deepEqual(base.document.expressions, []);
  editor.request({ op: "expression.begin", id: "smile", name: "Smile" });
  editor.request({ op: "mode", value: "vertex" });
  editor.request({ op: "vertices", indices: [0, 1] });
  move(editor, [0, 0.2, 0]);
  assert.throws(
    () => editor.request({ op: "add", kind: "cube" }),
    /expression/i,
  );
  editor.request({ op: "expression.cancel" });
  assert.deepEqual(editor.snapshot().document, base.document);
  assert.equal(editor.snapshot().revision, base.revision);
  editor.request({ op: "expression.begin", id: "smile", name: "Smile" });
  editor.request({ op: "mode", value: "vertex" });
  editor.request({ op: "vertices", indices: [0, 1] });
  move(editor, [0, 0.2, 0]);
  editor.request({ op: "expression.save" });
  const saved = editor.snapshot().document;
  assert.deepEqual(saved.nodes, base.document.nodes);
  assert.equal(editor.snapshot().revision, base.revision + 1);
  const target = saved.expressions[0].targets[0];
  assert.equal(target.node, "face");
  assert.deepEqual(
    target.vertices.map((v) => v.index),
    [0, 1],
  );
  const half = evaluateModel(saved, { smile: 0.5 }).nodes[0];
  assert.equal(half.vertices[0][1], 0.1);
  assert.deepEqual(half.vertices.slice(2), saved.nodes[0].vertices.slice(2));
  editor.request({ op: "expression.begin", id: "smile", name: "Smile" });
  assert.equal(editor.snapshot().document.nodes[0].vertices[0][1], 0.2);
  editor.request({ op: "expression.cancel" });
  editor.request({ op: "undo" });
  assert.deepEqual(editor.snapshot().document, base.document);
  editor.request({ op: "redo" });
  assert.deepEqual(editor.snapshot().document, saved);
  assert.deepEqual(
    createModelEditor(JSON.parse(JSON.stringify(saved))).snapshot().document,
    saved,
  );
});

test("malformed expression bindings are rejected atomically and bound topology stays stable", () => {
  const editor = createModelEditor();
  const base = editor.snapshot();
  const invalid = [
    (d) => (d.expressions[0].targets[0].node = "missing"),
    (d) => d.expressions.push(structuredClone(d.expressions[0])),
    (d) =>
      d.expressions[0].targets[0].vertices.push({
        index: 999999,
        offset: [0, 1, 0],
      }),
    (d) => (d.expressions[0].targets[0].position = [0, null, 0]),
    (d) => (d.expressions[0].unknown = true),
  ];
  for (const mutate of invalid) {
    const doc = structuredClone(base.document);
    mutate(doc);
    assert.throws(() => editor.request({ op: "replace", document: doc }));
    assert.deepEqual(editor.snapshot(), base);
  }
  editor.request({ op: "select", id: "brow.left" });
  assert.throws(() => editor.request({ op: "remove" }), /expression/i);
  editor.request({ op: "mode", value: "face" });
  editor.request({ op: "face", index: 0 });
  assert.throws(
    () => editor.request({ op: "begin", kind: "extrude" }),
    /expression/i,
  );
  // Deleting expressions is undoable and frees their references.
  editor.request({ op: "expression.remove", id: "happy" });
  assert.ok(
    !editor.snapshot().document.expressions.some((e) => e.id === "happy"),
  );
  editor.request({ op: "undo" });
  assert.deepEqual(editor.snapshot().document, base.document);
});

test("GLB geometry preserves named relative morph targets including object movement", () => {
  const editor = createModelEditor(human());
  editor.request({ op: "expression.begin", id: "jawOpen", name: "Jaw open" });
  move(editor, [0, -0.2, 0]);
  editor.request({ op: "expression.save" });
  const doc = editor.snapshot().document;
  const root = modelObject(doc);
  try {
    const mesh = root.children[0];
    const index = mesh.morphTargetDictionary.jawOpen;
    assert.equal(index, 0);
    assert.equal(mesh.geometry.morphTargetsRelative, true);
    const delta = mesh.geometry.morphAttributes.position[index];
    for (let i = 0; i < delta.count; i++)
      assert.ok(Math.abs(delta.getY(i) + 0.2) < 1e-6);
    assert.deepEqual(mesh.position.toArray(), doc.nodes[0].position);
  } finally {
    disposeObject(root);
  }
});
