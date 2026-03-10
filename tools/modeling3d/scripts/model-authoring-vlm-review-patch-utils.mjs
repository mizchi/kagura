function vec3(input, fallback = [0, 0, 0]) {
  if (!Array.isArray(input)) return fallback;
  return [
    Number(input[0] ?? fallback[0]),
    Number(input[1] ?? fallback[1]),
    Number(input[2] ?? fallback[2]),
  ];
}

function vec3MoonBit(input) {
  const [x, y, z] = vec3(input);
  return `@math3d.Vec3::new(${x}, ${y}, ${z})`;
}

function mentionIds(text) {
  if (typeof text !== "string") return [];
  const matches = text.toLowerCase().match(/\b[a-z][a-z0-9]*(?:_[a-z0-9]+)+\b/g);
  if (matches == null) return [];
  return [...new Set(matches)];
}

function primitiveIndex(bundle, sourceId) {
  return (bundle?.current_document?.primitives ?? []).findIndex(
    (primitive) => primitive?.id === sourceId,
  );
}

function primitiveById(bundle, sourceId) {
  return (bundle?.current_document?.primitives ?? []).find(
    (primitive) => primitive?.id === sourceId,
  ) ?? null;
}

function primitiveTopY(primitive) {
  const [, y] = vec3(primitive?.position);
  const [, sy] = vec3(primitive?.scale, [1, 1, 1]);
  return y + sy * 0.5;
}

function primitiveBottomY(primitive) {
  const [, y] = vec3(primitive?.position);
  const [, sy] = vec3(primitive?.scale, [1, 1, 1]);
  return y - sy * 0.5;
}

function footprintContains(support, target) {
  const [sx, , sz] = vec3(support?.position);
  const [ssx, , ssz] = vec3(support?.scale, [1, 1, 1]);
  const [tx, , tz] = vec3(target?.position);
  return (
    Math.abs(tx - sx) <= ssx * 0.5 + 1.0e-6 &&
    Math.abs(tz - sz) <= ssz * 0.5 + 1.0e-6
  );
}

function nearestSupportPrimitive(bundle, sourceId) {
  const target = primitiveById(bundle, sourceId);
  if (target == null) return null;
  const targetBottom = primitiveBottomY(target);
  const supports = (bundle?.current_document?.primitives ?? [])
    .filter((primitive) => primitive?.id !== sourceId)
    .filter((primitive) => primitive?.kind === "cube" || primitive?.kind === "plane")
    .filter((primitive) => footprintContains(primitive, target))
    .filter((primitive) => primitiveTopY(primitive) <= targetBottom + 0.08)
    .sort((left, right) => primitiveTopY(right) - primitiveTopY(left));
  return supports[0] ?? null;
}

function relatedPeerIds(review, sourceId) {
  const texts = [];
  for (const item of review?.manual_followups ?? []) {
    if (item?.source_id === sourceId) {
      texts.push(item?.next_step, item?.rationale);
    }
  }
  for (const item of review?.visual_findings ?? []) {
    if (item?.source_id === sourceId) {
      texts.push(item?.observation, item?.impact);
    }
  }
  const ids = new Set();
  for (const text of texts) {
    for (const id of mentionIds(text)) {
      if (id !== sourceId && id !== "scene") {
        ids.add(id);
      }
    }
  }
  return [...ids];
}

function alignmentRelevant(review, sourceId) {
  return (review?.manual_followups ?? []).some(
    (item) => item?.source_id === sourceId && item?.issue_kind === "review_alignment",
  );
}

function overlapRelevant(review, sourceId) {
  return (review?.manual_followups ?? []).some(
    (item) => item?.source_id === sourceId && item?.issue_kind === "review_overlap",
  );
}

function computeAlignedPosition(bundle, review, sourceId) {
  const primitive = primitiveById(bundle, sourceId);
  if (primitive == null) return null;
  let [x, y, z] = vec3(primitive.position);
  const notes = [];

  const support = nearestSupportPrimitive(bundle, sourceId);
  if (support != null) {
    const [, sy] = vec3(primitive.scale, [1, 1, 1]);
    y = primitiveTopY(support) + sy * 0.5;
    notes.push(`snap_to_plane:${support.id}`);
  }

  const peerIds = relatedPeerIds(review, sourceId);
  if (peerIds.length > 0) {
    const peer = primitiveById(bundle, peerIds[0]);
    if (peer != null) {
      const [, py, pz] = vec3(peer.position);
      if (support == null) {
        y = py;
        notes.push(`equalize_height:${peer.id}`);
      }
      const currentSign = Math.sign(z);
      if (currentSign === 0) {
        z = pz;
      } else {
        z = currentSign * Math.abs(pz);
      }
      notes.push(`equalize_spacing:${peer.id}`);
    }
  }

  if (notes.length === 0) return null;
  return {
    sourceId,
    index: primitiveIndex(bundle, sourceId),
    position: [x, y, z],
    notes,
  };
}

function computeOverlapPosition(bundle, review, sourceId) {
  const primitive = primitiveById(bundle, sourceId);
  if (primitive == null) return null;
  const peers = relatedPeerIds(review, sourceId)
    .map((peerId) => primitiveById(bundle, peerId))
    .filter(Boolean);
  if (peers.length === 0) return null;
  const [x, y, z] = vec3(primitive.position);
  const [, , sz] = vec3(primitive.scale, [1, 1, 1]);
  const peer = peers[0];
  const [, , pz] = vec3(peer.position);
  const [, , psz] = vec3(peer.scale, [1, 1, 1]);
  const direction = Math.sign(z - pz) || Math.sign(z) || 1;
  return {
    sourceId,
    index: primitiveIndex(bundle, sourceId),
    position: [x, y, pz + direction * (Math.abs(psz) + Math.abs(sz)) * 0.55],
    notes: [`separate_overlap:${peer.id}`],
  };
}

function deterministicFixes(bundle, review) {
  const ids = new Set([
    ...(review?.manual_followups ?? []).map((item) => item?.source_id),
  ]);
  const fixes = [];
  for (const sourceId of ids) {
    if (typeof sourceId !== "string" || sourceId.length === 0) continue;
    let fix = null;
    if (alignmentRelevant(review, sourceId)) {
      fix = computeAlignedPosition(bundle, review, sourceId);
    } else if (overlapRelevant(review, sourceId)) {
      fix = computeOverlapPosition(bundle, review, sourceId);
    }
    if (fix != null && fix.index >= 0) {
      fixes.push(fix);
    }
  }
  return fixes.sort((left, right) => left.index - right.index);
}

export function buildReviewDrivenMoonBitPatch(bundle, review) {
  const fixes = deterministicFixes(bundle, review);
  const lines = ["fn apply_vlm_review_patch(doc : ModelDocument) -> ModelDocument {"];
  if (fixes.length === 0) {
    lines.push("  doc");
    lines.push("}");
    lines.push("");
    lines.push("// No deterministic review-driven fixes.");
    return `${lines.join("\n")}\n`;
  }
  lines.push("  let primitives = doc.primitives.copy()");
  for (const fix of fixes) {
    lines.push(`  // ${fix.notes.join(", ")}`);
    lines.push(`  primitives[${fix.index}] = {`);
    lines.push(`    ..primitives[${fix.index}],`);
    lines.push(`    position: ${vec3MoonBit(fix.position)},`);
    lines.push("  }");
  }
  lines.push("  { ..doc, primitives }");
  lines.push("}");
  return `${lines.join("\n")}\n`;
}
