import test from "node:test";
import assert from "node:assert/strict";
import { runtimePickTargets } from "../runtime/picking.mjs";
test("2D picking uses declared subject bindings and observed bounds, never object-name guesses", () => {
  const hierarchy = [
    {
      id: "world",
      children: [
        { id: "world/body", subject: "bird", children: [] },
        { id: "world/decoration", children: [] },
      ],
    },
  ];
  const observation = {
    nodes: [
      {
        path: "world>body",
        left: 60,
        top: 80,
        width: 12,
        height: 12,
        visible: true,
      },
      {
        path: "world>decoration",
        left: 0,
        top: 0,
        width: 300,
        height: 240,
        visible: true,
      },
    ],
  };
  assert.deepEqual(
    runtimePickTargets(hierarchy, observation, new Set(["bird"])),
    [{ subject: "bird", left: 60, top: 80, width: 12, height: 12 }],
  );
  assert.deepEqual(runtimePickTargets(hierarchy, observation, new Set()), []);
  observation.nodes[0].width = NaN;
  assert.deepEqual(
    runtimePickTargets(hierarchy, observation, new Set(["bird"])),
    [],
  );
});
