/**
 * UI snapshot intake: parse the document published by
 * `@ui.publish_ui_snapshot` (`globalThis.__kaguraUISnapshot`) or written to
 * `context_path` by the native capture, and convert it into a vlmkit
 * `--elements-json` payload.
 *
 * A canvas-rendered UI has no DOM, so vlmkit's DOM-driven gates see one opaque
 * `<canvas>`. `diff png --elements-json` is the exception: its rect schema is
 * DOM-agnostic, so feeding it the snapshot is what lets a pixel diff name the
 * UI node that changed.
 */

/** Rect fields vlmkit's `parseRegionElementRect` requires, plus optionals it reads. */
const ELEMENT_KEYS = ["path", "tag", "id", "classes", "top", "left", "width", "height"];

/**
 * Unwrap a snapshot document.
 *
 * Accepts the raw snapshot object, the `{ json, parsed }` envelope the browser
 * global uses, or a JSON string of either. The envelope keeps the raw string
 * when parsing failed, so prefer `parsed` but fall back to re-parsing `json`.
 */
export function unwrapSnapshot(input) {
  let value = input;
  if (typeof value === "string") {
    value = JSON.parse(value);
  }
  if (value == null || typeof value !== "object") {
    throw new Error("snapshot must be an object or a JSON string");
  }
  if (!Array.isArray(value.nodes)) {
    if (value.parsed != null && typeof value.parsed === "object") {
      return unwrapSnapshot(value.parsed);
    }
    if (typeof value.json === "string") {
      return unwrapSnapshot(value.json);
    }
    throw new Error("snapshot has no `nodes` array");
  }
  return value;
}

function finiteNumber(value, fallback = 0) {
  return typeof value === "number" && Number.isFinite(value) ? value : fallback;
}

/**
 * Resolve the factor mapping snapshot units (CSS/logical px) to captured-frame
 * pixels.
 *
 * Getting this wrong silently misaligns every rect against the PNG, so `dpr`
 * (the default) reads it off the snapshot rather than assuming 1.
 */
export function resolveScale(snapshot, scaleOption = "dpr") {
  if (scaleOption === "dpr") {
    const dpr = finiteNumber(snapshot.screen?.dpr, 1);
    return dpr > 0 ? dpr : 1;
  }
  const explicit = Number(scaleOption);
  if (!Number.isFinite(explicit) || explicit <= 0) {
    throw new Error(`invalid scale: ${scaleOption} (expected "dpr" or a positive number)`);
  }
  return explicit;
}

/**
 * Convert a snapshot into vlmkit's elements-json payload.
 *
 * Invisible and zero-area nodes are dropped: vlmkit discards rows with
 * `width <= 0 || height <= 0` anyway, and an invisible node cannot own a pixel
 * diff, so attributing one to it would be a false lead.
 */
export function toVlmkitElements(input, { scale = "dpr", includeInvisible = false } = {}) {
  const snapshot = unwrapSnapshot(input);
  const factor = resolveScale(snapshot, scale);
  const elements = [];
  for (const node of snapshot.nodes) {
    if (node == null || typeof node !== "object") continue;
    if (!includeInvisible && node.visible === false) continue;
    const width = finiteNumber(node.width) * factor;
    const height = finiteNumber(node.height) * factor;
    if (width <= 0 || height <= 0) continue;
    const path = typeof node.path === "string" ? node.path : "";
    const tag = typeof node.tag === "string" && node.tag !== ""
      ? node.tag
      : typeof node.role === "string" && node.role !== ""
        ? node.role
        : "node";
    if (path === "") continue;
    elements.push({
      path,
      tag,
      id: typeof node.id === "string" ? node.id : "",
      classes: typeof node.classes === "string" ? node.classes : "",
      top: finiteNumber(node.top) * factor,
      left: finiteNumber(node.left) * factor,
      width,
      height,
    });
  }
  return { elements };
}

/** Field order vlmkit reads; exported so tests can assert the contract. */
export function elementKeys() {
  return [...ELEMENT_KEYS];
}
