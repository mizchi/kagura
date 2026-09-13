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
            new Vector3(-0.03, -0.13, 0.06),
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

test('cleaver exports three independent cuts with a longer overhead recovery',async()=>{
  const data=validateMotionAsset(JSON.parse(await readFile(new URL('../../../examples/games/hacknslash_3d/motions/hunter.kgrmotion',import.meta.url),'utf8')));
  const weapon=data.weapons.find(w=>w.id==='cleaver_flintlock');
  const cuts=weapon.clips.slice(0,3).map(id=>data.clips.find(c=>c.id===id));
  assert.deepEqual(cuts.map(c=>c.events[0].time),[7,8,16].map(n=>n/60));
  assert.deepEqual(cuts.map(c=>c.duration),[19,22,48].map(n=>n/60));
  const scene=createMotionScene(data);
  try{
    scene.selectWeapon(weapon.id);
    const poses=cuts.map(clip=>{
      scene.pose(clip.id,clip.events[0].time);
      assert.ok(!scene.bounds().isEmpty());
      return scene.bones[2].getWorldQuaternion(new Quaternion());
    });
    assert.ok(poses[0].angleTo(poses[1])>.2);
    assert.ok(poses[1].angleTo(poses[2])>.2);
    scene.pose(cuts[2].id,40/60);
    const recovering=scene.bones[1].quaternion.clone();
    scene.pose(cuts[2].id,48/60);
    assert.ok(recovering.angleTo(scene.bones[1].quaternion)>.01);
  }finally{scene.dispose();}
});

test('wolf asset uses four legs, loops walk/run in place and closes its jaw at bite contact',async()=>{
  const data=validateMotionAsset(JSON.parse(await readFile(new URL('../../../examples/games/hacknslash_3d/motions/wolf.kgrmotion',import.meta.url),'utf8')));
  assert.equal(data.skeleton.length,15);
  assert.deepEqual(data.clips.map(c=>c.id),['wolf_walk','wolf_run','wolf_bite']);
  const scene=createMotionScene(data);
  try{
    scene.selectModel('wolf');
    for(const clip of data.clips.slice(0,2)){
      scene.pose(clip.id,0);
      const start=scene.bones.map(b=>b.getWorldQuaternion(new Quaternion()));
      scene.pose(clip.id,clip.duration/4);
      for(const joint of [7,9,11,13]) assert.ok(start[joint].angleTo(scene.bones[joint].getWorldQuaternion(new Quaternion()))>.1);
      assert.equal(scene.bones[0].position.z,0);
      scene.pose(clip.id,clip.duration);
      scene.bones.forEach((b,i)=>assert.ok(start[i].angleTo(b.getWorldQuaternion(new Quaternion()))<.001));
      for(let i=0;i<=24;i++){
        scene.pose(clip.id,clip.duration*i/24);
        assert.ok(scene.bounds().min.y>-.06,`${clip.id} feet must not sink through the ground`);
      }
    }
    const bite=data.clips[2];
    assert.equal(bite.events[0].time,34/60);
    scene.pose(bite.id,24/60);
    assert.ok(scene.bones[4].quaternion.x>.2,'jaw opens during anticipation');
    scene.pose(bite.id,bite.events[0].time);
    assert.ok(Math.abs(scene.bones[4].quaternion.x)<.001,'jaw closes exactly on impact');
    assert.ok(scene.bones[0].position.z>.2,'head and body snap forward');
    scene.pose(bite.id,bite.duration);
    assert.equal(scene.bones[0].position.z,0);
  }finally{scene.dispose();}
});

test('zombie asset shows a dragging gait and raises its hands before the landing event',async()=>{
  const data=validateMotionAsset(JSON.parse(await readFile(new URL('../../../examples/games/hacknslash_3d/motions/zombie.kgrmotion',import.meta.url),'utf8')));
  assert.equal(data.skeleton.length,16);
  assert.deepEqual(data.clips.map(c=>c.id),['zombie_idle','zombie_shamble','zombie_pounce']);
  assert.equal(data.weapons[0].parts.length,0);
  const scene=createMotionScene(data);
  try {
    scene.selectModel('zombie');
    const walk=data.clips[1],pounce=data.clips[2];
    scene.pose(walk.id,0);
    const start=scene.bones.map(b=>b.quaternion.clone());
    scene.pose(walk.id,walk.duration/4);
    assert.ok(start[7].angleTo(scene.bones[7].quaternion)>start[9].angleTo(scene.bones[9].quaternion)*2);
    scene.pose(walk.id,walk.duration);
    scene.bones.forEach((b,i)=>assert.ok(start[i].angleTo(b.quaternion)<.001));
    for(const clip of data.clips)for(let i=0;i<=30;i++) {
      scene.pose(clip.id,clip.duration*i/30);
      assert.ok(scene.bounds().min.y>-.06,`${clip.id} feet must not sink into the floor`);
      assert.equal(scene.bones[0].position.z,0,'simulation owns forward movement');
    }
    scene.pose(pounce.id,36/60);
    const head=scene.bones[2].getWorldPosition(new Vector3());
    for(const joint of [4,6]) {
      const hand=scene.bones[joint].localToWorld(new Vector3(0,-.17,.05));
      assert.ok(hand.y>head.y+.2,'both hands rise above the neck before takeoff');
    }
    scene.pose(pounce.id,43/60);
    assert.ok(scene.bones[0].position.y>.4);
    assert.equal(pounce.events[0].time,50/60);
    scene.pose(pounce.id,pounce.events[0].time);
    assert.ok(Math.abs(scene.bones[0].position.y)<.001,'impact is exactly at landing');
  } finally {scene.dispose();}
});
