import * as THREE from "three";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";
import { meshGeometry, disposeObject } from "./geometry.mjs";

export function createModelViewport(
  container,
  { select, vertex, face, pointerDown, pointerMove, onCamera },
) {
  const renderer = new THREE.WebGLRenderer({
    antialias: true,
    preserveDrawingBuffer: true,
  });
  renderer.setPixelRatio(Math.min(devicePixelRatio, 2));
  renderer.setClearColor(0x20262b);
  renderer.outputColorSpace = THREE.SRGBColorSpace;
  const canvas = renderer.domElement;
  canvas.tabIndex = 0;
  canvas.setAttribute("aria-label", "Modeling viewport");
  container.append(canvas);
  const scene = new THREE.Scene(),
    root = new THREE.Group();
  scene.add(root);
  const perspective = new THREE.PerspectiveCamera(37, 1, 0.02, 200);
  const ortho = new THREE.OrthographicCamera(-3, 3, 3, -3, 0.02, 200);
  let camera = perspective,
    controls,
    width = 1,
    height = 1,
    frame,
    current,
    overlay,
    wire = false,
    disposed = false;
  const objects = new Map();
  const sun = new THREE.DirectionalLight(0xffefd3, 3.0);
  sun.position.set(-3, 6, 5);
  const rim = new THREE.DirectionalLight(0xc0e8e3, 1.6);
  rim.position.set(4, 3, -5);
  scene.add(new THREE.HemisphereLight(0xe2f2ec, 0x535246, 2.3), sun, rim);
  const floor = new THREE.Mesh(
    new THREE.CircleGeometry(3.9, 80),
    new THREE.MeshStandardMaterial({ color: 0x303d3c, roughness: 1 }),
  );
  floor.rotation.x = -Math.PI / 2;
  floor.position.y = -0.035;
  scene.add(floor);
  const grid = new THREE.GridHelper(12, 24, 0x516361, 0x34433f);
  grid.position.y = -0.02;
  scene.add(grid);
  const axes = new THREE.AxesHelper(0.6);
  axes.position.set(-2.7, 0, 1.8);
  scene.add(axes);
  const selectionBox = new THREE.BoxHelper(new THREE.Object3D(), 0xdeb471);
  scene.add(selectionBox);
  selectionBox.visible = false;
  const axisLine = new THREE.Line(
    new THREE.BufferGeometry(),
    new THREE.LineBasicMaterial({ color: 0xffffff, depthTest: false }),
  );
  axisLine.visible = false;
  scene.add(axisLine);
  function render() {
    frame = undefined;
    if (!disposed) renderer.render(scene, camera);
  }
  function invalidate() {
    if (!disposed && frame === undefined) frame = requestAnimationFrame(render);
  }
  function setupControls(target) {
    controls?.dispose();
    controls = new OrbitControls(camera, canvas);
    controls.mouseButtons = {
      LEFT: null,
      MIDDLE: THREE.MOUSE.ROTATE,
      RIGHT: THREE.MOUSE.PAN,
    };
    controls.target.copy(target);
    controls.minDistance = 0.3;
    controls.maxDistance = 80;
    controls.addEventListener("change", () => {
      invalidate();
      onCamera?.();
    });
    controls.update();
  }
  perspective.position.set(-4.7, 3.2, 5.8);
  setupControls(new THREE.Vector3(0, 1.45, 0));
  function size() {
    const rect = container.getBoundingClientRect();
    width = Math.max(1, rect.width);
    height = Math.max(1, rect.height);
    renderer.setSize(width, height, false);
    perspective.aspect = width / height;
    perspective.updateProjectionMatrix();
    const vertical = (ortho.top - ortho.bottom) / 2;
    ortho.left = (-vertical * width) / height;
    ortho.right = (vertical * width) / height;
    ortho.updateProjectionMatrix();
    invalidate();
  }
  const observer = new ResizeObserver(size);
  observer.observe(container);
  function setCamera(next) {
    if (next === camera) return;
    const target = controls.target.clone();
    next.position.copy(camera.position);
    next.quaternion.copy(camera.quaternion);
    if (next === ortho) {
      const half =
        camera.position.distanceTo(target) *
        Math.tan(THREE.MathUtils.degToRad(perspective.fov / 2));
      ortho.top = half;
      ortho.bottom = -half;
      ortho.zoom = 1;
    }
    camera = next;
    setupControls(target);
    size();
  }
  function view(name) {
    if (name === "toggle") {
      setCamera(camera === ortho ? perspective : ortho);
      invalidate();
      return;
    }
    const target = new THREE.Vector3(0, 1.5, 0),
      distance = 6.4;
    const direction = {
      front: [0, 0, 1],
      side: [1, 0, 0],
      top: [0, 1, 0.00001],
      back: [0, 0, -1],
      perspective: [-0.72, 0.32, 1],
    }[name] ?? [-0.72, 0.32, 1];
    setCamera(name === "perspective" ? perspective : ortho);
    camera.position
      .copy(target)
      .addScaledVector(new THREE.Vector3(...direction).normalize(), distance);
    controls.target.copy(target);
    controls.update();
    invalidate();
  }
  function clearOverlay() {
    if (overlay) {
      scene.remove(overlay);
      disposeObject(overlay);
      overlay = null;
    }
  }
  function update(snapshot) {
    current = snapshot;
    const ids = new Set(snapshot.document.nodes.map((n) => n.id));
    for (const [id, record] of objects)
      if (!ids.has(id)) {
        root.remove(record.mesh);
        disposeObject(record.mesh);
        objects.delete(id);
      }
    for (const node of snapshot.document.nodes) {
      const signature = JSON.stringify([node.vertices, node.faces]);
      let record = objects.get(node.id);
      if (!record) {
        const mesh = new THREE.Mesh(
          meshGeometry(node),
          new THREE.MeshStandardMaterial({
            color: node.color,
            roughness: 0.83,
            flatShading: true,
            side: THREE.DoubleSide,
          }),
        );
        mesh.name = node.id;
        root.add(mesh);
        record = { mesh, signature };
        objects.set(node.id, record);
      }
      if (record.signature !== signature) {
        record.mesh.geometry.dispose();
        record.mesh.geometry = meshGeometry(node);
        record.signature = signature;
      }
      record.mesh.position.fromArray(node.position);
      record.mesh.material.color.setHex(node.color);
      record.mesh.material.wireframe = wire;
      record.mesh.material.emissive.setHex(
        snapshot.mode === "object" && node.id === snapshot.selected
          ? 0x201306
          : 0x000000,
      );
    }
    clearOverlay();
    const selected = objects.get(snapshot.selected)?.mesh;
    selectionBox.visible = !!selected && snapshot.mode === "object";
    if (selected) selectionBox.setFromObject(selected);
    if (selected && snapshot.mode !== "object") {
      overlay = new THREE.Group();
      overlay.position.copy(selected.position);
      scene.add(overlay);
      const edge = new THREE.LineSegments(
        new THREE.WireframeGeometry(selected.geometry),
        new THREE.LineBasicMaterial({
          color: 0x324747,
          transparent: true,
          opacity: 0.5,
        }),
      );
      overlay.add(edge);
      const node = snapshot.document.nodes.find(
        (n) => n.id === snapshot.selected,
      );
      if (snapshot.mode === "vertex") {
        const geometry = new THREE.BufferGeometry();
        geometry.setAttribute(
          "position",
          new THREE.Float32BufferAttribute(node.vertices.flat(), 3),
        );
        const selectedSet = new Set(snapshot.vertices);
        const colors = node.vertices.flatMap((_, i) =>
          selectedSet.has(i) ? [1, 0.7, 0.25] : [0.6, 0.84, 0.82],
        );
        geometry.setAttribute(
          "color",
          new THREE.Float32BufferAttribute(colors, 3),
        );
        const points = new THREE.Points(
          geometry,
          new THREE.PointsMaterial({
            size: 6,
            sizeAttenuation: false,
            vertexColors: true,
            depthTest: true,
          }),
        );
        overlay.add(points);
      } else if (snapshot.face >= 0) {
        const geometry = meshGeometry({
          ...node,
          faces: [node.faces[snapshot.face]],
        });
        const patch = new THREE.Mesh(
          geometry,
          new THREE.MeshBasicMaterial({
            color: 0xffbc62,
            transparent: true,
            opacity: 0.75,
            side: THREE.DoubleSide,
            polygonOffset: true,
            polygonOffsetFactor: -2,
            polygonOffsetUnits: -2,
          }),
        );
        overlay.add(patch);
      }
    }
    controls.enabled = !snapshot.modal;
    invalidate();
  }
  const raycaster = new THREE.Raycaster();
  function rayAt(x, y) {
    const rect = canvas.getBoundingClientRect();
    raycaster.setFromCamera(
      new THREE.Vector2(
        ((x - rect.left) / width) * 2 - 1,
        (-(y - rect.top) / height) * 2 + 1,
      ),
      camera,
    );
    return raycaster;
  }
  let down;
  const abort = new AbortController(),
    opts = { signal: abort.signal };
  canvas.addEventListener("contextmenu", (e) => e.preventDefault(), opts);
  canvas.addEventListener(
    "pointerdown",
    (e) => {
      canvas.focus();
      if (pointerDown?.(e)) return;
      down = { x: e.clientX, y: e.clientY, button: e.button };
    },
    opts,
  );
  canvas.addEventListener("pointermove", (e) => pointerMove?.(e), opts);
  canvas.addEventListener(
    "pointerup",
    (e) => {
      if (
        !down ||
        down.button !== 0 ||
        current?.modal ||
        Math.hypot(e.clientX - down.x, e.clientY - down.y) > 4
      ) {
        down = null;
        return;
      }
      down = null;
      const ray = rayAt(e.clientX, e.clientY),
        hits = ray.intersectObjects(root.children, false);
      if (current.mode === "object") {
        select(hits[0]?.object.name ?? "");
        return;
      }
      const mesh = objects.get(current.selected)?.mesh;
      if (!mesh) return;
      if (current.mode === "face") {
        const hit = ray.intersectObject(mesh)[0];
        if (hit) face(mesh.geometry.userData.polygons[hit.faceIndex]);
        return;
      }
      const node = current.document.nodes.find(
        (n) => n.id === current.selected,
      );
      const rect = canvas.getBoundingClientRect();
      let best = -1,
        distance = 12;
      for (const [i, v] of node.vertices.entries()) {
        const world = new THREE.Vector3(...v).add(mesh.position),
          p = world.clone().project(camera);
        const d = Math.hypot(
          ((p.x + 1) * width) / 2 + rect.left - e.clientX,
          ((-p.y + 1) * height) / 2 + rect.top - e.clientY,
        );
        if (p.z >= 1 || p.z <= -1 || d >= distance) continue;
        // Vertex must be visible; do not select a hidden rear vertex through the mesh.
        const r = rayAt(
          ((p.x + 1) * width) / 2 + rect.left,
          ((-p.y + 1) * height) / 2 + rect.top,
        );
        const hit = r.intersectObjects(root.children, false)[0];
        if (hit && hit.distance + 0.025 < world.distanceTo(r.ray.origin))
          continue;
        best = i;
        distance = d;
      }
      if (best >= 0) vertex(best, e.shiftKey);
    },
    opts,
  );
  return {
    canvas,
    update,
    view,
    frame(ids) {
      const bounds = new THREE.Box3();
      if (ids) {
        for (const id of ids) {
          const mesh = objects.get(id)?.mesh;
          if (mesh) bounds.expandByObject(mesh);
        }
      } else {
        bounds.setFromObject(objects.get(current?.selected)?.mesh ?? root);
      }
      if (bounds.isEmpty()) return;
      const target = bounds.getCenter(new THREE.Vector3());
      const direction = camera.position
        .clone()
        .sub(controls.target)
        .normalize();
      camera.position
        .copy(target)
        .addScaledVector(
          direction,
          Math.max(bounds.getSize(new THREE.Vector3()).length() * 1.8, 1),
        );
      controls.target.copy(target);
      if (camera === ortho) {
        const half = Math.max(
          bounds.getSize(new THREE.Vector3()).length() * 0.65,
          0.3,
        );
        ortho.top = half;
        ortho.bottom = -half;
        ortho.zoom = 1;
        size();
      }
      controls.update();
      invalidate();
    },
    wire(value) {
      wire = value;
      if (current) update(current);
    },
    axis(axis) {
      axisLine.visible = !!axis;
      if (axis) {
        const origin =
          objects.get(current.selected)?.mesh.position ?? new THREE.Vector3();
        const vector = new THREE.Vector3(
          ...{ x: [1, 0, 0], y: [0, 1, 0], z: [0, 0, 1] }[axis],
        );
        axisLine.geometry.dispose();
        axisLine.geometry = new THREE.BufferGeometry().setFromPoints([
          origin.clone().addScaledVector(vector, -20),
          origin.clone().addScaledVector(vector, 20),
        ]);
        axisLine.material.color.setHex(
          { x: 0xe57878, y: 0x87cfa4, z: 0x83acdf }[axis],
        );
      }
      invalidate();
    },
    delta(dx, dy) {
      const distance = camera.position.distanceTo(controls.target);
      const unit =
        camera === ortho
          ? (ortho.top - ortho.bottom) / ortho.zoom / height
          : (2 *
              distance *
              Math.tan(THREE.MathUtils.degToRad(perspective.fov / 2))) /
            height;
      const right = new THREE.Vector3(1, 0, 0).applyQuaternion(
          camera.quaternion,
        ),
        up = new THREE.Vector3(0, 1, 0).applyQuaternion(camera.quaternion);
      return right
        .multiplyScalar(dx * unit)
        .addScaledVector(up, -dy * unit)
        .toArray();
    },
    stats() {
      return {
        drawCalls: renderer.info.render.calls,
        triangles: renderer.info.render.triangles,
        geometries: renderer.info.memory.geometries,
        camera: camera === ortho ? "orthographic" : "perspective",
      };
    },
    dispose() {
      disposed = true;
      cancelAnimationFrame(frame);
      abort.abort();
      observer.disconnect();
      controls.dispose();
      disposeObject(scene);
      renderer.dispose();
      canvas.remove();
    },
  };
}
