/**
 * Deterministic UI integrity gate for canvas-rendered game UI.
 *
 * vlmkit's `check integrity` finds text collision / clipping / protrusion /
 * collapsed containers from the DOM. A canvas UI has no DOM, so that gate is a
 * no-op here. This module runs the equivalent judgments over the UI snapshot
 * the engine publishes (`@ui.publish_ui_snapshot`), which carries the same
 * information the DOM would have: rects, clip rects, measured text extents,
 * hit rects and focus order.
 *
 * Every judgment is deterministic pixel/rect math — no VLM, no browser.
 */

import { unwrapSnapshot } from "./ui-snapshot-utils.mjs";
import { finiteNumber } from "./ui-number-utils.mjs";

/** Every finding kind this gate can emit. `--allow` is validated against it. */
export const FINDING_KINDS = [
  "zero-size",
  "text-overflow",
  "text-clipped",
  "protrusion",
  "offscreen",
  "safe-area-violation",
  "text-collision",
  "hit-box-mismatch",
  "child-escape",
];

const DEFAULT_TOLERANCE = 0.5;

function rectOf(source) {
  const left = finiteNumber(source?.left);
  const top = finiteNumber(source?.top);
  const width = finiteNumber(source?.width);
  const height = finiteNumber(source?.height);
  return { left, top, width, height, right: left + width, bottom: top + height };
}

function intersection(a, b) {
  const left = Math.max(a.left, b.left);
  const top = Math.max(a.top, b.top);
  const right = Math.min(a.right, b.right);
  const bottom = Math.min(a.bottom, b.bottom);
  const width = right - left;
  const height = bottom - top;
  if (width <= 0 || height <= 0) return null;
  return { left, top, width, height, right, bottom };
}

function area(rect) {
  return Math.max(0, rect.width) * Math.max(0, rect.height);
}

function contains(outer, inner, tolerance) {
  return (
    inner.left >= outer.left - tolerance &&
    inner.top >= outer.top - tolerance &&
    inner.right <= outer.right + tolerance &&
    inner.bottom <= outer.bottom + tolerance
  );
}

/** How far `inner` pokes out past each edge of `outer`, clamped at 0. */
function escapeAmounts(outer, inner) {
  return {
    left: Math.max(0, outer.left - inner.left),
    top: Math.max(0, outer.top - inner.top),
    right: Math.max(0, inner.right - outer.right),
    bottom: Math.max(0, inner.bottom - outer.bottom),
  };
}

function maxEscape(amounts) {
  return Math.max(amounts.left, amounts.top, amounts.right, amounts.bottom);
}

function describeEscape(amounts) {
  return Object.entries(amounts)
    .filter(([, value]) => value > 0)
    .map(([edge, value]) => `${edge} ${round(value)}px`)
    .join(", ");
}

function round(value) {
  return Number(value.toFixed(2));
}

/** A node that covers the whole screen — a backdrop / root layer, not content. */
function isFullBleed(rect, screen, tolerance) {
  return contains(rect, screen, tolerance);
}

function label(node) {
  if (typeof node.id === "string" && node.id !== "") return node.id;
  if (typeof node.path === "string" && node.path !== "") return node.path;
  return "<unnamed>";
}

function hasText(node) {
  return typeof node.text === "string" && node.text.trim() !== "";
}

function isVisible(node) {
  return node.visible !== false;
}

/** `a` is an ancestor of `b` when b's path extends a's. */
function isAncestorPath(a, b) {
  return typeof a === "string" && typeof b === "string" && a !== "" && b.startsWith(`${a}>`);
}

/**
 * Nearest ancestor of `node` present in the snapshot.
 *
 * Paths are structural, so the parent is the longest path that prefixes this
 * one. Intermediate nodes may be absent from the snapshot (a UI is free to
 * publish only what it considers meaningful), hence "longest present" rather
 * than "strip one segment".
 */
function findParent(node, nodes) {
  let best = null;
  for (const candidate of nodes) {
    if (candidate === node) continue;
    if (!isAncestorPath(candidate.path, node.path)) continue;
    if (best === null || candidate.path.length > best.path.length) best = candidate;
  }
  return best;
}

/**
 * Parse an `--allow` rule: `<kind>[@<id>];<reason>`.
 *
 * A reason is mandatory and an unknown kind is an error, so a suppression can
 * never be a silent typo — the same contract vlmkit's `--allow` uses.
 */
export function parseAllowRule(raw) {
  const text = String(raw);
  const separator = text.indexOf(";");
  if (separator < 0) {
    throw new Error(`--allow needs a reason: "${text}" (syntax: <kind>[@<id>];<reason>)`);
  }
  const selector = text.slice(0, separator).trim();
  const reason = text.slice(separator + 1).trim();
  if (reason === "") {
    throw new Error(`--allow needs a non-empty reason: "${text}"`);
  }
  const at = selector.indexOf("@");
  const kind = (at < 0 ? selector : selector.slice(0, at)).trim();
  const id = at < 0 ? "" : selector.slice(at + 1).trim();
  if (!FINDING_KINDS.includes(kind)) {
    throw new Error(`unknown --allow kind: "${kind}" (known: ${FINDING_KINDS.join(", ")})`);
  }
  return { kind, id, reason, raw: text };
}

function ruleMatches(rule, finding) {
  if (rule.kind !== finding.kind) return false;
  if (rule.id === "") return true;
  return finding.id === rule.id || finding.path === rule.id || finding.ids?.includes(rule.id) === true;
}

/**
 * Run every judgment over a snapshot.
 *
 * Returns findings, the subset exempted by `--allow`, and any rule that matched
 * nothing — a stale suppression is itself a defect worth surfacing.
 */
export function analyzeSnapshot(input, { tolerance = DEFAULT_TOLERANCE, allow = [] } = {}) {
  const snapshot = unwrapSnapshot(input);
  const nodes = snapshot.nodes.filter((node) => node != null && typeof node === "object");
  const screenWidth = finiteNumber(snapshot.screen?.width);
  const screenHeight = finiteNumber(snapshot.screen?.height);
  const screen = rectOf({ left: 0, top: 0, width: screenWidth, height: screenHeight });
  const safeArea = snapshot.screen?.safe_area ?? {};
  const findings = [];

  const push = (kind, node, message, evidence, extra = {}) => {
    findings.push({
      kind,
      severity: "defect",
      id: typeof node?.id === "string" ? node.id : "",
      path: typeof node?.path === "string" ? node.path : "",
      message,
      evidence,
      ...extra,
    });
  };

  for (const node of nodes) {
    if (!isVisible(node)) continue;
    const rect = rectOf(node);

    // Collapsed node: nothing renders, and every geometric judgment below is
    // meaningless on a degenerate rect, so stop at this node.
    if (rect.width <= 0 || rect.height <= 0) {
      push(
        "zero-size",
        node,
        `${label(node)}: visible node has no area (${round(rect.width)}x${round(rect.height)})`,
        { width: round(rect.width), height: round(rect.height) },
      );
      continue;
    }

    // Text wider/taller than its box: the renderer will clip or spill it.
    if (node.text_measured != null && typeof node.text_measured === "object") {
      const measured = {
        width: finiteNumber(node.text_measured.width),
        height: finiteNumber(node.text_measured.height),
      };
      const overWidth = measured.width - rect.width;
      const overHeight = measured.height - rect.height;
      if (overWidth > tolerance || overHeight > tolerance) {
        const axes = [];
        if (overWidth > tolerance) axes.push(`width by ${round(overWidth)}px`);
        if (overHeight > tolerance) axes.push(`height by ${round(overHeight)}px`);
        push(
          "text-overflow",
          node,
          `${label(node)}: measured text ${round(measured.width)}x${round(measured.height)} ` +
            `exceeds rect ${round(rect.width)}x${round(rect.height)} (${axes.join(", ")})`,
          {
            measured: { width: round(measured.width), height: round(measured.height) },
            rect: { width: round(rect.width), height: round(rect.height) },
            overWidth: round(overWidth),
            overHeight: round(overHeight),
          },
        );
      }
    }

    // Scissor rect cutting into a text node: part of the string is invisible.
    if (hasText(node) && node.clip != null && typeof node.clip === "object") {
      const clip = rectOf(node.clip);
      const visiblePart = intersection(rect, clip);
      const visibleArea = visiblePart === null ? 0 : area(visiblePart);
      const nodeArea = area(rect);
      const hiddenRatio = nodeArea > 0 ? 1 - visibleArea / nodeArea : 0;
      if (hiddenRatio * nodeArea > tolerance) {
        push(
          "text-clipped",
          node,
          `${label(node)}: ${Math.round(hiddenRatio * 100)}% of the text box is outside its clip rect`,
          {
            hiddenRatio: round(hiddenRatio),
            rect: { left: round(rect.left), top: round(rect.top), width: round(rect.width), height: round(rect.height) },
            clip: { left: round(clip.left), top: round(clip.top), width: round(clip.width), height: round(clip.height) },
          },
        );
      }
    }

    // Off the screen entirely, or poking past an edge.
    if (screenWidth > 0 && screenHeight > 0) {
      const onScreen = intersection(rect, screen);
      if (onScreen === null) {
        push(
          "offscreen",
          node,
          `${label(node)}: rect (${round(rect.left)},${round(rect.top)}) ` +
            `${round(rect.width)}x${round(rect.height)} is entirely outside the ` +
            `${round(screenWidth)}x${round(screenHeight)} screen`,
          {
            rect: { left: round(rect.left), top: round(rect.top), width: round(rect.width), height: round(rect.height) },
            screen: { width: round(screenWidth), height: round(screenHeight) },
          },
        );
      } else {
        const escapes = escapeAmounts(screen, rect);
        if (maxEscape(escapes) > tolerance) {
          push(
            "protrusion",
            node,
            `${label(node)}: extends past the screen edge (${describeEscape(escapes)})`,
            { escapes: Object.fromEntries(Object.entries(escapes).map(([k, v]) => [k, round(v)])) },
          );
        }
      }

      // A zero inset means the UI never declared one; only a declared safe area
      // can be violated. A full-bleed backdrop is exempt by construction: a node
      // that covers the screen cannot respect an inset, and flagging every
      // background layer would bury the content findings that matter.
      const insets = {
        top: finiteNumber(safeArea.top),
        right: finiteNumber(safeArea.right),
        bottom: finiteNumber(safeArea.bottom),
        left: finiteNumber(safeArea.left),
      };
      const hasInset = insets.top > 0 || insets.right > 0 || insets.bottom > 0 || insets.left > 0;
      if (hasInset && !isFullBleed(rect, screen, tolerance)) {
        const safeRect = rectOf({
          left: insets.left,
          top: insets.top,
          width: screenWidth - insets.left - insets.right,
          height: screenHeight - insets.top - insets.bottom,
        });
        if (area(safeRect) > 0 && !contains(safeRect, rect, tolerance)) {
          const escapes = escapeAmounts(safeRect, rect);
          push(
            "safe-area-violation",
            node,
            `${label(node)}: intrudes into the safe-area inset (${describeEscape(escapes)})`,
            {
              escapes: Object.fromEntries(Object.entries(escapes).map(([k, v]) => [k, round(v)])),
              safeArea: insets,
            },
          );
        }
      }
    }

    // Pointer target drifted from what is drawn.
    if (node.hit != null && typeof node.hit === "object") {
      const hit = rectOf(node.hit);
      const drift = Math.max(
        Math.abs(hit.left - rect.left),
        Math.abs(hit.top - rect.top),
        Math.abs(hit.right - rect.right),
        Math.abs(hit.bottom - rect.bottom),
      );
      if (drift > tolerance) {
        push(
          "hit-box-mismatch",
          node,
          `${label(node)}: hit rect (${round(hit.left)},${round(hit.top)}) ` +
            `${round(hit.width)}x${round(hit.height)} differs from drawn rect ` +
            `(${round(rect.left)},${round(rect.top)}) ${round(rect.width)}x${round(rect.height)} ` +
            `by ${round(drift)}px`,
          {
            drift: round(drift),
            hit: { left: round(hit.left), top: round(hit.top), width: round(hit.width), height: round(hit.height) },
            rect: { left: round(rect.left), top: round(rect.top), width: round(rect.width), height: round(rect.height) },
          },
        );
      }
    }

    // Child sticking out of its parent. A scroll container clips its children on
    // purpose, so only an escape that is still *visible* after clipping counts.
    // A full-bleed parent is skipped: escaping it is the same fact `protrusion`
    // already reports against the screen, and one defect should be reported once.
    const parent = findParent(node, nodes);
    if (parent !== null && isVisible(parent)) {
      const parentRect = rectOf(parent);
      const parentIsFullBleed =
        screenWidth > 0 && screenHeight > 0 && isFullBleed(parentRect, screen, tolerance);
      if (area(parentRect) > 0 && !parentIsFullBleed && !contains(parentRect, rect, tolerance)) {
        const clip = node.clip != null && typeof node.clip === "object" ? rectOf(node.clip) : null;
        const visiblePart = clip === null ? rect : intersection(rect, clip);
        if (visiblePart !== null && !contains(parentRect, visiblePart, tolerance)) {
          const escapes = escapeAmounts(parentRect, visiblePart);
          push(
            "child-escape",
            node,
            `${label(node)}: escapes parent ${label(parent)} unclipped (${describeEscape(escapes)})`,
            {
              escapes: Object.fromEntries(Object.entries(escapes).map(([k, v]) => [k, round(v)])),
              parent: label(parent),
            },
            { parentPath: parent.path },
          );
        }
      }
    }
  }

  // Text colliding with text. Restricted to the same z and to nodes that are not
  // in an ancestor/descendant relationship: different z is deliberate layering,
  // and a label inside its own panel is not a collision.
  const textNodes = nodes.filter((node) => isVisible(node) && hasText(node));
  for (let i = 0; i < textNodes.length; i += 1) {
    for (let j = i + 1; j < textNodes.length; j += 1) {
      const a = textNodes[i];
      const b = textNodes[j];
      if (finiteNumber(a.z) !== finiteNumber(b.z)) continue;
      if (isAncestorPath(a.path, b.path) || isAncestorPath(b.path, a.path)) continue;
      const overlap = intersection(rectOf(a), rectOf(b));
      if (overlap === null || area(overlap) <= tolerance) continue;
      findings.push({
        kind: "text-collision",
        severity: "defect",
        id: typeof a.id === "string" ? a.id : "",
        path: typeof a.path === "string" ? a.path : "",
        ids: [a.id, b.id].filter((value) => typeof value === "string" && value !== ""),
        message:
          `${label(a)} overlaps ${label(b)} at z=${finiteNumber(a.z)}: ` +
          `"${a.text}" / "${b.text}" share ` +
          `(${round(overlap.left)},${round(overlap.top)}) ${round(overlap.width)}x${round(overlap.height)}`,
        evidence: {
          overlap: {
            left: round(overlap.left),
            top: round(overlap.top),
            width: round(overlap.width),
            height: round(overlap.height),
          },
          other: label(b),
          otherPath: typeof b.path === "string" ? b.path : "",
        },
      });
    }
  }

  findings.sort(
    (a, b) => a.kind.localeCompare(b.kind) || a.path.localeCompare(b.path) || a.id.localeCompare(b.id),
  );

  const rules = allow.map((rule) => (typeof rule === "string" ? parseAllowRule(rule) : rule));
  const used = new Set();
  const kept = [];
  const exempted = [];
  for (const finding of findings) {
    const rule = rules.find((candidate) => ruleMatches(candidate, finding));
    if (rule === undefined) {
      kept.push(finding);
      continue;
    }
    used.add(rule.raw ?? `${rule.kind}@${rule.id}`);
    exempted.push({ ...finding, exemptedBy: rule.raw ?? `${rule.kind}@${rule.id}`, reason: rule.reason });
  }

  return {
    screen: { width: screenWidth, height: screenHeight, dpr: finiteNumber(snapshot.screen?.dpr, 1) },
    state: typeof snapshot.state === "string" ? snapshot.state : "",
    frame: finiteNumber(snapshot.frame),
    nodeCount: nodes.length,
    findings: kept,
    exempted,
    unusedAllows: rules
      .filter((rule) => !used.has(rule.raw ?? `${rule.kind}@${rule.id}`))
      .map((rule) => rule.raw ?? `${rule.kind}@${rule.id}`),
  };
}

/**
 * Render a report as machine-parsable lines.
 *
 * `[kind] message` mirrors vlmkit's fix-list shape so the same reading habit
 * (and the same agent loop) works across both gates.
 */
export function formatReport(result, { source = "" } = {}) {
  const lines = [];
  if (source !== "") lines.push(`source: ${source}`);
  const stateSuffix = result.state === "" ? "" : ` state=${result.state}`;
  lines.push(
    `screen: ${result.screen.width}x${result.screen.height} dpr=${result.screen.dpr}` +
      `${stateSuffix} nodes=${result.nodeCount}`,
  );
  lines.push(`verdict: ${result.findings.length === 0 ? "CLEAN" : "DEFECTS"}`);
  for (const finding of result.findings) {
    lines.push(`[${finding.kind}] ${finding.message}`);
  }
  if (result.exempted.length > 0) {
    lines.push(`exempted: ${result.exempted.length}`);
    for (const finding of result.exempted) {
      lines.push(`  [${finding.kind}] ${finding.message} — ${finding.reason}`);
    }
  }
  for (const rule of result.unusedAllows) {
    lines.push(`warning: --allow rule matched nothing: ${rule}`);
  }
  return lines.join("\n");
}
