#!/usr/bin/env node
// Generate a test .glb file with 3 colored cubes in a scene hierarchy.
// Usage: node scripts/generate_test_glb.mjs

import { writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const OUTPUT = join(__dirname, "../examples/gltf_viewer/assets/test_scene.glb");

// Cube with each face slightly offset outward along its normal.
// This prevents depth-sorting artifacts from painter's algorithm
// by ensuring adjacent faces don't share edge positions.
function makeCube(epsilon = 0.015) {
  const h = 0.5;
  const corners = [
    [-h, -h, h],
    [h, -h, h],
    [h, h, h],
    [-h, h, h],
    [-h, -h, -h],
    [h, -h, -h],
    [h, h, -h],
    [-h, h, -h],
  ];

  const faces = [
    { verts: [0, 1, 2, 3], normal: [0, 0, 1] },  // front  (+Z)
    { verts: [5, 4, 7, 6], normal: [0, 0, -1] },  // back   (-Z)
    { verts: [4, 0, 3, 7], normal: [-1, 0, 0] },  // left   (-X)
    { verts: [1, 5, 6, 2], normal: [1, 0, 0] },   // right  (+X)
    { verts: [3, 2, 6, 7], normal: [0, 1, 0] },   // top    (+Y)
    { verts: [4, 5, 1, 0], normal: [0, -1, 0] },  // bottom (-Y)
  ];

  const positions = [];
  const normals = [];
  const indices = [];

  for (const face of faces) {
    const base = positions.length / 3;
    const [nx, ny, nz] = face.normal;
    for (const vi of face.verts) {
      const [x, y, z] = corners[vi];
      // Push each vertex slightly outward along face normal
      positions.push(x + nx * epsilon, y + ny * epsilon, z + nz * epsilon);
      normals.push(nx, ny, nz);
    }
    indices.push(base, base + 1, base + 2);
    indices.push(base, base + 2, base + 3);
  }

  return { positions, normals, indices };
}

function buildGlb() {
  const cube = makeCube();
  const vertexCount = cube.positions.length / 3; // 24
  const indexCount = cube.indices.length; // 36

  // Build binary buffer: positions + normals + indices (uint16)
  const posBytes = vertexCount * 3 * 4;
  const normBytes = vertexCount * 3 * 4;
  const idxBytes = indexCount * 2;
  // Pad to 4-byte alignment
  const idxBytesPadded = idxBytes % 4 !== 0 ? idxBytes + (4 - (idxBytes % 4)) : idxBytes;
  const totalBinSize = posBytes + normBytes + idxBytesPadded;

  const binBuf = new ArrayBuffer(totalBinSize);
  const posView = new Float32Array(binBuf, 0, vertexCount * 3);
  const normView = new Float32Array(binBuf, posBytes, vertexCount * 3);
  const idxView = new Uint16Array(binBuf, posBytes + normBytes, indexCount);

  posView.set(cube.positions);
  normView.set(cube.normals);
  idxView.set(cube.indices);

  // Compute AABB for position accessor
  let minPos = [Infinity, Infinity, Infinity];
  let maxPos = [-Infinity, -Infinity, -Infinity];
  for (let i = 0; i < cube.positions.length; i += 3) {
    for (let j = 0; j < 3; j++) {
      minPos[j] = Math.min(minPos[j], cube.positions[i + j]);
      maxPos[j] = Math.max(maxPos[j], cube.positions[i + j]);
    }
  }

  // glTF JSON - 3 cubes with different colors, under a root node
  const gltf = {
    asset: { version: "2.0", generator: "kagura-test-generator" },
    scene: 0,
    scenes: [{ name: "TestScene", nodes: [0] }],
    nodes: [
      { name: "Root", children: [1, 2, 3] },
      { name: "RedCube", mesh: 0, translation: [-2, 0.5, 0], material: undefined },
      { name: "GreenCube", mesh: 0, translation: [0, 0.5, 0], material: undefined },
      { name: "BlueCube", mesh: 0, translation: [2, 0.5, 0], material: undefined },
    ],
    meshes: [
      {
        name: "Cube",
        primitives: [
          {
            attributes: { POSITION: 0, NORMAL: 1 },
            indices: 2,
            material: undefined, // will be set per-node via separate meshes
          },
        ],
      },
    ],
    accessors: [
      {
        bufferView: 0,
        componentType: 5126,
        count: vertexCount,
        type: "VEC3",
        min: minPos,
        max: maxPos,
      },
      {
        bufferView: 1,
        componentType: 5126,
        count: vertexCount,
        type: "VEC3",
      },
      {
        bufferView: 2,
        componentType: 5123,
        count: indexCount,
        type: "SCALAR",
      },
    ],
    bufferViews: [
      { buffer: 0, byteOffset: 0, byteLength: posBytes },
      { buffer: 0, byteOffset: posBytes, byteLength: normBytes },
      { buffer: 0, byteOffset: posBytes + normBytes, byteLength: idxBytes },
    ],
    buffers: [{ byteLength: totalBinSize }],
    materials: [
      {
        name: "Red",
        pbrMetallicRoughness: {
          baseColorFactor: [0.9, 0.15, 0.15, 1.0],
          metallicFactor: 0.1,
          roughnessFactor: 0.8,
        },
      },
      {
        name: "Green",
        pbrMetallicRoughness: {
          baseColorFactor: [0.15, 0.8, 0.2, 1.0],
          metallicFactor: 0.1,
          roughnessFactor: 0.8,
        },
      },
      {
        name: "Blue",
        pbrMetallicRoughness: {
          baseColorFactor: [0.15, 0.3, 0.9, 1.0],
          metallicFactor: 0.1,
          roughnessFactor: 0.8,
        },
      },
    ],
  };

  // Use 3 separate meshes so each node gets its own material
  gltf.meshes = [
    {
      name: "RedCube",
      primitives: [{ attributes: { POSITION: 0, NORMAL: 1 }, indices: 2, material: 0 }],
    },
    {
      name: "GreenCube",
      primitives: [{ attributes: { POSITION: 0, NORMAL: 1 }, indices: 2, material: 1 }],
    },
    {
      name: "BlueCube",
      primitives: [{ attributes: { POSITION: 0, NORMAL: 1 }, indices: 2, material: 2 }],
    },
  ];
  gltf.nodes[1].mesh = 0;
  gltf.nodes[2].mesh = 1;
  gltf.nodes[3].mesh = 2;

  // Encode JSON
  const jsonStr = JSON.stringify(gltf);
  const jsonBuf = new TextEncoder().encode(jsonStr);
  // Pad JSON to 4-byte alignment with spaces
  const jsonPadded = jsonBuf.length % 4 !== 0 ? jsonBuf.length + (4 - (jsonBuf.length % 4)) : jsonBuf.length;
  const jsonChunk = new Uint8Array(jsonPadded);
  jsonChunk.set(jsonBuf);
  jsonChunk.fill(0x20, jsonBuf.length); // pad with spaces

  // Build GLB
  const totalLength = 12 + 8 + jsonPadded + 8 + totalBinSize;
  const glb = new ArrayBuffer(totalLength);
  const view = new DataView(glb);

  // Header
  view.setUint32(0, 0x46546c67, true); // magic "glTF"
  view.setUint32(4, 2, true); // version
  view.setUint32(8, totalLength, true);

  // JSON chunk
  view.setUint32(12, jsonPadded, true); // chunk length
  view.setUint32(16, 0x4e4f534a, true); // chunk type
  new Uint8Array(glb, 20, jsonPadded).set(jsonChunk);

  // BIN chunk
  const binOffset = 20 + jsonPadded;
  view.setUint32(binOffset, totalBinSize, true);
  view.setUint32(binOffset + 4, 0x004e4942, true);
  new Uint8Array(glb, binOffset + 8, totalBinSize).set(new Uint8Array(binBuf));

  return Buffer.from(glb);
}

const glb = buildGlb();
writeFileSync(OUTPUT, glb);
console.log(`Generated ${OUTPUT} (${glb.length} bytes)`);
