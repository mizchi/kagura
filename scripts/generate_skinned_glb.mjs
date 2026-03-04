#!/usr/bin/env node
// Generate a test .glb file with a skinned mesh, skeleton, and animation.
// Usage: node scripts/generate_skinned_glb.mjs
//
// Creates a simple 2-bone arm that bends via keyframe animation.
// Output: examples/gltf_viewer/assets/skinned_test.glb

import { writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const OUTPUT = join(
  __dirname,
  "../examples/gltf_viewer/assets/skinned_test.glb"
);

// Build a simple cylinder-like arm mesh along Y axis
// Two segments: lower arm (bone 0) and upper arm (bone 1)
function makeArmMesh() {
  const segments = 8; // around the circumference
  const rings = 5; // along the length
  const radius = 0.15;
  const length = 2.0; // total length
  const ringStep = length / (rings - 1);

  const positions = [];
  const normals = [];
  const texcoords = [];
  const joints = []; // JOINTS_0 (4 per vertex, uint8)
  const weights = []; // WEIGHTS_0 (4 per vertex, float)
  const indices = [];

  // Generate vertices
  for (let ring = 0; ring < rings; ring++) {
    const y = ring * ringStep;
    // Weight blending: 0.0 at y=0 (bone 0), 1.0 at y=length (bone 1)
    const t = y / length;
    // Smooth blend around the joint (at y = length/2)
    let w1;
    if (t <= 0.3) w1 = 0.0;
    else if (t >= 0.7) w1 = 1.0;
    else w1 = (t - 0.3) / 0.4; // linear blend in [0.3, 0.7]

    for (let seg = 0; seg < segments; seg++) {
      const angle = (seg / segments) * Math.PI * 2;
      const nx = Math.cos(angle);
      const nz = Math.sin(angle);
      const px = nx * radius;
      const pz = nz * radius;

      positions.push(px, y, pz);
      normals.push(nx, 0, nz);
      texcoords.push(seg / segments, ring / (rings - 1));

      // Skinning: 2 bones, rest are 0
      joints.push(0, 1, 0, 0);
      weights.push(1.0 - w1, w1, 0.0, 0.0);
    }
  }

  // Generate indices (triangle strip → triangles)
  for (let ring = 0; ring < rings - 1; ring++) {
    for (let seg = 0; seg < segments; seg++) {
      const curr = ring * segments + seg;
      const next = ring * segments + ((seg + 1) % segments);
      const currUp = (ring + 1) * segments + seg;
      const nextUp = (ring + 1) * segments + ((seg + 1) % segments);

      indices.push(curr, next, currUp);
      indices.push(next, nextUp, currUp);
    }
  }

  // Add end caps
  const bottomCenter = positions.length / 3;
  positions.push(0, 0, 0);
  normals.push(0, -1, 0);
  texcoords.push(0.5, 0);
  joints.push(0, 0, 0, 0);
  weights.push(1, 0, 0, 0);

  const topCenter = positions.length / 3;
  positions.push(0, length, 0);
  normals.push(0, 1, 0);
  texcoords.push(0.5, 1);
  joints.push(0, 1, 0, 0);
  weights.push(0, 1, 0, 0);

  // Bottom cap
  for (let seg = 0; seg < segments; seg++) {
    const next = (seg + 1) % segments;
    indices.push(bottomCenter, next, seg);
  }

  // Top cap
  const topRingStart = (rings - 1) * segments;
  for (let seg = 0; seg < segments; seg++) {
    const next = (seg + 1) % segments;
    indices.push(topCenter, topRingStart + seg, topRingStart + next);
  }

  return { positions, normals, texcoords, joints, weights, indices };
}

function buildGlb() {
  const mesh = makeArmMesh();
  const vertexCount = mesh.positions.length / 3;
  const indexCount = mesh.indices.length;

  // Bone 0: root at origin
  // Bone 1: child at y=1.0 (midpoint)
  const boneLength = 1.0;

  // Inverse bind matrices (column-major, 4x4)
  // Bone 0 is at origin → IBM = identity
  const ibm0 = [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1];
  // Bone 1 is at y=1.0 → IBM = translate(0, -1, 0)
  const ibm1 = [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, -boneLength, 0, 1];

  // Animation: bone 1 rotates around Z axis
  // Keyframes: 0s → 0°, 1s → 45°, 2s → 0°, 3s → -45°, 4s → 0°
  const animDuration = 4.0;
  const keyframeTimes = [0.0, 1.0, 2.0, 3.0, 4.0];
  const keyframeAngles = [0, Math.PI / 4, 0, -Math.PI / 4, 0]; // radians around Z
  const keyframeRotations = keyframeAngles.flatMap((angle) => {
    const half = angle / 2;
    return [0, 0, Math.sin(half), Math.cos(half)]; // quaternion (x,y,z,w)
  });

  // Build binary buffer
  const posBytes = vertexCount * 3 * 4;
  const normBytes = vertexCount * 3 * 4;
  const texBytes = vertexCount * 2 * 4;
  const jointBytes = vertexCount * 4; // UNSIGNED_BYTE
  const jointBytesPadded =
    jointBytes % 4 !== 0 ? jointBytes + (4 - (jointBytes % 4)) : jointBytes;
  const weightBytes = vertexCount * 4 * 4; // FLOAT
  const idxBytes = indexCount * 2; // UNSIGNED_SHORT
  const idxBytesPadded =
    idxBytes % 4 !== 0 ? idxBytes + (4 - (idxBytes % 4)) : idxBytes;
  const ibmBytes = 2 * 16 * 4; // 2 bones × 16 floats × 4 bytes
  const animTimeBytes = keyframeTimes.length * 4;
  const animTimeBytesPadded =
    animTimeBytes % 4 !== 0
      ? animTimeBytes + (4 - (animTimeBytes % 4))
      : animTimeBytes;
  const animRotBytes = keyframeRotations.length * 4;

  let offset = 0;
  const bufferViews = [];
  const accessors = [];

  // BV0: positions
  const bv_pos = bufferViews.length;
  bufferViews.push({ buffer: 0, byteOffset: offset, byteLength: posBytes });
  offset += posBytes;

  // BV1: normals
  const bv_norm = bufferViews.length;
  bufferViews.push({ buffer: 0, byteOffset: offset, byteLength: normBytes });
  offset += normBytes;

  // BV2: texcoords
  const bv_tex = bufferViews.length;
  bufferViews.push({ buffer: 0, byteOffset: offset, byteLength: texBytes });
  offset += texBytes;

  // BV3: joints
  const bv_joints = bufferViews.length;
  bufferViews.push({
    buffer: 0,
    byteOffset: offset,
    byteLength: jointBytes,
    byteStride: 4,
  });
  offset += jointBytesPadded;

  // BV4: weights
  const bv_weights = bufferViews.length;
  bufferViews.push({
    buffer: 0,
    byteOffset: offset,
    byteLength: weightBytes,
    byteStride: 16,
  });
  offset += weightBytes;

  // BV5: indices
  const bv_idx = bufferViews.length;
  bufferViews.push({ buffer: 0, byteOffset: offset, byteLength: idxBytes });
  offset += idxBytesPadded;

  // BV6: inverse bind matrices
  const bv_ibm = bufferViews.length;
  bufferViews.push({ buffer: 0, byteOffset: offset, byteLength: ibmBytes });
  offset += ibmBytes;

  // BV7: animation times
  const bv_animTime = bufferViews.length;
  bufferViews.push({
    buffer: 0,
    byteOffset: offset,
    byteLength: animTimeBytes,
  });
  offset += animTimeBytesPadded;

  // BV8: animation rotations
  const bv_animRot = bufferViews.length;
  bufferViews.push({
    buffer: 0,
    byteOffset: offset,
    byteLength: animRotBytes,
  });
  offset += animRotBytes;

  const totalBinSize = offset;

  // AABB for positions
  let minPos = [Infinity, Infinity, Infinity];
  let maxPos = [-Infinity, -Infinity, -Infinity];
  for (let i = 0; i < mesh.positions.length; i += 3) {
    for (let j = 0; j < 3; j++) {
      minPos[j] = Math.min(minPos[j], mesh.positions[i + j]);
      maxPos[j] = Math.max(maxPos[j], mesh.positions[i + j]);
    }
  }

  // ACC0: positions
  const acc_pos = accessors.length;
  accessors.push({
    bufferView: bv_pos,
    componentType: 5126,
    count: vertexCount,
    type: "VEC3",
    min: minPos,
    max: maxPos,
  });

  // ACC1: normals
  const acc_norm = accessors.length;
  accessors.push({
    bufferView: bv_norm,
    componentType: 5126,
    count: vertexCount,
    type: "VEC3",
  });

  // ACC2: texcoords
  const acc_tex = accessors.length;
  accessors.push({
    bufferView: bv_tex,
    componentType: 5126,
    count: vertexCount,
    type: "VEC2",
  });

  // ACC3: joints
  const acc_joints = accessors.length;
  accessors.push({
    bufferView: bv_joints,
    componentType: 5121,
    count: vertexCount,
    type: "VEC4",
  });

  // ACC4: weights
  const acc_weights = accessors.length;
  accessors.push({
    bufferView: bv_weights,
    componentType: 5126,
    count: vertexCount,
    type: "VEC4",
  });

  // ACC5: indices
  const acc_idx = accessors.length;
  accessors.push({
    bufferView: bv_idx,
    componentType: 5123,
    count: indexCount,
    type: "SCALAR",
  });

  // ACC6: inverse bind matrices
  const acc_ibm = accessors.length;
  accessors.push({
    bufferView: bv_ibm,
    componentType: 5126,
    count: 2,
    type: "MAT4",
  });

  // ACC7: animation input (times)
  const acc_animTime = accessors.length;
  accessors.push({
    bufferView: bv_animTime,
    componentType: 5126,
    count: keyframeTimes.length,
    type: "SCALAR",
    min: [0.0],
    max: [animDuration],
  });

  // ACC8: animation output (rotations)
  const acc_animRot = accessors.length;
  accessors.push({
    bufferView: bv_animRot,
    componentType: 5126,
    count: keyframeTimes.length,
    type: "VEC4",
  });

  const gltf = {
    asset: { version: "2.0", generator: "kagura-skinned-test-generator" },
    scene: 0,
    scenes: [{ name: "SkinnedTestScene", nodes: [0] }],
    nodes: [
      {
        name: "ArmMesh",
        mesh: 0,
        skin: 0,
      },
      {
        name: "Bone0_Root",
        children: [2],
        translation: [0, 0, 0],
        rotation: [0, 0, 0, 1],
        scale: [1, 1, 1],
      },
      {
        name: "Bone1_Upper",
        translation: [0, boneLength, 0],
        rotation: [0, 0, 0, 1],
        scale: [1, 1, 1],
      },
    ],
    meshes: [
      {
        name: "Arm",
        primitives: [
          {
            attributes: {
              POSITION: acc_pos,
              NORMAL: acc_norm,
              TEXCOORD_0: acc_tex,
              JOINTS_0: acc_joints,
              WEIGHTS_0: acc_weights,
            },
            indices: acc_idx,
            material: 0,
          },
        ],
      },
    ],
    skins: [
      {
        name: "ArmSkin",
        joints: [1, 2], // node indices for bone 0 and bone 1
        inverseBindMatrices: acc_ibm,
        skeleton: 1,
      },
    ],
    animations: [
      {
        name: "ArmBend",
        channels: [
          {
            sampler: 0,
            target: {
              node: 2, // Bone1_Upper
              path: "rotation",
            },
          },
        ],
        samplers: [
          {
            input: acc_animTime,
            output: acc_animRot,
            interpolation: "LINEAR",
          },
        ],
      },
    ],
    materials: [
      {
        name: "ArmMaterial",
        pbrMetallicRoughness: {
          baseColorFactor: [0.8, 0.6, 0.4, 1.0],
          metallicFactor: 0.1,
          roughnessFactor: 0.7,
        },
      },
    ],
    accessors,
    bufferViews,
    buffers: [{ byteLength: totalBinSize }],
  };

  // Build binary buffer
  const binBuf = new ArrayBuffer(totalBinSize);
  const dataView = new DataView(binBuf);
  let writeOffset = 0;

  // Write positions (float32)
  for (const v of mesh.positions) {
    dataView.setFloat32(writeOffset, v, true);
    writeOffset += 4;
  }

  // Write normals (float32)
  for (const v of mesh.normals) {
    dataView.setFloat32(writeOffset, v, true);
    writeOffset += 4;
  }

  // Write texcoords (float32)
  for (const v of mesh.texcoords) {
    dataView.setFloat32(writeOffset, v, true);
    writeOffset += 4;
  }

  // Write joints (uint8)
  const jointsStart = writeOffset;
  for (const v of mesh.joints) {
    dataView.setUint8(writeOffset, v);
    writeOffset += 1;
  }
  // Pad joints to 4-byte alignment
  while (writeOffset < jointsStart + jointBytesPadded) {
    dataView.setUint8(writeOffset, 0);
    writeOffset += 1;
  }

  // Write weights (float32)
  for (const v of mesh.weights) {
    dataView.setFloat32(writeOffset, v, true);
    writeOffset += 4;
  }

  // Write indices (uint16)
  const idxStart = writeOffset;
  for (const v of mesh.indices) {
    dataView.setUint16(writeOffset, v, true);
    writeOffset += 2;
  }
  // Pad indices to 4-byte alignment
  while (writeOffset < idxStart + idxBytesPadded) {
    dataView.setUint8(writeOffset, 0);
    writeOffset += 1;
  }

  // Write inverse bind matrices (float32, column-major)
  for (const v of ibm0) {
    dataView.setFloat32(writeOffset, v, true);
    writeOffset += 4;
  }
  for (const v of ibm1) {
    dataView.setFloat32(writeOffset, v, true);
    writeOffset += 4;
  }

  // Write animation times (float32)
  const animTimeStart = writeOffset;
  for (const v of keyframeTimes) {
    dataView.setFloat32(writeOffset, v, true);
    writeOffset += 4;
  }
  // Pad animation times
  while (writeOffset < animTimeStart + animTimeBytesPadded) {
    dataView.setUint8(writeOffset, 0);
    writeOffset += 1;
  }

  // Write animation rotations (float32)
  for (const v of keyframeRotations) {
    dataView.setFloat32(writeOffset, v, true);
    writeOffset += 4;
  }

  // Encode JSON
  const jsonStr = JSON.stringify(gltf);
  const jsonBuf = new TextEncoder().encode(jsonStr);
  const jsonPadded =
    jsonBuf.length % 4 !== 0
      ? jsonBuf.length + (4 - (jsonBuf.length % 4))
      : jsonBuf.length;
  const jsonChunk = new Uint8Array(jsonPadded);
  jsonChunk.set(jsonBuf);
  jsonChunk.fill(0x20, jsonBuf.length); // pad with spaces

  // Build GLB
  const totalLength = 12 + 8 + jsonPadded + 8 + totalBinSize;
  const glb = new ArrayBuffer(totalLength);
  const glbView = new DataView(glb);

  // Header
  glbView.setUint32(0, 0x46546c67, true); // "glTF"
  glbView.setUint32(4, 2, true); // version
  glbView.setUint32(8, totalLength, true);

  // JSON chunk
  glbView.setUint32(12, jsonPadded, true);
  glbView.setUint32(16, 0x4e4f534a, true);
  new Uint8Array(glb, 20, jsonPadded).set(jsonChunk);

  // BIN chunk
  const binChunkOffset = 20 + jsonPadded;
  glbView.setUint32(binChunkOffset, totalBinSize, true);
  glbView.setUint32(binChunkOffset + 4, 0x004e4942, true);
  new Uint8Array(glb, binChunkOffset + 8, totalBinSize).set(
    new Uint8Array(binBuf)
  );

  return Buffer.from(glb);
}

const glb = buildGlb();
writeFileSync(OUTPUT, glb);
console.log(`Generated ${OUTPUT} (${glb.length} bytes)`);
