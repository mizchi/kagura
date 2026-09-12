import { test } from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import { Vector3 } from "three";
import { validateMotionAsset } from "../motions/contract.mjs";
import { createMotionScene } from "../motions/scene.mjs";
const asset = validateMotionAsset(
  JSON.parse(
    await readFile(
      new URL(
        "../../../examples/games/hacknslash_3d/motions/enemies.kgrmotion",
        import.meta.url,
      ),
      "utf8",
    ),
  ),
);

test("game-exported bow keeps the string in the hand and removes its arrow exactly at release", () => {
  const scene = createMotionScene(asset),
    clip = asset.clips.find((c) => c.id === "bow_shot");
  try {
    assert.equal(asset.models.length, 6);
    assert.equal(asset.clips.length, 4);
    scene.selectModel("archer");
    scene.pose(clip.id, clip.events[0].time - 1 / 60);
    const string = scene.bones[14].getWorldPosition(new Vector3());
    const hand = scene.bones[6].localToWorld(new Vector3(0.02, -0.16, 0.035));
    assert.ok(string.distanceTo(hand) < 0.001);
    assert.equal(scene.bones[15].scale.x, 1);
    scene.pose(clip.id, clip.events[0].time);
    assert.equal(scene.bones[15].scale.x, 0);
    scene.pose(clip.id, clip.duration);
    scene.pose(clip.id, clip.events[0].time - 1 / 60);
    assert.equal(
      scene.bones[15].scale.x,
      1,
      "backward seek after the final pose resumes sampling",
    );
    scene.selectModel("goblin");
    scene.pose("punch", 0);
    assert.ok(
      scene.bones[14].position.distanceTo(new Vector3(0, 0, -0.13)) < 1e-6,
      "clip switch resets untracked prop translations",
    );
  } finally {
    scene.dispose();
  }
});
