import test from "node:test";
import assert from "node:assert/strict";
import { createModelEditor, kawaikoDocument } from "../modeling/model.mjs";
import {
  meshGeometry,
  modelObject,
  disposeObject,
} from "../modeling/geometry.mjs";

test("invalid model imports and previews leave geometry and history intact", () => {
  const editor = createModelEditor(),
    initial = editor.snapshot();
  const malformed = structuredClone(initial.document);
  malformed.nodes[0].faces[0][0] = 999999;
  assert.throws(
    () => editor.request({ op: "replace", document: malformed }),
    /polygon/,
  );
  assert.deepEqual(editor.snapshot(), initial);
  assert.throws(() => editor.request({ op: "material", color: -1 }), /color/);
  editor.request({ op: "begin", kind: "scale" });
  const modal = editor.snapshot();
  assert.throws(
    () => editor.request({ op: "preview", value: [0, 1, 1] }),
    /zero/,
  );
  assert.deepEqual(editor.snapshot(), modal);
  assert.throws(() => editor.request({ op: "select", id: "body" }), /Confirm/);
  editor.request({ op: "cancel" });
  assert.deepEqual(editor.snapshot(), initial);
});

test("vertex edits affect only the selected vertices; mirrored meshes keep outward winding", () => {
  const editor = createModelEditor();
  editor.request({ op: "add", kind: "cube" });
  const before = editor.snapshot(),
    id = before.selected,
    node = before.document.nodes.at(-1);
  editor.request({ op: "mode", value: "vertex" });
  editor.request({ op: "vertices", indices: [0, 1] });
  editor.request({ op: "begin", kind: "move" });
  editor.request({ op: "preview", value: [0, 0.2, 0] });
  editor.request({ op: "confirm" });
  const edited = editor.snapshot().document.nodes.find((n) => n.id === id);
  assert.equal(edited.vertices[0][1], node.vertices[0][1] + 0.2);
  assert.deepEqual(edited.vertices.slice(2), node.vertices.slice(2));
  editor.request({ op: "undo" });
  editor.request({ op: "mode", value: "object" });
  editor.request({ op: "begin", kind: "scale" });
  editor.request({ op: "preview", value: [-1, 1, 1] });
  editor.request({ op: "confirm" });
  const mirrored = editor.snapshot().document.nodes.at(-1);
  assert.deepEqual(mirrored.faces[0], node.faces[0].toReversed());
  assert.equal(mirrored.vertices[0][0], -node.vertices[0][0]);
});

test("concave V pack triangulates without filling its notch and maps triangles to editable polygons", () => {
  const node = kawaikoDocument().nodes.find((n) => n.id === "backpack");
  const geometry = meshGeometry(node);
  try {
    const positions = geometry.getAttribute("position"),
      indices = geometry.index.array;
    let area = 0;
    for (let i = 0; i < indices.length; i += 3) {
      if (geometry.userData.polygons[i / 3] !== 0) continue;
      const [a, b, c] = [indices[i], indices[i + 1], indices[i + 2]].map(
        (i) => [positions.getX(i), positions.getY(i)],
      );
      area +=
        Math.abs(
          (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0]),
        ) / 2;
    }
    const outline = node.faces[0].map((i) => node.vertices[i]);
    const expected =
      Math.abs(
        outline.reduce((sum, p, i) => {
          const next = outline[(i + 1) % outline.length];
          return sum + p[0] * next[1] - next[0] * p[1];
        }, 0),
      ) / 2;
    assert.ok(Math.abs(area - expected) < 1e-6);
    assert.equal(geometry.userData.polygons.length, indices.length / 3);
    assert.ok(indices.every((i) => i < node.vertices.length));
  } finally {
    geometry.dispose();
  }
});

test("exported mesh has flat normals at every triangle and no viewer helpers", () => {
  const document = kawaikoDocument();
  const root = modelObject(document);
  try {
    assert.equal(root.children.length, document.nodes.length);
    for (const mesh of root.children) {
      const geometry = mesh.geometry;
      assert.equal(geometry.index, null);
      const normals = geometry.getAttribute("normal");
      for (let i = 0; i < normals.count; i += 3) {
        for (const k of ["getX", "getY", "getZ"]) {
          assert.ok(Number.isFinite(normals[k](i)));
          assert.equal(normals[k](i), normals[k](i + 1));
          assert.equal(normals[k](i), normals[k](i + 2));
        }
      }
    }
  } finally {
    disposeObject(root);
  }
});
