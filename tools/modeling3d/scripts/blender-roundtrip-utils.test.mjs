import test from "node:test";
import assert from "node:assert/strict";

import {
  copyKaguraRootExtras,
  compareInspectionToGltf,
  blenderToGltfLocation,
  blenderToGltfScale,
  extractExpectedNodesFromGltf,
  extractInspectionJson,
  parseGlbJson,
  resolveBlenderExecutable,
  summarizeComparison,
  summarizeInspection,
} from "./blender-roundtrip-utils.mjs";

test("extractInspectionJson reads trailing JSON from blender stdout", () => {
  const stdout = [
    "Blender 4.1.0",
    "Read prefs: /tmp/fake",
    '{"file":"model.glb","objects":[{"name":"pedestal","custom_properties":{"kagura_source_id":"pedestal"}}],"materials":[]}',
    "",
  ].join("\n");

  assert.deepEqual(extractInspectionJson(stdout), {
    file: "model.glb",
    objects: [
      {
        name: "pedestal",
        custom_properties: { kagura_source_id: "pedestal" },
      },
    ],
    materials: [],
  });
});

test("summarizeInspection reports kagura coverage and missing metadata", () => {
  const summary = summarizeInspection({
    file: "model.glb",
    objects: [
      {
        name: "pedestal",
        custom_properties: {
          kagura_source_id: "pedestal",
          kagura_node_kind: "primitive",
        },
        materials: [
          {
            name: "pedestal_mat",
            double_sided: true,
            metallic: 0,
            roughness: 0.85,
          },
        ],
      },
      {
        name: "plain_mesh",
        custom_properties: {},
        materials: [],
      },
    ],
    materials: [
      {
        name: "pedestal_mat",
        double_sided: true,
        metallic: 0,
        roughness: 0.85,
      },
    ],
  });

  assert.equal(summary.kaguraObjectCount, 1);
  assert.deepEqual(summary.objectsMissingKaguraExtras, ["plain_mesh"]);
  assert.deepEqual(summary.materialsNotDoubleSided, []);
  assert.match(summary.text, /kagura_objects: 1/);
  assert.match(summary.text, /missing_kagura_extras: plain_mesh/);
});

test("resolveBlenderExecutable prefers PATH and falls back to macOS app binary", () => {
  const seen = [];
  const fakeExistsSync = (path) => {
    seen.push(path);
    return (
      path === "/custom/bin/blender" ||
      path === "/Applications/Blender.app/Contents/MacOS/Blender"
    );
  };

  assert.equal(
    resolveBlenderExecutable({
      env: { PATH: "/custom/bin:/usr/bin" },
      existsSync: fakeExistsSync,
    }),
    "/custom/bin/blender",
  );

  assert.equal(
    resolveBlenderExecutable({
      env: { PATH: "/missing/bin" },
      existsSync: (path) =>
        path === "/Applications/Blender.app/Contents/MacOS/Blender",
    }),
    "/Applications/Blender.app/Contents/MacOS/Blender",
  );

  assert.equal(
    resolveBlenderExecutable({
      env: { PATH: "/missing/bin" },
      existsSync: () => false,
    }),
    null,
  );

  assert.ok(seen.includes("/custom/bin/blender"));
});

test("blenderToGltf helpers undo Blender's Y-up to Z-up object transform", () => {
  assert.deepEqual(blenderToGltfLocation([0.55, 0.55, 0.95]), [0.55, 0.95, -0.55]);
  assert.deepEqual(blenderToGltfScale([0.9, 0.9, 0.35]), [0.9, 0.35, 0.9]);
});

function createJsonOnlyGlb(json) {
  const jsonBytes = Buffer.from(JSON.stringify(json), "utf8");
  const paddedJsonLength = Math.ceil(jsonBytes.length / 4) * 4;
  const jsonChunk = Buffer.alloc(paddedJsonLength, 0x20);
  jsonBytes.copy(jsonChunk);
  const totalLength = 12 + 8 + paddedJsonLength;
  const header = Buffer.alloc(12);
  header.write("glTF", 0, 4, "ascii");
  header.writeUInt32LE(2, 4);
  header.writeUInt32LE(totalLength, 8);
  const chunkHeader = Buffer.alloc(8);
  chunkHeader.writeUInt32LE(paddedJsonLength, 0);
  chunkHeader.write("JSON", 4, 4, "ascii");
  return Buffer.concat([header, chunkHeader, jsonChunk]);
}

test("parseGlbJson reads the JSON chunk from a GLB buffer", () => {
  const glb = createJsonOnlyGlb({
    asset: { version: "2.0" },
    extras: { kagura_document_name: "vlm_clay_totem" },
  });
  assert.deepEqual(parseGlbJson(glb), {
    asset: { version: "2.0" },
    extras: { kagura_document_name: "vlm_clay_totem" },
  });
});

test("copyKaguraRootExtras restores document extras without touching edited nodes", () => {
  const source = createJsonOnlyGlb({
    asset: { version: "2.0" },
    extras: { kagura_document_name: "vlm_clay_totem", unrelated: "keep-source-local" },
    nodes: [
      {
        translation: [0, -0.25, 0],
        extras: { kagura_source_id: "pedestal" },
      },
    ],
  });
  const target = createJsonOnlyGlb({
    asset: { version: "2.0" },
    extras: { blender_export: true },
    nodes: [
      {
        translation: [0.2, -0.25, 0],
        extras: { kagura_source_id: "pedestal" },
      },
    ],
  });

  const patched = parseGlbJson(copyKaguraRootExtras(source, target));
  assert.deepEqual(patched.extras, {
    blender_export: true,
    kagura_document_name: "vlm_clay_totem",
  });
  assert.deepEqual(patched.nodes[0].translation, [0.2, -0.25, 0]);
});

test("extractExpectedNodesFromGltf reads Kagura extras and material colors", () => {
  const expected = extractExpectedNodesFromGltf({
    extras: { kagura_document_name: "vlm_clay_totem" },
    nodes: [
      {
        mesh: 0,
        translation: [0, -0.25, 0],
        scale: [0.9, 0.35, 0.9],
        extras: {
          kagura_source_id: "pedestal",
          kagura_node_kind: "primitive",
          kagura_primitive_kind: "cube",
        },
      },
    ],
    meshes: [{ primitives: [{ material: 0 }] }],
    materials: [
      {
        pbrMetallicRoughness: {
          baseColorFactor: [0.317647, 0.380392, 0.478431, 1],
        },
      },
    ],
  });
  assert.equal(expected.documentName, "vlm_clay_totem");
  assert.deepEqual(expected.nodes, [
    {
      source_id: "pedestal",
      node_kind: "primitive",
      primitive_kind: "cube",
      stamp_count: null,
      translation: [0, -0.25, 0],
      scale: [0.9, 0.35, 0.9],
      color: [0.317647, 0.380392, 0.478431, 1],
    },
  ]);
});

test("compareInspectionToGltf normalizes Blender object transforms before diffing", () => {
  const comparison = compareInspectionToGltf(
    {
      file: "vlm-clay-totem.glb",
      objects: [
        {
          name: "guide_orb",
          location: [0.55, 0.55, 0.95],
          scale: [0.18, 0.18, 0.18],
          custom_properties: {
            kagura_source_id: "guide_orb",
            kagura_node_kind: "primitive",
            kagura_primitive_kind: "sphere",
          },
          materials: [
            {
              base_color: [0.435294, 0.780392, 1, 1],
            },
          ],
        },
      ],
    },
    {
      documentName: "vlm_clay_totem",
      nodes: [
        {
          source_id: "guide_orb",
          node_kind: "primitive",
          primitive_kind: "sphere",
          stamp_count: null,
          translation: [0.55, 0.95, -0.55],
          scale: [0.18, 0.18, 0.18],
          color: [0.435294, 0.780392, 1, 1],
        },
      ],
    },
  );
  assert.equal(comparison.ok, true);
  assert.deepEqual(comparison.movedSourceIds, []);
  assert.deepEqual(comparison.rescaledSourceIds, []);
  assert.deepEqual(comparison.colorMismatches, []);
  assert.deepEqual(comparison.nodeKindMismatches, []);
  assert.deepEqual(comparison.primitiveKindMismatches, []);
  assert.deepEqual(comparison.stampCountMismatches, []);
});

test("compareInspectionToGltf reports moved and recolored nodes", () => {
  const comparison = compareInspectionToGltf(
    {
      file: "vlm-clay-totem.glb",
      objects: [
        {
          name: "pedestal",
          gltf_space_location: [0.2, -0.25, 0],
          gltf_space_scale: [0.9, 0.35, 0.9],
          custom_properties: {
            kagura_source_id: "pedestal",
            kagura_node_kind: "primitive",
            kagura_primitive_kind: "cube",
          },
          materials: [
            {
              base_color: [1, 0, 0, 1],
            },
          ],
        },
      ],
    },
    {
      documentName: "vlm_clay_totem",
      nodes: [
        {
          source_id: "pedestal",
          node_kind: "primitive",
          primitive_kind: "cube",
          stamp_count: null,
          translation: [0, -0.25, 0],
          scale: [0.9, 0.35, 0.9],
          color: [0.317647, 0.380392, 0.478431, 1],
        },
      ],
    },
  );
  assert.equal(comparison.ok, false);
  assert.deepEqual(comparison.movedSourceIds, ["pedestal"]);
  assert.deepEqual(comparison.colorMismatches, ["pedestal"]);
});

test("compareInspectionToGltf reports extra missing and metadata mismatches", () => {
  const comparison = compareInspectionToGltf(
    {
      file: "vlm-clay-totem-edited.glb",
      objects: [
        {
          name: "pedestal",
          gltf_space_location: [0, -0.25, 0],
          gltf_space_scale: [0.9, 0.35, 0.9],
          custom_properties: {
            kagura_source_id: "pedestal",
            kagura_node_kind: "primitive",
            kagura_primitive_kind: "sphere",
          },
          materials: [{ base_color: [0.317647, 0.380392, 0.478431, 1] }],
        },
        {
          name: "clay_head",
          gltf_space_location: [0, 0, 0],
          gltf_space_scale: [1, 1, 1],
          custom_properties: {
            kagura_source_id: "clay_head",
            kagura_node_kind: "sculpt_layer",
            kagura_stamp_count: 7,
          },
          materials: [{ base_color: [0.85098, 0.560784, 0.439216, 1] }],
        },
        {
          name: "blender_helper",
          gltf_space_location: [1.2, 0, 0],
          gltf_space_scale: [0.2, 0.2, 0.2],
          custom_properties: {
            kagura_source_id: "blender_helper",
            kagura_node_kind: "primitive",
            kagura_primitive_kind: "cube",
          },
          materials: [{ base_color: [0.666667, 0.666667, 0.666667, 1] }],
        },
      ],
    },
    {
      documentName: "vlm_clay_totem",
      nodes: [
        {
          source_id: "pedestal",
          node_kind: "primitive",
          primitive_kind: "cube",
          stamp_count: null,
          translation: [0, -0.25, 0],
          scale: [0.9, 0.35, 0.9],
          color: [0.317647, 0.380392, 0.478431, 1],
        },
        {
          source_id: "guide_orb",
          node_kind: "primitive",
          primitive_kind: "sphere",
          stamp_count: null,
          translation: [0.55, 0.95, -0.55],
          scale: [0.18, 0.18, 0.18],
          color: [0.435294, 0.780392, 1, 1],
        },
        {
          source_id: "clay_head",
          node_kind: "sculpt_layer",
          primitive_kind: null,
          stamp_count: 6,
          translation: [0, 0, 0],
          scale: [1, 1, 1],
          color: [0.85098, 0.560784, 0.439216, 1],
        },
      ],
    },
  );
  assert.equal(comparison.ok, false);
  assert.deepEqual(comparison.missingSourceIds, ["guide_orb"]);
  assert.deepEqual(comparison.extraSourceIds, ["blender_helper"]);
  assert.deepEqual(comparison.primitiveKindMismatches, ["pedestal"]);
  assert.deepEqual(comparison.stampCountMismatches, ["clay_head"]);
});

test("summarizeComparison renders a compact roundtrip diff summary", () => {
  assert.equal(
    summarizeComparison({
      ok: true,
      missingSourceIds: [],
      extraSourceIds: [],
      movedSourceIds: [],
      rescaledSourceIds: [],
      colorMismatches: [],
      nodeKindMismatches: [],
      primitiveKindMismatches: [],
      stampCountMismatches: [],
    }),
    "gltf_roundtrip: ok",
  );

  assert.equal(
    summarizeComparison({
      ok: false,
      missingSourceIds: ["guide_orb"],
      extraSourceIds: [],
      movedSourceIds: ["pedestal"],
      rescaledSourceIds: ["clay_head"],
      colorMismatches: ["pedestal"],
      nodeKindMismatches: ["guide_orb"],
      primitiveKindMismatches: ["pedestal"],
      stampCountMismatches: ["clay_head"],
    }),
    [
      "gltf_missing: guide_orb",
      "gltf_extra: -",
      "gltf_moved: pedestal",
      "gltf_rescaled: clay_head",
      "gltf_recolored: pedestal",
      "gltf_node_kind: guide_orb",
      "gltf_primitive_kind: pedestal",
      "gltf_stamp_count: clay_head",
    ].join("\n"),
  );
});
