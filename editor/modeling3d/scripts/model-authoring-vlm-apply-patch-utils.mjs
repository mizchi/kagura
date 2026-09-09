const PATCH_START_MARKER = "// VLM_ROUNDTRIP_PATCH_START";
const PATCH_END_MARKER = "// VLM_ROUNDTRIP_PATCH_END";
const DEFAULT_MODEL_DOC_SIGNATURE = "fn default_model_document() -> ModelDocument {";
const PATCH_SIGNATURE = "fn apply_imported_patch(doc : ModelDocument) -> ModelDocument {";
const STAGE_PREFIX = "apply_imported_patch_stage_";

function findMatchingBrace(source, openBraceIndex) {
  let depth = 0;
  for (let index = openBraceIndex; index < source.length; index += 1) {
    const char = source[index];
    if (char === "{") {
      depth += 1;
    } else if (char === "}") {
      depth -= 1;
      if (depth === 0) {
        return index;
      }
    }
  }
  throw new Error("could not find matching brace");
}

function indentBlock(text, indent) {
  return text
    .split("\n")
    .map((line) => `${indent}${line}`)
    .join("\n");
}

function wrapDefaultModelDocument(source) {
  const signatureIndex = source.indexOf(DEFAULT_MODEL_DOC_SIGNATURE);
  if (signatureIndex < 0) {
    throw new Error("default_model_document() was not found");
  }
  const functionOpenBraceIndex =
    signatureIndex + DEFAULT_MODEL_DOC_SIGNATURE.length - 1;
  const functionCloseBraceIndex = findMatchingBrace(source, functionOpenBraceIndex);
  const bodyStart = functionOpenBraceIndex + 1;
  const bodyEnd = functionCloseBraceIndex;
  const body = source.slice(bodyStart, bodyEnd);
  if (body.includes("apply_imported_patch(")) {
    return source;
  }
  const trimmedBody = body.trim();
  if (trimmedBody.length === 0) {
    throw new Error("default_model_document() body is empty");
  }
  const wrappedBody = `\n  apply_imported_patch(\n${indentBlock(trimmedBody, "    ")}\n  )\n`;
  return `${source.slice(0, bodyStart)}${wrappedBody}${source.slice(bodyEnd)}`;
}

function renamePatchFunction(patchText, nextName) {
  if (!patchText.includes(PATCH_SIGNATURE)) {
    throw new Error("patch file must contain apply_imported_patch(doc : ModelDocument)");
  }
  return patchText.replace(
    PATCH_SIGNATURE,
    `fn ${nextName}(doc : ModelDocument) -> ModelDocument {`,
  );
}

function extractPatchBlock(source) {
  const startIndex = source.indexOf(PATCH_START_MARKER);
  const endIndex = source.indexOf(PATCH_END_MARKER);
  if (startIndex < 0 || endIndex < 0 || endIndex <= startIndex) {
    return null;
  }
  const blockStart = startIndex + PATCH_START_MARKER.length;
  return {
    startIndex,
    endIndex,
    inner: source.slice(blockStart, endIndex).trim(),
  };
}

function existingStageIndices(patchInner) {
  return [...patchInner.matchAll(/fn apply_imported_patch_stage_(\d+)\(doc : ModelDocument\) -> ModelDocument \{/g)]
    .map((match) => Number(match[1]))
    .filter((value) => Number.isFinite(value))
    .sort((a, b) => a - b);
}

function removeMainPatchFunction(patchInner) {
  const signatureIndex = patchInner.indexOf(PATCH_SIGNATURE);
  if (signatureIndex < 0) {
    return patchInner;
  }
  const openBraceIndex = signatureIndex + PATCH_SIGNATURE.length - 1;
  const closeBraceIndex = findMatchingBrace(patchInner, openBraceIndex);
  const before = patchInner.slice(0, signatureIndex).trimEnd();
  const after = patchInner.slice(closeBraceIndex + 1).trimStart();
  if (before.length === 0) return after;
  if (after.length === 0) return before;
  return `${before}\n\n${after}`;
}

function buildStageWrapper(stageIndices) {
  const lines = ["fn apply_imported_patch(doc : ModelDocument) -> ModelDocument {"];
  if (stageIndices.length === 0) {
    lines.push("  doc");
    lines.push("}");
    return lines.join("\n");
  }
  lines.push(`  let stage_0 = ${STAGE_PREFIX}${stageIndices[0]}(doc)`);
  for (let index = 1; index < stageIndices.length; index += 1) {
    lines.push(
      `  let stage_${index} = ${STAGE_PREFIX}${stageIndices[index]}(stage_${index - 1})`,
    );
  }
  lines.push(`  stage_${stageIndices.length - 1}`);
  lines.push("}");
  return lines.join("\n");
}

function composePatchBlock(existingInner, patchText) {
  const normalizedExisting = existingInner.trim();
  const normalizedPatch = patchText.trim();
  if (normalizedExisting === normalizedPatch) {
    return `${PATCH_START_MARKER}\n${normalizedPatch}\n${PATCH_END_MARKER}\n`;
  }

  const stageIndices = existingStageIndices(normalizedExisting);
  const existingStages =
    stageIndices.length === 0
      ? renamePatchFunction(`${normalizedExisting}\n`, `${STAGE_PREFIX}0`).trim()
      : removeMainPatchFunction(normalizedExisting).trim();
  const nextStageIndex =
    stageIndices.length === 0 ? 1 : Math.max(...stageIndices) + 1;
  const nextStage = renamePatchFunction(
    normalizedPatch,
    `${STAGE_PREFIX}${nextStageIndex}`,
  ).trim();
  const allStageIndices =
    stageIndices.length === 0
      ? [0, nextStageIndex]
      : [...stageIndices, nextStageIndex];

  return [
    PATCH_START_MARKER,
    existingStages,
    "",
    nextStage,
    "",
    buildStageWrapper(allStageIndices),
    PATCH_END_MARKER,
    "",
  ].join("\n");
}

function injectPatchBlock(source, patchText) {
  const normalizedPatch = patchText.trim();
  if (!normalizedPatch.includes("fn apply_imported_patch(doc : ModelDocument) -> ModelDocument")) {
    throw new Error("patch file must contain apply_imported_patch(doc : ModelDocument)");
  }
  const wrappedPatch = `${PATCH_START_MARKER}\n${normalizedPatch}\n${PATCH_END_MARKER}\n`;
  const existingPatch = extractPatchBlock(source);
  if (existingPatch != null) {
    const afterEnd = source.indexOf("\n", existingPatch.endIndex);
    const replaceEnd = afterEnd >= 0 ? afterEnd + 1 : source.length;
    return `${source.slice(0, existingPatch.startIndex)}${composePatchBlock(existingPatch.inner, normalizedPatch)}${source.slice(replaceEnd)}`;
  }
  const trimmedSource = source.trimEnd();
  return `${trimmedSource}\n\n${wrappedPatch}`;
}

export function applyRoundtripPatchToModelDoc(source, patchText) {
  return injectPatchBlock(wrapDefaultModelDocument(source), patchText);
}

export const MODEL_DOC_PATCH_MARKERS = {
  start: PATCH_START_MARKER,
  end: PATCH_END_MARKER,
};
