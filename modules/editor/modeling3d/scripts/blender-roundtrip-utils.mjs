export function extractInspectionJson(stdout) {
  const lines = stdout.trim().split(/\r?\n/).reverse();
  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed.startsWith("{") || !trimmed.endsWith("}")) continue;
    try {
      return JSON.parse(trimmed);
    } catch {
      continue;
    }
  }
  throw new Error("No JSON object found in Blender stdout");
}

export function resolveBlenderExecutable({
  env = process.env,
  existsSync,
} = {}) {
  const pathEntries = (env.PATH ?? "").split(":").filter(Boolean);
  for (const entry of pathEntries) {
    const candidate = `${entry}/blender`;
    if (existsSync(candidate)) return candidate;
  }
  const macAppBinary = "/Applications/Blender.app/Contents/MacOS/Blender";
  if (existsSync(macAppBinary)) return macAppBinary;
  return null;
}

export function blenderToGltfLocation([x = 0, y = 0, z = 0] = []) {
  return [x, z, -y];
}

export function blenderToGltfScale([x = 1, y = 1, z = 1] = []) {
  return [x, z, y];
}

function approxNumber(a, b, epsilon = 1e-5) {
  return Math.abs(a - b) <= epsilon;
}

function approxVec(actual = [], expected = [], epsilon = 1e-5) {
  if (actual.length !== expected.length) return false;
  for (let i = 0; i < actual.length; i += 1) {
    if (!approxNumber(actual[i] ?? 0, expected[i] ?? 0, epsilon)) return false;
  }
  return true;
}

function gltfNodeColor(gltf, node) {
  const meshes = Array.isArray(gltf.meshes) ? gltf.meshes : [];
  const materials = Array.isArray(gltf.materials) ? gltf.materials : [];
  const mesh = meshes[node?.mesh ?? -1];
  const primitive = mesh?.primitives?.[0];
  const material = materials[primitive?.material ?? -1];
  return material?.pbrMetallicRoughness?.baseColorFactor ?? [1, 1, 1, 1];
}

export function parseGlbJson(glbBuffer) {
  return parseGlb(glbBuffer).json;
}

function parseGlb(glbBuffer) {
  const buffer = Buffer.isBuffer(glbBuffer) ? glbBuffer : Buffer.from(glbBuffer);
  if (buffer.length < 20) {
    throw new Error("GLB is too small");
  }
  if (buffer.toString("utf8", 0, 4) !== "glTF") {
    throw new Error("Invalid GLB magic");
  }
  const version = buffer.readUInt32LE(4);
  if (version !== 2) {
    throw new Error(`Unsupported GLB version: ${version}`);
  }
  const chunks = [];
  let offset = 12;
  let json = null;
  while (offset + 8 <= buffer.length) {
    const chunkLength = buffer.readUInt32LE(offset);
    const chunkType = buffer.toString("ascii", offset + 4, offset + 8);
    const chunkStart = offset + 8;
    const chunkEnd = chunkStart + chunkLength;
    if (chunkEnd > buffer.length) {
      throw new Error("GLB chunk exceeded file length");
    }
    const chunkData = buffer.subarray(chunkStart, chunkEnd);
    chunks.push({ type: chunkType, data: Buffer.from(chunkData) });
    if (chunkType === "JSON") {
      const jsonText = chunkData.toString("utf8").replace(/\0+$/, "").trimEnd();
      json = JSON.parse(jsonText);
    }
    offset = chunkEnd;
  }
  if (json == null) {
    throw new Error("GLB JSON chunk was not found");
  }
  return { json, chunks };
}

function encodeGlb(json, chunks) {
  const jsonBytes = Buffer.from(JSON.stringify(json), "utf8");
  const paddedJsonLength = Math.ceil(jsonBytes.length / 4) * 4;
  const paddedJson = Buffer.alloc(paddedJsonLength, 0x20);
  jsonBytes.copy(paddedJson);
  const serializedChunks = [
    { type: "JSON", data: paddedJson },
    ...chunks.filter((chunk) => chunk.type !== "JSON"),
  ];
  const totalLength =
    12 +
    serializedChunks.reduce((sum, chunk) => {
      const paddedLength = Math.ceil(chunk.data.length / 4) * 4;
      return sum + 8 + paddedLength;
    }, 0);
  const header = Buffer.alloc(12);
  header.write("glTF", 0, 4, "ascii");
  header.writeUInt32LE(2, 4);
  header.writeUInt32LE(totalLength, 8);
  const encodedChunks = serializedChunks.map((chunk) => {
    const paddedLength = Math.ceil(chunk.data.length / 4) * 4;
    const paddedData =
      chunk.data.length === paddedLength
        ? chunk.data
        : Buffer.concat([chunk.data, Buffer.alloc(paddedLength - chunk.data.length)]);
    const chunkHeader = Buffer.alloc(8);
    chunkHeader.writeUInt32LE(paddedData.length, 0);
    chunkHeader.write(chunk.type, 4, 4, "ascii");
    return Buffer.concat([chunkHeader, paddedData]);
  });
  return Buffer.concat([header, ...encodedChunks]);
}

export function copyKaguraRootExtras(sourceGlbBuffer, targetGlbBuffer) {
  const source = parseGlb(sourceGlbBuffer);
  const target = parseGlb(targetGlbBuffer);
  const sourceExtras = source.json?.extras ?? {};
  const targetExtras = target.json?.extras ?? {};
  const mergedKaguraExtras = { ...targetExtras };
  for (const [key, value] of Object.entries(sourceExtras)) {
    if (key.startsWith("kagura_")) {
      mergedKaguraExtras[key] = value;
    }
  }
  target.json.extras = mergedKaguraExtras;
  return encodeGlb(target.json, target.chunks);
}

export function extractExpectedNodesFromGltf(gltf) {
  const extras = gltf?.extras ?? {};
  const nodes = Array.isArray(gltf?.nodes) ? gltf.nodes : [];
  return {
    documentName:
      typeof extras.kagura_document_name === "string" ? extras.kagura_document_name : "",
    nodes: nodes
      .map((node) => {
        const nodeExtras = node?.extras ?? {};
        if (typeof nodeExtras.kagura_source_id !== "string") return null;
        return {
          source_id: nodeExtras.kagura_source_id,
          node_kind:
            typeof nodeExtras.kagura_node_kind === "string"
              ? nodeExtras.kagura_node_kind
              : "",
          primitive_kind:
            typeof nodeExtras.kagura_primitive_kind === "string"
              ? nodeExtras.kagura_primitive_kind
              : null,
          stamp_count:
            typeof nodeExtras.kagura_stamp_count === "number"
              ? nodeExtras.kagura_stamp_count
              : null,
          translation: Array.isArray(node?.translation) ? node.translation : [0, 0, 0],
          scale: Array.isArray(node?.scale) ? node.scale : [1, 1, 1],
          color: gltfNodeColor(gltf, node),
        };
      })
      .filter(Boolean),
  };
}

export function compareInspectionToGltf(inspection, expected, epsilon = 1e-5) {
  const importedObjects = (Array.isArray(inspection?.objects) ? inspection.objects : [])
    .filter((object) => typeof object?.custom_properties?.kagura_source_id === "string")
    .map((object) => ({
      source_id: object.custom_properties.kagura_source_id,
      node_kind:
        typeof object?.custom_properties?.kagura_node_kind === "string"
          ? object.custom_properties.kagura_node_kind
          : "",
      primitive_kind:
        typeof object?.custom_properties?.kagura_primitive_kind === "string"
          ? object.custom_properties.kagura_primitive_kind
          : null,
      stamp_count:
        typeof object?.custom_properties?.kagura_stamp_count === "number"
          ? object.custom_properties.kagura_stamp_count
          : null,
      translation: Array.isArray(object.gltf_space_location)
        ? object.gltf_space_location
        : blenderToGltfLocation(object.location),
      scale: Array.isArray(object.gltf_space_scale)
        ? object.gltf_space_scale
        : blenderToGltfScale(object.scale),
      color: object.materials?.[0]?.base_color ?? [1, 1, 1, 1],
    }));
  const importedById = new Map(importedObjects.map((object) => [object.source_id, object]));
  const expectedById = new Map((expected?.nodes ?? []).map((node) => [node.source_id, node]));
  const missingSourceIds = [];
  const extraSourceIds = [];
  const movedSourceIds = [];
  const rescaledSourceIds = [];
  const colorMismatches = [];
  const nodeKindMismatches = [];
  const primitiveKindMismatches = [];
  const stampCountMismatches = [];
  for (const node of expected?.nodes ?? []) {
    const imported = importedById.get(node.source_id);
    if (!imported) {
      missingSourceIds.push(node.source_id);
      continue;
    }
    if (!approxVec(imported.translation, node.translation, epsilon)) {
      movedSourceIds.push(node.source_id);
    }
    if (!approxVec(imported.scale, node.scale, epsilon)) {
      rescaledSourceIds.push(node.source_id);
    }
    if (!approxVec(imported.color, node.color, epsilon)) {
      colorMismatches.push(node.source_id);
    }
    if ((imported.node_kind ?? "") !== (node.node_kind ?? "")) {
      nodeKindMismatches.push(node.source_id);
    }
    if ((imported.primitive_kind ?? null) !== (node.primitive_kind ?? null)) {
      primitiveKindMismatches.push(node.source_id);
    }
    if ((imported.stamp_count ?? null) !== (node.stamp_count ?? null)) {
      stampCountMismatches.push(node.source_id);
    }
  }
  for (const object of importedObjects) {
    if (!expectedById.has(object.source_id)) {
      extraSourceIds.push(object.source_id);
    }
  }
  return {
    importedDocumentName: inspection?.file ?? "",
    expectedDocumentName: expected?.documentName ?? "",
    recognizedNodeCount: importedObjects.length,
    missingSourceIds,
    extraSourceIds,
    movedSourceIds,
    rescaledSourceIds,
    colorMismatches,
    nodeKindMismatches,
    primitiveKindMismatches,
    stampCountMismatches,
    ok:
      missingSourceIds.length === 0 &&
      extraSourceIds.length === 0 &&
      movedSourceIds.length === 0 &&
      rescaledSourceIds.length === 0 &&
      colorMismatches.length === 0 &&
      nodeKindMismatches.length === 0 &&
      primitiveKindMismatches.length === 0 &&
      stampCountMismatches.length === 0,
  };
}

export function summarizeComparison(comparison) {
  if (comparison?.ok) {
    return "gltf_roundtrip: ok";
  }
  return [
    `gltf_missing: ${comparison?.missingSourceIds?.join(", ") || "-"}`,
    `gltf_extra: ${comparison?.extraSourceIds?.join(", ") || "-"}`,
    `gltf_moved: ${comparison?.movedSourceIds?.join(", ") || "-"}`,
    `gltf_rescaled: ${comparison?.rescaledSourceIds?.join(", ") || "-"}`,
    `gltf_recolored: ${comparison?.colorMismatches?.join(", ") || "-"}`,
    `gltf_node_kind: ${comparison?.nodeKindMismatches?.join(", ") || "-"}`,
    `gltf_primitive_kind: ${comparison?.primitiveKindMismatches?.join(", ") || "-"}`,
    `gltf_stamp_count: ${comparison?.stampCountMismatches?.join(", ") || "-"}`,
  ].join("\n");
}

export function summarizeInspection(report) {
  const objects = Array.isArray(report.objects) ? report.objects : [];
  const materials = Array.isArray(report.materials) ? report.materials : [];
  const objectsMissingKaguraExtras = objects
    .filter((object) => {
      const props = object?.custom_properties ?? {};
      return typeof props.kagura_source_id !== "string";
    })
    .map((object) => object.name);
  const kaguraObjectCount = objects.length - objectsMissingKaguraExtras.length;
  const materialsNotDoubleSided = materials
    .filter((material) => material?.double_sided !== true)
    .map((material) => material.name);
  const lines = [
    `file: ${report.file ?? "(unknown)"}`,
    `objects: ${objects.length}`,
    `materials: ${materials.length}`,
    `kagura_objects: ${kaguraObjectCount}`,
    "transform_space: blender raw + gltf_space_*",
  ];
  if (objectsMissingKaguraExtras.length > 0) {
    lines.push(
      `missing_kagura_extras: ${objectsMissingKaguraExtras.join(", ")}`,
    );
  }
  if (materialsNotDoubleSided.length > 0) {
    lines.push(`materials_not_double_sided: ${materialsNotDoubleSided.join(", ")}`);
  }
  return {
    kaguraObjectCount,
    objectsMissingKaguraExtras,
    materialsNotDoubleSided,
    text: lines.join("\n"),
  };
}
