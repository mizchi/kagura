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

import { finiteNumber } from "./ui-number-utils.mjs";

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

/** Rich image-integrity contract. Keep collapsed geometry: it is evidence. */
export function toVlmkitIntegrityElements(input, { scale = 'dpr' } = {}) {
  const snapshot = unwrapSnapshot(input);
  if (scale === 'dpr' && snapshot.screen?.dpr != null &&
    (!Number.isFinite(snapshot.screen.dpr) || snapshot.screen.dpr <= 0)) throw Error('Invalid integrity DPR');
  const factor = resolveScale(snapshot, scale);
  const paths = new Set();
  const number = (value, field) => {
    if (!Number.isFinite(value)) throw Error(`Invalid integrity element ${field}`);
    return value * factor;
  };
  const box = (value, position) => ({
    ...(position ? { left: number(value.left, 'left'), top: number(value.top, 'top') } : {}),
    width: number(value.width, 'width'), height: number(value.height, 'height'),
  });
  return { elements: snapshot.nodes.filter(n => n?.visible !== false).map(node => {
    if (!node || typeof node.path !== 'string' || !node.path) throw Error('Integrity element needs a path');
    if (paths.has(node.path)) throw Error('Duplicate integrity element path');
    paths.add(node.path);
    const element = { path: node.path, tag: node.tag || node.role || 'node', id: node.id ?? '', classes: node.classes ?? '',
      ...box(node, true) };
    if (node.text != null) {
      if (typeof node.text !== 'string') throw Error('Integrity element text must be a string');
      element.text = node.text;
    }
    if (node.text_measured != null) element.text_measured = box(node.text_measured, false);
    if (node.clip != null) element.clip = box(node.clip, true);
    if (node.z != null) {
      if (!Number.isFinite(node.z)) throw Error('Invalid integrity element z');
      element.z_index = node.z;
    }
    return element;
  }) };
}
