import * as THREE from "three";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";
import { createMotionScene } from "./scene.mjs";

/** A viewer owns its canvas, animation loop and GPU resources; dispose on every pane/project change. */
export function createMotionViewer(container, asset, player, onFrame) {
  const renderer = new THREE.WebGLRenderer({
    antialias: true,
    preserveDrawingBuffer: true,
  });
  renderer.setPixelRatio(Math.min(devicePixelRatio, 2));
  renderer.setClearColor(0x121c26);
  renderer.domElement.tabIndex = 0;
  renderer.domElement.setAttribute("aria-label", "Motion viewport");
  container.append(renderer.domElement);
  const scene = new THREE.Scene(),
    camera = new THREE.PerspectiveCamera(35, 1, 0.01, 100);
  const controls = new OrbitControls(camera, renderer.domElement);
  controls.enableDamping = false;
  const actor = createMotionScene(asset);
  scene.add(actor.root, actor.helper);
  scene.add(new THREE.HemisphereLight(0xe3efff, 0x293525, 2));
  const light = new THREE.DirectionalLight(0xffe8cf, 2.4);
  light.position.set(3, 5, 4);
  scene.add(light);
  const rim = new THREE.DirectionalLight(0x83aedc, 1.4);
  rim.position.set(-3, 2, -2);
  scene.add(rim);
  const grid = new THREE.GridHelper(8, 32, 0x52616e, 0x273641);
  scene.add(grid);
  let firstResize = true,
    dirty = true,
    disposed = false,
    raf = 0,
    lastNow,
    previousTime,
    previousClip;
  const change = () => {
    dirty = true;
  };
  controls.addEventListener("change", change);
  function view(direction = "orbit") {
    const vectors = {
      orbit: [0.7, 0.35, 1],
      front: [0, 0, 1],
      side: [1, 0, 0],
      top: [0, 1, 0.001],
    };
    const position = vectors[direction];
    if (!position) throw Error("Unknown camera view");
    const bounds = actor.bounds(),
      center = bounds.getCenter(new THREE.Vector3()),
      radius = Math.max(bounds.getSize(new THREE.Vector3()).length() / 2, 0.01);
    const distance =
      ((radius / Math.sin(THREE.MathUtils.degToRad(camera.fov / 2))) * 1.12) /
      Math.min(camera.aspect, 1);
    controls.target.copy(center);
    camera.position
      .copy(center)
      .add(new THREE.Vector3(...position).normalize().multiplyScalar(distance));
    camera.near = radius / 1000;
    camera.far = distance * 100;
    camera.updateProjectionMatrix();
    controls.minDistance = radius * 0.25;
    controls.maxDistance = distance * 10;
    controls.update();
    dirty = true;
  }
  const resize = new ResizeObserver(() => {
    const { width, height } = container.getBoundingClientRect();
    if (width > 0 && height > 0) {
      renderer.setSize(width, height, false);
      camera.aspect = width / height;
      camera.updateProjectionMatrix();
      if (firstResize) {
        firstResize = false;
        view();
      }
      dirty = true;
    }
  });
  resize.observe(container);
  const visibility = () => {
    lastNow = undefined;
  };
  document.addEventListener("visibilitychange", visibility);
  function draw(now) {
    if (disposed) return;
    raf = requestAnimationFrame(draw);
    if (document.hidden) {
      lastNow = undefined;
      return;
    }
    if (lastNow !== undefined)
      player.tick(Math.min((now - lastNow) / 1000, 0.25));
    lastNow = now;
    const state = player.snapshot();
    if (state.time !== previousTime || state.clip !== previousClip) {
      actor.pose(state.clip, state.time);
      dirty = true;
      previousTime = state.time;
      previousClip = state.clip;
    }
    if (dirty) {
      renderer.render(scene, camera);
      dirty = false;
      container.dataset.ready = "true";
      container.dataset.frame = String(state.frame);
      container.dataset.clip = state.clip;
    }
    onFrame(state);
  }
  view();
  raf = requestAnimationFrame(draw);
  return {
    view,
    model(id) {
      actor.selectModel(id);
      dirty = true;
    },
    skeleton(show) {
      actor.helper.visible = show;
      dirty = true;
    },
    grid(show) {
      grid.visible = show;
      dirty = true;
    },
    dispose() {
      if (disposed) return;
      disposed = true;
      cancelAnimationFrame(raf);
      document.removeEventListener("visibilitychange", visibility);
      resize.disconnect();
      controls.dispose();
      actor.dispose();
      grid.geometry.dispose();
      grid.material.dispose();
      renderer.dispose();
      renderer.forceContextLoss();
      renderer.domElement.remove();
      delete container.dataset.ready;
    },
  };
}
