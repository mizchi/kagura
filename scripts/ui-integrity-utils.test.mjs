import assert from "node:assert/strict";
import test from "node:test";

import {
  FINDING_KINDS,
  analyzeSnapshot,
  formatReport,
  parseAllowRule,
} from "./ui-integrity-utils.mjs";

function snapshot(nodes, extra = {}) {
  return {
    screen: { width: 640, height: 480, dpr: 1, safe_area: { top: 0, right: 0, bottom: 0, left: 0 } },
    frame: 0,
    state: "playing",
    nodes,
    focus_order: [],
    ...extra,
  };
}

function node(overrides) {
  return {
    path: "hud[0]",
    id: "hud",
    tag: "panel",
    role: "panel",
    classes: "",
    left: 0,
    top: 0,
    width: 100,
    height: 20,
    z: 0,
    visible: true,
    focusable: false,
    focus_index: -1,
    focused: false,
    ...overrides,
  };
}

function kinds(result) {
  return result.findings.map((finding) => finding.kind);
}

test("clean snapshot yields no findings", () => {
  const result = analyzeSnapshot(snapshot([node({})]));
  assert.deepEqual(result.findings, []);
  assert.equal(result.nodeCount, 1);
  assert.equal(result.state, "playing");
});

test("zero-size flags a visible node with no area", () => {
  const result = analyzeSnapshot(snapshot([node({ id: "empty", width: 0 })]));
  assert.deepEqual(kinds(result), ["zero-size"]);
  assert.match(result.findings[0].message, /empty: visible node has no area/);
});

test("zero-size is skipped for invisible nodes", () => {
  const result = analyzeSnapshot(snapshot([node({ width: 0, visible: false })]));
  assert.deepEqual(result.findings, []);
});

test("a degenerate rect reports only zero-size, not every geometric rule", () => {
  // A 0-width node at (700,500) is off-screen and escapes its parent too, but
  // reporting all three would bury the one finding that explains the rest.
  const result = analyzeSnapshot(
    snapshot([
      node({ path: "hud[0]", id: "hud", width: 640, height: 480 }),
      node({ path: "hud[0]>x[0]", id: "collapsed", left: 700, top: 500, width: 0, height: 0 }),
    ]),
  );
  assert.deepEqual(kinds(result), ["zero-size"]);
});

test("text-overflow flags measured text wider than its box", () => {
  const result = analyzeSnapshot(
    snapshot([
      node({ id: "hp_label", width: 200, height: 20, text: "HP 9999999", text_measured: { width: 214, height: 18 } }),
    ]),
  );
  assert.deepEqual(kinds(result), ["text-overflow"]);
  assert.equal(result.findings[0].evidence.overWidth, 14);
  assert.match(result.findings[0].message, /width by 14px/);
});

test("text-overflow flags the height axis", () => {
  const result = analyzeSnapshot(
    snapshot([node({ width: 200, height: 12, text_measured: { width: 100, height: 30 } })]),
  );
  assert.deepEqual(kinds(result), ["text-overflow"]);
  assert.equal(result.findings[0].evidence.overHeight, 18);
});

test("text that fits is not flagged", () => {
  const result = analyzeSnapshot(
    snapshot([node({ width: 200, height: 20, text_measured: { width: 199.8, height: 18 } })]),
  );
  assert.deepEqual(result.findings, []);
});

test("text-clipped flags a text box cut by its scissor rect", () => {
  const result = analyzeSnapshot(
    snapshot([
      node({
        id: "name",
        left: 100,
        top: 0,
        width: 100,
        height: 20,
        text: "Aethelred the Unready",
        clip: { left: 0, top: 0, width: 150, height: 480 },
      }),
    ]),
  );
  assert.deepEqual(kinds(result), ["text-clipped"]);
  assert.equal(result.findings[0].evidence.hiddenRatio, 0.5);
});

test("text fully inside its clip rect is not flagged", () => {
  const result = analyzeSnapshot(
    snapshot([node({ text: "ok", clip: { left: 0, top: 0, width: 640, height: 480 } })]),
  );
  assert.deepEqual(result.findings, []);
});

test("a text node clipped away entirely reports 100% hidden", () => {
  const result = analyzeSnapshot(
    snapshot([
      node({ left: 300, top: 300, width: 100, height: 20, text: "gone", clip: { left: 0, top: 0, width: 100, height: 100 } }),
    ]),
  );
  assert.deepEqual(kinds(result), ["text-clipped"]);
  assert.equal(result.findings[0].evidence.hiddenRatio, 1);
});

test("protrusion flags a node poking past the screen edge", () => {
  const result = analyzeSnapshot(snapshot([node({ id: "minimap", left: 600, top: 440, width: 80, height: 80 })]));
  assert.deepEqual(kinds(result), ["protrusion"]);
  assert.equal(result.findings[0].evidence.escapes.right, 40);
  assert.equal(result.findings[0].evidence.escapes.bottom, 40);
});

test("offscreen flags a node entirely outside the screen", () => {
  const result = analyzeSnapshot(snapshot([node({ id: "ghost", left: 700, top: 10, width: 50, height: 20 })]));
  assert.deepEqual(kinds(result), ["offscreen"]);
  assert.match(result.findings[0].message, /entirely outside the 640x480 screen/);
});

test("safe-area-violation only applies when an inset is declared", () => {
  const nodes = [node({ id: "hud_top", left: 0, top: 0, width: 100, height: 20 })];
  const withoutInset = analyzeSnapshot(snapshot(nodes));
  assert.deepEqual(withoutInset.findings, []);

  const withInset = analyzeSnapshot(
    snapshot(nodes, {
      screen: { width: 640, height: 480, dpr: 1, safe_area: { top: 32, right: 0, bottom: 0, left: 0 } },
    }),
  );
  assert.deepEqual(kinds(withInset), ["safe-area-violation"]);
  assert.equal(withInset.findings[0].evidence.escapes.top, 32);
});

test("safe-area-violation exempts a full-bleed backdrop", () => {
  // A root layer covering the screen cannot respect an inset; flagging every
  // background would bury the content findings that matter.
  const result = analyzeSnapshot(
    snapshot(
      [
        node({ path: "hud[0]", id: "hud", left: 0, top: 0, width: 640, height: 480 }),
        node({ path: "hud[0]>label[0]", id: "label", left: 16, top: 8, width: 100, height: 20, text: "HP" }),
      ],
      { screen: { width: 640, height: 480, dpr: 1, safe_area: { top: 32, right: 0, bottom: 0, left: 0 } } },
    ),
  );
  assert.deepEqual(
    result.findings.map((finding) => `${finding.kind}:${finding.id}`),
    ["safe-area-violation:label"],
  );
});

test("child-escape is not reported when the parent is full-bleed", () => {
  // Escaping a screen-sized root is the same fact `protrusion` reports against
  // the screen; reporting both would double-count one defect.
  const result = analyzeSnapshot(
    snapshot([
      node({ path: "hud[0]", id: "hud", left: 0, top: 0, width: 640, height: 480 }),
      node({ path: "hud[0]>mm[0]", id: "minimap", left: 600, top: 440, width: 80, height: 80 }),
    ]),
  );
  assert.deepEqual(kinds(result), ["protrusion"]);
});

test("hit-box-mismatch flags a pointer target drifted from the drawn rect", () => {
  const result = analyzeSnapshot(
    snapshot([
      node({ id: "pause", left: 270, top: 320, width: 100, height: 28, hit: { left: 270, top: 330, width: 100, height: 28 } }),
    ]),
  );
  assert.deepEqual(kinds(result), ["hit-box-mismatch"]);
  assert.equal(result.findings[0].evidence.drift, 10);
});

test("a hit rect matching the drawn rect is not flagged", () => {
  const result = analyzeSnapshot(
    snapshot([node({ left: 10, top: 10, width: 100, height: 20, hit: { left: 10, top: 10, width: 100, height: 20 } })]),
  );
  assert.deepEqual(result.findings, []);
});

test("text-collision flags two overlapping text nodes at the same z", () => {
  const result = analyzeSnapshot(
    snapshot([
      node({ path: "hud[0]>a[0]", id: "total", left: 10, top: 10, width: 100, height: 20, text: "Total: 1240", z: 2 }),
      node({ path: "hud[0]>b[1]", id: "refunds", left: 80, top: 10, width: 100, height: 20, text: "Refunds: 80", z: 2 }),
    ]),
  );
  assert.deepEqual(kinds(result), ["text-collision"]);
  assert.equal(result.findings[0].evidence.overlap.width, 30);
  assert.deepEqual(result.findings[0].ids, ["total", "refunds"]);
});

test("text-collision ignores different z (deliberate layering)", () => {
  const result = analyzeSnapshot(
    snapshot([
      node({ path: "hud[0]>a[0]", id: "a", left: 10, top: 10, width: 100, height: 20, text: "a", z: 1 }),
      node({ path: "hud[0]>b[1]", id: "b", left: 10, top: 10, width: 100, height: 20, text: "b", z: 5 }),
    ]),
  );
  assert.deepEqual(result.findings, []);
});

test("text-collision ignores a label nested inside its own container", () => {
  const result = analyzeSnapshot(
    snapshot([
      node({ path: "panel[0]", id: "panel", left: 0, top: 0, width: 200, height: 40, text: "Panel" }),
      node({ path: "panel[0]>label[0]", id: "label", left: 10, top: 10, width: 100, height: 20, text: "Label" }),
    ]),
  );
  assert.deepEqual(result.findings, []);
});

test("text-collision ignores nodes without text", () => {
  const result = analyzeSnapshot(
    snapshot([
      node({ path: "hud[0]>a[0]", id: "a", left: 10, top: 10, width: 100, height: 20 }),
      node({ path: "hud[0]>b[1]", id: "b", left: 10, top: 10, width: 100, height: 20 }),
    ]),
  );
  assert.deepEqual(result.findings, []);
});

test("child-escape flags an unclipped child sticking out of its parent", () => {
  const result = analyzeSnapshot(
    snapshot([
      node({ path: "panel[0]", id: "panel", left: 0, top: 0, width: 100, height: 40 }),
      node({ path: "panel[0]>row[0]", id: "row", left: 10, top: 10, width: 200, height: 20 }),
    ]),
  );
  assert.deepEqual(kinds(result), ["child-escape"]);
  assert.equal(result.findings[0].evidence.escapes.right, 110);
  assert.equal(result.findings[0].evidence.parent, "panel");
});

test("child-escape tolerates a scroll child that its clip rect contains", () => {
  // A scroll container's content legitimately extends past the container and is
  // clipped to it; flagging that would make the gate unusable for scroll views.
  const result = analyzeSnapshot(
    snapshot([
      node({ path: "panel[0]", id: "panel", left: 0, top: 0, width: 100, height: 40 }),
      node({
        path: "panel[0]>row[0]",
        id: "row",
        left: 10,
        top: 10,
        width: 200,
        height: 20,
        clip: { left: 0, top: 0, width: 100, height: 40 },
      }),
    ]),
  );
  assert.deepEqual(result.findings, []);
});

test("parent is the longest matching ancestor path present in the snapshot", () => {
  // The intermediate `panel[0]>group[0]` is absent, so `inner` must be measured
  // against `panel[0]`, not skipped for lack of a direct parent.
  const result = analyzeSnapshot(
    snapshot([
      node({ path: "panel[0]", id: "panel", left: 0, top: 0, width: 100, height: 40 }),
      node({ path: "panel[0]>group[0]>inner[0]", id: "inner", left: 10, top: 10, width: 200, height: 20 }),
    ]),
  );
  assert.deepEqual(kinds(result), ["child-escape"]);
  assert.equal(result.findings[0].evidence.parent, "panel");
});

test("tolerance suppresses sub-pixel noise", () => {
  const nodes = [node({ left: 0, top: 0, width: 640.4, height: 480 })];
  assert.deepEqual(analyzeSnapshot(snapshot(nodes)).findings, []);
  assert.deepEqual(kinds(analyzeSnapshot(snapshot(nodes), { tolerance: 0.1 })), ["protrusion"]);
});

test("findings are ordered deterministically", () => {
  const nodes = [
    node({ path: "z[9]", id: "zz", left: 700, top: 0, width: 10, height: 10 }),
    node({ path: "a[0]", id: "aa", width: 0 }),
    node({ path: "m[5]", id: "mm", left: 600, top: 0, width: 100, height: 10 }),
  ];
  const first = analyzeSnapshot(snapshot(nodes));
  const second = analyzeSnapshot(snapshot([...nodes].reverse()));
  assert.deepEqual(kinds(first), kinds(second));
  assert.deepEqual(kinds(first), ["offscreen", "protrusion", "zero-size"]);
});

test("parseAllowRule accepts kind, optional id and a reason", () => {
  assert.deepEqual(parseAllowRule("text-collision;deliberate graze"), {
    kind: "text-collision",
    id: "",
    reason: "deliberate graze",
    raw: "text-collision;deliberate graze",
  });
  const scoped = parseAllowRule("protrusion@minimap;bleeds off-screen by design");
  assert.equal(scoped.kind, "protrusion");
  assert.equal(scoped.id, "minimap");
});

test("parseAllowRule rejects a missing reason and an unknown kind", () => {
  assert.throws(() => parseAllowRule("protrusion"), /needs a reason/);
  assert.throws(() => parseAllowRule("protrusion;   "), /non-empty reason/);
  assert.throws(() => parseAllowRule("no-such-kind;because"), /unknown --allow kind/);
});

test("an allow rule moves a finding to exempted, still listed with its reason", () => {
  const result = analyzeSnapshot(
    snapshot([node({ id: "minimap", left: 600, top: 440, width: 80, height: 80 })]),
    { allow: ["protrusion@minimap;bleeds off-screen by design"] },
  );
  assert.deepEqual(result.findings, []);
  assert.equal(result.exempted.length, 1);
  assert.equal(result.exempted[0].reason, "bleeds off-screen by design");
  assert.deepEqual(result.unusedAllows, []);
});

test("an allow rule scoped to another id does not exempt", () => {
  const result = analyzeSnapshot(
    snapshot([node({ id: "minimap", left: 600, top: 440, width: 80, height: 80 })]),
    { allow: ["protrusion@healthbar;unrelated"] },
  );
  assert.deepEqual(kinds(result), ["protrusion"]);
  assert.deepEqual(result.unusedAllows, ["protrusion@healthbar;unrelated"]);
});

test("an allow rule may be scoped by path", () => {
  const result = analyzeSnapshot(
    snapshot([node({ path: "hud[0]>mm[3]", id: "", left: 600, top: 440, width: 80, height: 80 })]),
    { allow: ["protrusion@hud[0]>mm[3];intentional"] },
  );
  assert.deepEqual(result.findings, []);
  assert.equal(result.exempted.length, 1);
});

test("a stale allow rule is reported so suppressions cannot rot silently", () => {
  const result = analyzeSnapshot(snapshot([node({})]), { allow: ["zero-size;fixed last month"] });
  assert.deepEqual(result.findings, []);
  assert.deepEqual(result.unusedAllows, ["zero-size;fixed last month"]);
});

test("analyzeSnapshot accepts the browser envelope and a JSON string", () => {
  const raw = snapshot([node({ id: "empty", width: 0 })]);
  const fromEnvelope = analyzeSnapshot({ json: JSON.stringify(raw), parsed: raw });
  const fromString = analyzeSnapshot(JSON.stringify(raw));
  const fromJsonOnly = analyzeSnapshot({ json: JSON.stringify(raw), parsed: null });
  assert.deepEqual(kinds(fromEnvelope), ["zero-size"]);
  assert.deepEqual(kinds(fromString), ["zero-size"]);
  assert.deepEqual(kinds(fromJsonOnly), ["zero-size"]);
});

test("formatReport prints a CLEAN verdict and machine-parsable defect lines", () => {
  const clean = formatReport(analyzeSnapshot(snapshot([node({})])), { source: "ui_demo" });
  assert.match(clean, /^source: ui_demo$/m);
  assert.match(clean, /^screen: 640x480 dpr=1 state=playing nodes=1$/m);
  assert.match(clean, /^verdict: CLEAN$/m);

  const dirty = formatReport(
    analyzeSnapshot(snapshot([node({ id: "hp", width: 200, height: 20, text_measured: { width: 214, height: 18 } })])),
  );
  assert.match(dirty, /^verdict: DEFECTS$/m);
  assert.match(dirty, /^\[text-overflow\] hp: measured text 214x18/m);
});

test("formatReport lists exemptions and stale rules", () => {
  const report = formatReport(
    analyzeSnapshot(snapshot([node({ id: "minimap", left: 600, top: 440, width: 80, height: 80 })]), {
      allow: ["protrusion@minimap;by design", "zero-size;stale"],
    }),
  );
  assert.match(report, /^exempted: 1$/m);
  assert.match(report, /by design$/m);
  assert.match(report, /^warning: --allow rule matched nothing: zero-size;stale$/m);
});

test("FINDING_KINDS covers every kind the analyzer can emit", () => {
  const emitted = new Set();
  const cases = [
    snapshot([node({ width: 0 })]),
    snapshot([node({ text_measured: { width: 999, height: 999 } })]),
    snapshot([node({ text: "x", left: 600, width: 100, clip: { left: 0, top: 0, width: 100, height: 100 } })]),
    snapshot([node({ left: 600, top: 440, width: 80, height: 80 })]),
    snapshot([node({ left: 700, width: 50 })]),
    snapshot([node({ left: 0, top: 0, width: 100, height: 20 })], {
      screen: { width: 640, height: 480, dpr: 1, safe_area: { top: 32, right: 0, bottom: 0, left: 0 } },
    }),
    snapshot([
      node({ path: "a[0]", id: "a", text: "a" }),
      node({ path: "b[1]", id: "b", text: "b" }),
    ]),
    snapshot([node({ hit: { left: 50, top: 50, width: 10, height: 10 } })]),
    snapshot([
      node({ path: "p[0]", id: "p", width: 100, height: 40 }),
      node({ path: "p[0]>c[0]", id: "c", width: 200, height: 20 }),
    ]),
  ];
  for (const value of cases) {
    for (const finding of analyzeSnapshot(value).findings) emitted.add(finding.kind);
  }
  assert.deepEqual([...emitted].sort(), [...FINDING_KINDS].sort());
});
