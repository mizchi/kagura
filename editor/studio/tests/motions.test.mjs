import { test } from "node:test";
import assert from "node:assert/strict";
import {
  validateMotionAsset,
  prepareMotionAsset,
} from "../motions/contract.mjs";
import { createMotionPlayer } from "../motions/player.mjs";

export const fixture = () => ({
  format: "kagura.motion",
  version: 1,
  name: "Test rig",
  skeleton: [
    {
      name: "root",
      parent: -1,
      position: [0, 0, 0],
      rotation: [0, 0, 0, 1],
      scale: [1, 1, 1],
    },
  ],
  models: [
    {
      id: "actor",
      name: "Actor",
      defaultClip: "punch",
      parts: [
        {
          name: "body",
          color: [0.8, 0.3, 0.2, 1],
          vertices: [
            0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0,
            0,
          ],
          indices: [0, 1, 2],
          joints: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          weights: [1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0],
        },
      ],
    },
  ],
  clips: [
    {
      id: "punch",
      name: "Punch",
      duration: 1,
      fps: 60,
      events: [{ name: "Impact", time: 0.4 }],
      channels: [
        {
          joint: 0,
          target: "translation",
          interpolation: "linear",
          times: [0, 1],
          values: [0, 0, 0, 0, 1, 0],
        },
      ],
    },
  ],
});

test("portable assets validate skin indices, hierarchy, animation and contact references", () => {
  const raw = fixture(),
    asset = validateMotionAsset(raw);
  assert.deepEqual(asset, raw);
  assert.notEqual(asset, raw);
  for (const mutate of [
    (x) => (x.skeleton[0].parent = 0),
    (x) => (x.models[0].parts[0].indices[2] = 9),
    (x) => (x.models[0].parts[0].joints[0] = 1),
    (x) => (x.models[0].parts[0].weights[0] = 0.5),
    (x) => (x.models[0].defaultClip = "missing"),
    (x) => (x.clips[0].channels[0].times = [1, 0]),
    (x) => (x.clips[0].channels[0].values[0] = Infinity),
    (x) => (x.clips[0].channels[0].joint = 1),
    (x) => x.clips[0].channels.push(structuredClone(x.clips[0].channels[0])),
    (x) => (x.clips[0].events[0].time = 2),
    (x) => (x.skeleton[0].rotation = [0, 0, 0, 2]),
    (x) => (x.format = "other"),
    (x) => (x.unexpected = true),
  ]) {
    const bad = fixture();
    mutate(bad);
    assert.throws(() => validateMotionAsset(bad));
  }
});

test("preparation reads through project resources and rejects oversized inputs", async () => {
  let path;
  const asset = await prepareMotionAsset(
    {
      read: async (key) => {
        path = key;
        return new Blob([JSON.stringify(fixture())]);
      },
    },
    "animations/enemy.kgrmotion",
  );
  assert.equal(path, "animations/enemy.kgrmotion");
  assert.equal(asset.name, "Test rig");
  await assert.rejects(
    () =>
      prepareMotionAsset(
        { read: async () => ({ size: 65 * 1024 * 1024 }) },
        "large.kgrmotion",
      ),
    /64 MiB/,
  );
});

test("transport pauses on seek and step, preserves the final pose, and restarts deliberately", () => {
  const player = createMotionPlayer(fixture());
  player.play();
  player.tick(0.25);
  assert.equal(player.snapshot().time, 0.25);
  player.seek(0.4);
  assert.equal(player.snapshot().playing, false);
  player.step(1);
  assert.ok(Math.abs(player.snapshot().time - 25 / 60) < 1e-9);
  player.step(-1);
  assert.equal(player.snapshot().time, 0.4);
  player.setLoop(false);
  player.play();
  player.tick(3);
  assert.equal(player.snapshot().time, 1);
  assert.equal(player.snapshot().playing, false);
  player.play();
  assert.equal(player.snapshot().time, 0);
  player.setSpeed(0.5);
  player.tick(0.5);
  assert.equal(player.snapshot().time, 0.25);
  player.setLoop(true);
  player.tick(2);
  assert.equal(player.snapshot().time, 0.25);
  player.seek(-1);
  assert.equal(player.snapshot().time, 0);
  player.seek(100);
  assert.equal(player.snapshot().time, 1);
  for (const action of [
    () => player.seek(NaN),
    () => player.setSpeed(0),
    () => player.selectClip("missing"),
    () => player.tick(Infinity),
  ])
    assert.throws(action);
});
