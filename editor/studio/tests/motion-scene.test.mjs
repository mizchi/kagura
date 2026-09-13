import { test } from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import { Vector3, Quaternion } from "three";
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
    assert.equal(asset.models.length, 5);
    assert.equal(asset.clips.length, 5);
    assert.equal(asset.weapons.length, 4);
    scene.selectModel("skeleton");
    scene.selectWeapon("bow");
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

test("every body accepts every weapon and swapping equipment leaves body geometry and pose intact", () => {
  const before = structuredClone(asset);
  const scene = createMotionScene(asset);
  try {
    for (const model of asset.models) {
      assert.ok(
        model.parts.every((part) => part.joints.every((joint) => joint < 12)),
        "weapon geometry is absent from species",
      );
      scene.selectModel(model.id);
      for (const weapon of asset.weapons) {
        scene.selectWeapon(weapon.id);
        const clip = asset.clips.find((clip) => clip.id === weapon.defaultClip);
        scene.pose(clip.id, clip.events[0].time - 1 / 60);
        const groups = scene.root.children.filter(
          (child) => child.type === "Group" && child.visible,
        );
        assert.deepEqual(
          groups.map((group) => group.name).sort(),
          ["body:" + model.id, "weapon:" + weapon.id].sort(),
        );
        assert.ok(!scene.bounds().isEmpty());
      }
    }
    scene.selectWeapon("bow");
    scene.pose("bow_shot", 0.58);
    const pose = scene.bones.map((bone) => bone.matrixWorld.toArray());
    scene.selectModel("goblin");
    assert.deepEqual(
      scene.bones.map((bone) => bone.matrixWorld.toArray()),
      pose,
    );
    assert.deepEqual(asset, before);
    assert.throws(() => scene.selectWeapon("absent"));
  } finally {
    scene.dispose();
  }
});

test("hunter exports every playable weapon with matching contact and bow attachments", async () => {
  const hunter = validateMotionAsset(
    JSON.parse(
      await readFile(
        new URL(
          "../../../examples/games/hacknslash_3d/motions/hunter.kgrmotion",
          import.meta.url,
        ),
        "utf8",
      ),
    ),
  );
  const scene = createMotionScene(hunter);
  try {
    assert.deepEqual(
      hunter.models.map((m) => m.id),
      [
        "hunter", "hunter_goblin", "hunter_kobold", "hunter_skeleton",
        "hunter_bare", "hunter_leather", "hunter_plate", "hunter_occult",
      ],
    );
    assert.deepEqual(
      hunter.weapons.map((w) => w.id),
      ["cleaver_flintlock", "spear", "knuckles", "focus", "bow", "shield_guard"],
    );
    for (const model of hunter.models) {
      scene.selectModel(model.id);
      for (const [index, weapon] of hunter.weapons.entries()) {
        scene.selectWeapon(weapon.id);
        const clip = hunter.clips.find((c) => c.id === weapon.defaultClip);
        assert.equal(clip.events[0].time, [7, 16, 10, 24, 30, 5][index] / 60);
        scene.pose(clip.id, clip.events[0].time - 1 / 60);
        assert.ok(!scene.bounds().isEmpty());
        if (weapon.id === "bow") {
          const hand = scene.bones[3].localToWorld(
            new Vector3(0.03, -0.13, 0.06),
          );
          assert.ok(
            scene.bones[15].getWorldPosition(new Vector3()).distanceTo(hand) <
              0.005,
          );
          assert.equal(scene.bones[16].scale.x, 1);
          scene.pose(clip.id, clip.events[0].time);
          assert.equal(scene.bones[16].scale.x, 0);
        }
      }
    }
  } finally {
    scene.dispose();
  }
});

test("charge is shared across weapon sets with launch and brake events and no root travel", async () => {
  for (const [name, brake, duration] of [
    ["enemies", 21 / 60, 37 / 60],
    ["hunter", 24 / 60, 42 / 60],
  ]) {
    const data = validateMotionAsset(
      JSON.parse(
        await readFile(
          new URL(
            `../../../examples/games/hacknslash_3d/motions/${name}.kgrmotion`,
            import.meta.url,
          ),
          "utf8",
        ),
      ),
    );
    for (const weapon of data.weapons.filter(w => w.id !== "shield_guard"))
      assert.ok(weapon.clips.includes("charge"));
    const clip = data.clips.find((c) => c.id === "charge");
    assert.deepEqual(clip.events, [
      { name: "Launch", time: 0.2 },
      { name: "Brake", time: brake },
    ]);
    assert.equal(clip.duration, duration);
    const scene = createMotionScene(data);
    try {
      scene.selectModel(data.models[0].id);
      scene.selectWeapon("spear");
      scene.pose("charge", 0.1);
      const before = scene.bones[1].matrixWorld.toArray();
      scene.pose("charge", 0.25);
      assert.notDeepEqual(scene.bones[1].matrixWorld.toArray(), before);
      assert.equal(scene.bones[0].position.x, 0);
      assert.equal(scene.bones[0].position.z, 0);
      assert.equal(scene.bones.at(-1).scale.x, 0);
      assert.ok(!scene.bounds().isEmpty());
    } finally {
      scene.dispose();
    }
  }
});

test('hunter combat arts export the actual contact frames and a separate shield attachment',async()=>{
  const data=validateMotionAsset(JSON.parse(await readFile(new URL('../../../examples/games/hacknslash_3d/motions/hunter.kgrmotion',import.meta.url),'utf8')));
  const scene=createMotionScene(data);
  try {
    for(const [id,frame] of [['lightning_cast',10],['flame_cast',14],['astral_cast',30],['dash_strike',16],['guard',5]]){
      const clip=data.clips.find(c=>c.id===id);
      assert.equal(clip.events[0].time,frame/60);
      scene.selectWeapon(id==='guard'?'shield_guard':'cleaver_flintlock');
      scene.pose(id,.02);const before=scene.bones[7].getWorldQuaternion(new Quaternion());
      scene.pose(id,frame/60);
      assert.ok(before.angleTo(scene.bones[7].getWorldQuaternion(new Quaternion()))>.01);
      assert.ok(!scene.bounds().isEmpty());
    }
  } finally {scene.dispose();}
});

test('whirlwind is a seamless spinning clip shared by every main weapon',async()=>{
  const data=validateMotionAsset(JSON.parse(await readFile(new URL('../../../examples/games/hacknslash_3d/motions/hunter.kgrmotion',import.meta.url),'utf8')));
  const clip=data.clips.find(c=>c.id==='whirlwind');
  assert.ok(clip);
  assert.equal(clip.duration,24/60);
  assert.equal(clip.events[0].time,6/60);
  const scene=createMotionScene(data);
  try {
    for(const weapon of data.weapons.filter(w=>w.id!=='shield_guard')){
      assert.ok(weapon.clips.includes(clip.id));
      scene.selectWeapon(weapon.id);
      scene.pose(clip.id,0);
      const start=scene.bones.map(b=>b.getWorldQuaternion(new Quaternion()));
      scene.pose(clip.id,clip.duration/2);
      assert.ok(start[0].angleTo(scene.bones[0].getWorldQuaternion(new Quaternion()))>3);
      scene.pose(clip.id,clip.duration);
      scene.bones.forEach((b,i)=>assert.ok(start[i].angleTo(b.getWorldQuaternion(new Quaternion()))<.001));
      assert.ok(!scene.bounds().isEmpty());
    }
  } finally {scene.dispose();}
});
