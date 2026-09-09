function normalizeColorHex(input) {
  if (typeof input !== "string") return null;
  const trimmed = input.trim();
  if (trimmed.length === 0) return null;
  if (trimmed.startsWith("#")) {
    return `0x${trimmed.slice(1).toUpperCase()}`;
  }
  if (/^0x/i.test(trimmed)) {
    return `0x${trimmed.slice(2).toUpperCase()}`;
  }
  return null;
}

function primitiveKindMoonBitName(input) {
  switch ((input ?? "").toLowerCase()) {
    case "cube":
      return "Cube";
    case "sphere":
      return "Sphere";
    case "plane":
      return "Plane";
    default:
      throw new Error(`unsupported primitive kind: ${input}`);
  }
}

function vec3MoonBit(input) {
  const [x = 0, y = 0, z = 0] = Array.isArray(input) ? input : [];
  return `@math3d.Vec3::new(${x}, ${y}, ${z})`;
}

function currentPrimitiveIndex(bundle, sourceId) {
  return (bundle.current_document?.primitives ?? []).findIndex(
    (primitive) => primitive?.id === sourceId,
  );
}

function currentSculptLayerIndex(bundle, sourceId) {
  return (bundle.current_document?.sculpt_layers ?? []).findIndex(
    (layer) => layer?.id === sourceId,
  );
}

function remainingManualIssues(bundle, coveredSourceIds) {
  return (bundle.patch_payload?.manual_issue_details ?? []).filter(
    (issue) => !coveredSourceIds.has(issue?.source_id),
  );
}

function buildPrimitiveUpdates(bundle) {
  const updates = new Map();
  for (const action of bundle.patch_payload?.auto_actions ?? []) {
    if (action?.target_kind !== "primitive") continue;
    const index = currentPrimitiveIndex(bundle, action.source_id);
    if (index < 0) continue;
    const current = updates.get(index) ?? { sourceId: action.source_id };
    switch (action.action_kind) {
      case "set_position":
        current.position = action.target_position;
        break;
      case "set_scale":
        current.scale = action.target_scale;
        break;
      case "set_color":
        current.colorHex = normalizeColorHex(action.target_color_hex);
        break;
      case "set_primitive_kind":
        current.kind = primitiveKindMoonBitName(action.target_text);
        break;
      default:
        break;
    }
    updates.set(index, current);
  }
  return [...updates.entries()].sort((a, b) => a[0] - b[0]);
}

function buildSculptLayerUpdates(bundle) {
  const updates = new Map();
  for (const action of bundle.patch_payload?.auto_actions ?? []) {
    if (action?.target_kind !== "sculpt_layer") continue;
    const index = currentSculptLayerIndex(bundle, action.source_id);
    if (index < 0) continue;
    const current = updates.get(index) ?? { sourceId: action.source_id };
    switch (action.action_kind) {
      case "set_color":
        current.colorHex = normalizeColorHex(action.target_color_hex);
        break;
      default:
        break;
    }
    updates.set(index, current);
  }
  return [...updates.entries()].sort((a, b) => a[0] - b[0]);
}

function buildRemoveOperations(bundle) {
  return (bundle.patch_payload?.opt_in_remove_source_ids ?? [])
    .map((sourceId) => ({ sourceId, index: currentPrimitiveIndex(bundle, sourceId) }))
    .filter((operation) => operation.index >= 0)
    .sort((a, b) => b.index - a.index);
}

function buildAppendOperations(bundle) {
  const appendSourceIds = new Set(bundle.patch_payload?.opt_in_append_source_ids ?? []);
  return (bundle.patch_payload?.manual_issue_details ?? [])
    .filter(
      (issue) =>
        appendSourceIds.has(issue?.source_id) &&
        issue?.action_kind === "review_extra" &&
        issue?.target_kind === "primitive",
    )
    .map((issue) => ({
      sourceId: issue.source_id,
      kind: primitiveKindMoonBitName(issue.imported_primitive_kind),
      position: issue.imported_position ?? [0, 0, 0],
      scale: issue.imported_scale ?? [1, 1, 1],
      colorHex: normalizeColorHex(issue.imported_color_hex) ?? "0xFFFFFF",
    }));
}

function appendManualComments(lines, issues) {
  if (issues.length === 0) return;
  lines.push("");
  lines.push("// Manual review");
  for (const issue of issues) {
    const suggested = typeof issue?.suggested_moonbit === "string"
      ? issue.suggested_moonbit.trim()
      : "";
    if (suggested.length > 0) {
      lines.push(...suggested.split("\n"));
    } else if (typeof issue?.summary === "string" && issue.summary.length > 0) {
      lines.push(`// ${issue.summary}`);
    }
  }
}

export function buildOptInMoonBitPatch(bundle) {
  if (bundle?.current_document == null || bundle?.patch_payload == null) {
    throw new Error("bundle.current_document and bundle.patch_payload are required");
  }

  const primitiveUpdates = buildPrimitiveUpdates(bundle);
  const sculptLayerUpdates = buildSculptLayerUpdates(bundle);
  const removeOperations = buildRemoveOperations(bundle);
  const appendOperations = buildAppendOperations(bundle);
  const coveredSourceIds = new Set([
    ...removeOperations.map((operation) => operation.sourceId),
    ...appendOperations.map((operation) => operation.sourceId),
  ]);
  const manualIssues = remainingManualIssues(bundle, coveredSourceIds);

  const lines = [
    "fn apply_imported_patch(doc : ModelDocument) -> ModelDocument {",
  ];
  const needsPrimitives =
    primitiveUpdates.length > 0 ||
    removeOperations.length > 0 ||
    appendOperations.length > 0;
  const needsSculptLayers = sculptLayerUpdates.length > 0;

  if (needsPrimitives) {
    lines.push("  let primitives = doc.primitives.copy()");
    for (const [index, update] of primitiveUpdates) {
      lines.push(`  primitives[${index}] = {`);
      lines.push(`    ..primitives[${index}],`);
      if (update.kind != null) {
        lines.push(`    kind: ${update.kind},`);
      }
      if (update.position != null) {
        lines.push(`    position: ${vec3MoonBit(update.position)},`);
      }
      if (update.scale != null) {
        lines.push(`    scale: ${vec3MoonBit(update.scale)},`);
      }
      if (update.colorHex != null) {
        lines.push(`    color_hex: ${update.colorHex},`);
      }
      lines.push("  }");
    }
    for (const operation of removeOperations) {
      lines.push(`  ignore(primitives.remove(${operation.index}))`);
    }
    for (const operation of appendOperations) {
      lines.push("  primitives.push({");
      lines.push(`    id: "${operation.sourceId}",`);
      lines.push(`    kind: ${operation.kind},`);
      lines.push(`    position: ${vec3MoonBit(operation.position)},`);
      lines.push(`    scale: ${vec3MoonBit(operation.scale)},`);
      lines.push(`    color_hex: ${operation.colorHex},`);
      lines.push("  })");
    }
  }

  if (needsSculptLayers) {
    lines.push("  let sculpt_layers = doc.sculpt_layers.copy()");
    for (const [index, update] of sculptLayerUpdates) {
      lines.push(`  sculpt_layers[${index}] = {`);
      lines.push(`    ..sculpt_layers[${index}],`);
      if (update.colorHex != null) {
        lines.push(`    color_hex: ${update.colorHex},`);
      }
      lines.push("  }");
    }
  }

  if (!needsPrimitives && !needsSculptLayers) {
    lines.push("  doc");
  } else {
    const returnParts = [];
    if (needsPrimitives) returnParts.push("primitives");
    if (needsSculptLayers) returnParts.push("sculpt_layers");
    lines.push(`  { ..doc, ${returnParts.join(", ")} }`);
  }
  lines.push("}");

  appendManualComments(lines, manualIssues);
  return `${lines.join("\n")}\n`;
}
