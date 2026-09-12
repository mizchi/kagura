import * as THREE from "three";

/** GPU-independent Three adapter, using the exported game bind mesh and local animation channels. */
export function createMotionScene(asset) {
  const root = new THREE.Group();
  const bones = asset.skeleton.map((b, i) => {
    const bone = new THREE.Bone();
    bone.name = "motion_bone_" + i;
    bone.position.fromArray(b.position);
    bone.quaternion.fromArray(b.rotation);
    bone.scale.fromArray(b.scale);
    return bone;
  });
  bones.forEach((bone, i) =>
    (asset.skeleton[i].parent < 0 ? root : bones[asset.skeleton[i].parent]).add(
      bone,
    ),
  );
  root.updateMatrixWorld(true);
  const skeleton = new THREE.Skeleton(bones);
  const clips = asset.clips.map(
    (c) =>
      new THREE.AnimationClip(
        c.id,
        c.duration,
        c.channels.map((ch) => {
          const type = {
            translation: THREE.VectorKeyframeTrack,
            rotation: THREE.QuaternionKeyframeTrack,
            scale: THREE.VectorKeyframeTrack,
          }[ch.target];
          const property = {
            translation: "position",
            rotation: "quaternion",
            scale: "scale",
          }[ch.target];
          const track = new type(
            `motion_bone_${ch.joint}.${property}`,
            ch.times,
            ch.values,
            ch.interpolation === "step"
              ? THREE.InterpolateDiscrete
              : THREE.InterpolateLinear,
          );
          // Preserve exact authored release times (e.g. 0.6); Float32 rounding must not delay Step keys.
          track.times = new Float64Array(ch.times);
          return track;
        }),
      ),
  );
  const mixer = new THREE.AnimationMixer(root),
    models = new Map();
  let model, action, clipId, lastTime;
  const helper = new THREE.SkeletonHelper(root);
  helper.material.depthTest = false;
  helper.renderOrder = 10;
  helper.visible = false;
  function selectModel(id) {
    const definition = asset.models.find((m) => m.id === id);
    if (!definition) throw Error("Unknown motion model");
    if (model) model.visible = false;
    model = models.get(id);
    if (!model) {
      model = new THREE.Group();
      for (const part of definition.parts) {
        const geometry = new THREE.BufferGeometry(),
          count = part.vertices.length / 8;
        const positions = new Float32Array(count * 3),
          normals = new Float32Array(count * 3),
          uv = new Float32Array(count * 2);
        for (let i = 0; i < count; i++) {
          positions.set(part.vertices.slice(i * 8, i * 8 + 3), i * 3);
          normals.set(part.vertices.slice(i * 8 + 3, i * 8 + 6), i * 3);
          uv.set(part.vertices.slice(i * 8 + 6, i * 8 + 8), i * 2);
        }
        geometry.setAttribute(
          "position",
          new THREE.BufferAttribute(positions, 3),
        );
        geometry.setAttribute("normal", new THREE.BufferAttribute(normals, 3));
        geometry.setAttribute("uv", new THREE.BufferAttribute(uv, 2));
        geometry.setAttribute(
          "skinIndex",
          new THREE.Uint16BufferAttribute(part.joints, 4),
        );
        geometry.setAttribute(
          "skinWeight",
          new THREE.Float32BufferAttribute(part.weights, 4),
        );
        geometry.setIndex(part.indices);
        const material = new THREE.MeshStandardMaterial({
          color: new THREE.Color(...part.color.slice(0, 3)),
          roughness: 0.85,
          metalness: 0.04,
          flatShading: true,
          side: THREE.DoubleSide,
          opacity: part.color[3],
          transparent: part.color[3] < 1,
        });
        const mesh = new THREE.SkinnedMesh(geometry, material);
        mesh.frustumCulled = false;
        mesh.bind(skeleton, new THREE.Matrix4());
        mesh.castShadow = true;
        mesh.receiveShadow = true;
        model.add(mesh);
      }
      models.set(id, model);
      root.add(model);
    }
    model.visible = true;
    return definition;
  }
  function pose(id, time) {
    if (id !== clipId) {
      const clip = clips.find((c) => c.name === id);
      if (!clip) throw Error("Unknown motion clip");
      mixer.stopAllAction();
      bones.forEach((bone, i) => {
        const rest = asset.skeleton[i];
        bone.position.fromArray(rest.position);
        bone.quaternion.fromArray(rest.rotation);
        bone.scale.fromArray(rest.scale);
      });
      action = mixer.clipAction(clip);
      action.reset().setLoop(THREE.LoopOnce, 1).play();
      action.clampWhenFinished = true;
      clipId = id;
      lastTime = undefined;
    }
    if (time !== lastTime) {
      action.enabled = true;
      action.paused = false;
      mixer.setTime(time);
      root.updateMatrixWorld(true);
      skeleton.update();
      helper.updateMatrixWorld(true);
      lastTime = time;
    }
  }
  selectModel(asset.models[0].id);
  return {
    root,
    helper,
    bones,
    selectModel,
    pose,
    bounds() {
      model.children.forEach((mesh) => mesh.computeBoundingBox());
      return new THREE.Box3().setFromObject(model);
    },
    dispose() {
      mixer.stopAllAction();
      mixer.uncacheRoot(root);
      skeleton.dispose();
      root.traverse((o) => {
        o.geometry?.dispose();
        o.material?.dispose();
      });
      helper.geometry.dispose();
      helper.material.dispose();
      root.clear();
    },
  };
}
