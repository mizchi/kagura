import assert from "node:assert/strict";
import test from "node:test";

import { elementKeys, resolveScale, toVlmkitElements, unwrapSnapshot } from "./ui-snapshot-utils.mjs";

function snapshot(nodes, screen = {}) {
  return {
    screen: { width: 640, height: 480, dpr: 1, safe_area: { top: 0, right: 0, bottom: 0, left: 0 }, ...screen },
    frame: 0,
    state: "playing",
    nodes,
    focus_order: [],
  };
}

function node(overrides) {
  return {
    path: "hud[0]",
    id: "hud",
    tag: "panel",
    role: "panel",
    classes: "hud-root",
    left: 0,
    top: 0,
    width: 100,
    height: 20,
    z: 0,
    visible: true,
    ...overrides,
  };
}

test("unwrapSnapshot accepts a raw snapshot", () => {
  const raw = snapshot([node({})]);
  assert.equal(unwrapSnapshot(raw), raw);
});

test("unwrapSnapshot accepts a JSON string", () => {
  const raw = snapshot([node({})]);
  assert.deepEqual(unwrapSnapshot(JSON.stringify(raw)), raw);
});

test("unwrapSnapshot unwraps the __kaguraUISnapshot envelope", () => {
  const raw = snapshot([node({})]);
  assert.deepEqual(unwrapSnapshot({ json: JSON.stringify(raw), parsed: raw }), raw);
});

test("unwrapSnapshot falls back to the envelope's raw json when parsed is null", () => {
  // The publish hook keeps the string when JSON.parse failed in the page, so a
  // null `parsed` must not lose the document.
  const raw = snapshot([node({})]);
  assert.deepEqual(unwrapSnapshot({ json: JSON.stringify(raw), parsed: null }), raw);
});

test("unwrapSnapshot rejects documents with no nodes array", () => {
  assert.throws(() => unwrapSnapshot({ screen: {} }), /no `nodes` array/);
  assert.throws(() => unwrapSnapshot(42), /must be an object or a JSON string/);
});

test("resolveScale reads dpr off the snapshot by default", () => {
  assert.equal(resolveScale(snapshot([], { dpr: 2 })), 2);
  assert.equal(resolveScale(snapshot([], { dpr: 1 })), 1);
});

test("resolveScale falls back to 1 for a missing or nonsense dpr", () => {
  assert.equal(resolveScale({ screen: {} }), 1);
  assert.equal(resolveScale(snapshot([], { dpr: 0 })), 1);
  assert.equal(resolveScale(snapshot([], { dpr: Number.NaN })), 1);
});

test("resolveScale accepts an explicit factor", () => {
  assert.equal(resolveScale(snapshot([], { dpr: 2 }), "1"), 1);
  assert.equal(resolveScale(snapshot([], { dpr: 2 }), 3), 3);
  assert.throws(() => resolveScale(snapshot([]), "0"), /invalid scale/);
  assert.throws(() => resolveScale(snapshot([]), "wat"), /invalid scale/);
});

test("toVlmkitElements emits exactly the keys vlmkit reads", () => {
  const { elements } = toVlmkitElements(snapshot([node({})]));
  assert.equal(elements.length, 1);
  assert.deepEqual(Object.keys(elements[0]).sort(), elementKeys().sort());
});

test("toVlmkitElements maps snapshot fields onto the rect schema", () => {
  const { elements } = toVlmkitElements(
    snapshot([node({ path: "hud[0]>bar[0]", id: "hp_bar", tag: "gauge", classes: "hud gauge", left: 16, top: 24, width: 200, height: 20 })]),
  );
  assert.deepEqual(elements[0], {
    path: "hud[0]>bar[0]",
    tag: "gauge",
    id: "hp_bar",
    classes: "hud gauge",
    top: 24,
    left: 16,
    width: 200,
    height: 20,
  });
});

test("toVlmkitElements scales rects to frame pixels by dpr", () => {
  // The captured PNG is dpr-scaled; leaving rects in logical units would
  // misalign every element against the image.
  const { elements } = toVlmkitElements(
    snapshot([node({ left: 16, top: 24, width: 200, height: 20 })], { dpr: 2 }),
  );
  assert.deepEqual(
    { left: elements[0].left, top: elements[0].top, width: elements[0].width, height: elements[0].height },
    { left: 32, top: 48, width: 400, height: 40 },
  );
});

test("toVlmkitElements can be pinned to an explicit scale", () => {
  const { elements } = toVlmkitElements(snapshot([node({ width: 100, height: 20 })], { dpr: 2 }), { scale: "1" });
  assert.equal(elements[0].width, 100);
});

test("toVlmkitElements falls back to role when tag is absent", () => {
  const { elements } = toVlmkitElements(snapshot([{ path: "a[0]", role: "gauge", left: 0, top: 0, width: 10, height: 10 }]));
  assert.equal(elements[0].tag, "gauge");
});

test("toVlmkitElements defaults tag to node when neither tag nor role is present", () => {
  const { elements } = toVlmkitElements(snapshot([{ path: "a[0]", left: 0, top: 0, width: 10, height: 10 }]));
  assert.equal(elements[0].tag, "node");
});

test("toVlmkitElements drops invisible nodes", () => {
  // An invisible node owns no pixels, so attributing a diff region to it would
  // point the reader at the wrong place.
  const { elements } = toVlmkitElements(
    snapshot([node({ id: "shown" }), node({ path: "hud[1]", id: "hidden", visible: false })]),
  );
  assert.deepEqual(elements.map((element) => element.id), ["shown"]);
});

test("toVlmkitElements can keep invisible nodes on request", () => {
  const { elements } = toVlmkitElements(
    snapshot([node({ id: "shown" }), node({ path: "hud[1]", id: "hidden", visible: false })]),
    { includeInvisible: true },
  );
  assert.deepEqual(elements.map((element) => element.id), ["shown", "hidden"]);
});

test("toVlmkitElements drops zero-area nodes vlmkit would reject anyway", () => {
  const { elements } = toVlmkitElements(
    snapshot([node({ id: "flat", height: 0 }), node({ path: "hud[1]", id: "thin", width: -5 }), node({ path: "hud[2]", id: "ok" })]),
  );
  assert.deepEqual(elements.map((element) => element.id), ["ok"]);
});

test("toVlmkitElements drops nodes with no path, which vlmkit requires", () => {
  const { elements } = toVlmkitElements(snapshot([{ tag: "x", left: 0, top: 0, width: 10, height: 10 }]));
  assert.deepEqual(elements, []);
});

test("toVlmkitElements tolerates non-finite coordinates", () => {
  const { elements } = toVlmkitElements(
    snapshot([node({ left: Number.NaN, top: Number.POSITIVE_INFINITY, width: 10, height: 10 })]),
  );
  assert.equal(elements[0].left, 0);
  assert.equal(elements[0].top, 0);
});

test("toVlmkitElements accepts the browser envelope", () => {
  const raw = snapshot([node({})]);
  const { elements } = toVlmkitElements({ json: JSON.stringify(raw), parsed: raw });
  assert.equal(elements.length, 1);
});
