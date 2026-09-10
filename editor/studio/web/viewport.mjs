import * as THREE from 'three';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';

export function createViewport(container, app, api) {
  const renderer = new THREE.WebGLRenderer({ antialias: true, preserveDrawingBuffer: true });
  renderer.setPixelRatio(Math.min(devicePixelRatio, 2));
  renderer.setClearColor(0x202731);
  renderer.domElement.setAttribute('aria-label', '3D scene viewport');
  renderer.domElement.tabIndex = 0;
  container.prepend(renderer.domElement);
  const scene = new THREE.Scene();
  const camera = new THREE.PerspectiveCamera(42, 1, 0.05, 2000);
  const controls = new OrbitControls(camera, renderer.domElement);
  controls.enableDamping = true;
  const hemisphere = new THREE.HemisphereLight(0xe2edff, 0x55535c, 2.5);
  const sun = new THREE.DirectionalLight(0xffe4c3, 3.5);
  sun.position.set(4, 8, 5);
  scene.add(hemisphere, sun);
  const grid = new THREE.GridHelper(40, 40, 0x697784, 0x384450);
  grid.position.y = 0.01;
  scene.add(grid);
  const selectionBox = new THREE.BoxHelper(new THREE.Object3D(), 0xffc775);
  selectionBox.visible = false;
  scene.add(selectionBox);
  const flash = new THREE.Mesh(new THREE.SphereGeometry(0.24, 12, 8), new THREE.MeshBasicMaterial({ color: 0xffdd8b }));
  flash.visible = false;
  scene.add(flash);
  let root, currentRevision = -1, current, playing = false, lastFrame = 0, frame;
  function disposeTree(object) {
    object.traverse(n => {
      n.geometry?.dispose();
      for (const m of Array.isArray(n.material) ? n.material : n.material ? [n.material] : []) m.dispose();
    });
  }
  function update(snapshot) {
    current = snapshot;
    if (snapshot.revision !== currentRevision) {
      playing = false;
      if (root) { scene.remove(root); disposeTree(root); }
      root = app.build_scene();
      scene.add(root);
      currentRevision = snapshot.revision;
    }
    const actor = root.getObjectByName(snapshot.document.action.target);
    const source = snapshot.document.nodes.find(n => n.id === snapshot.document.action.target);
    if (actor && source) {
      actor.position.z = source.position[2] + snapshot.preview.offset;
      actor.updateWorldMatrix(true, false);
      flash.position.copy(actor.localToWorld(new THREE.Vector3(0, 0.2, 0.7)));
    }
    flash.visible = !!actor && snapshot.preview.flash;
    const selected = root.getObjectByName(snapshot.selection);
    selectionBox.visible = !!selected;
    if (selected) selectionBox.setFromObject(selected);
  }
  const unsubscribe = api.subscribe(update);
  update(api.snapshot());
  function view(name) {
    const target = new THREE.Vector3(0, 0.5, 0);
    const offsets = { perspective: [10, 8, 12], front: [0, 1, 16], side: [16, 1, 0], top: [0, 18, 0.01] };
    camera.position.fromArray(offsets[name] ?? offsets.perspective).add(target);
    controls.target.copy(target);
    controls.update();
  }
  view('perspective');
  const observer = new ResizeObserver(() => {
    const { width, height } = container.getBoundingClientRect();
    renderer.setSize(width, height, false);
    camera.aspect = width / Math.max(1, height);
    camera.updateProjectionMatrix();
  });
  observer.observe(container);
  let down;
  const onDown = e => { down = { x: e.clientX, y: e.clientY, button: e.button }; };
  const onUp = e => {
    if (!down || down.button !== 0 || Math.hypot(e.clientX - down.x, e.clientY - down.y) > 4) return;
    const rect = renderer.domElement.getBoundingClientRect();
    const ray = new THREE.Raycaster();
    ray.setFromCamera(new THREE.Vector2((e.clientX - rect.left) / rect.width * 2 - 1, -(e.clientY - rect.top) / rect.height * 2 + 1), camera);
    const hit = ray.intersectObjects(root.children, true)[0];
    api.select(hit?.object.name ?? '');
  };
  renderer.domElement.addEventListener('pointerdown', onDown);
  renderer.domElement.addEventListener('pointerup', onUp);
  function animate(time) {
    const dt = Math.min((time - lastFrame) / 1000, 0.05);
    lastFrame = time;
    if (playing) {
      const next = Math.min(current.preview.time + dt, current.document.action.duration);
      app.seek(Math.round(next * 1000) / 1000);
      if (next >= current.document.action.duration) playing = false;
    }
    controls.update();
    renderer.render(scene, camera);
    frame = requestAnimationFrame(animate);
  }
  frame = requestAnimationFrame(animate);
  const onVisibility = () => { if (document.hidden) playing = false; };
  document.addEventListener('visibilitychange', onVisibility);
  return {
    view,
    frame(id) {
      const object = root.getObjectByName(id);
      if (!object) return;
      const bounds = new THREE.Box3().setFromObject(object);
      if (bounds.isEmpty()) return;
      const center = bounds.getCenter(new THREE.Vector3());
      const distance = Math.max(bounds.getSize(new THREE.Vector3()).length() * 1.6, 2);
      const direction = camera.position.clone().sub(controls.target).normalize();
      controls.target.copy(center);
      camera.position.copy(center).addScaledVector(direction, distance);
      controls.update();
    },
    play() { app.seek(0); playing = true; },
    pause() { playing = false; },
    dispose() {
      cancelAnimationFrame(frame); unsubscribe(); observer.disconnect(); controls.dispose();
      document.removeEventListener('visibilitychange', onVisibility);
      renderer.domElement.removeEventListener('pointerdown', onDown);
      renderer.domElement.removeEventListener('pointerup', onUp);
      disposeTree(scene); renderer.dispose(); renderer.domElement.remove();
    },
  };
}
