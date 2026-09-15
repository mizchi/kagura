import * as THREE from "three";

/** Preserve polygon identity while triangulating concave authoring faces. */
export function meshGeometry(node) {
  const indices = [],
    polygons = [];
  for (const [faceIndex, face] of node.faces.entries()) {
    const points = face.map((i) => node.vertices[i]);
    const normal = [0, 0, 0];
    for (let i = 0; i < points.length; i++) {
      const a = points[i],
        b = points[(i + 1) % points.length];
      normal[0] += (a[1] - b[1]) * (a[2] + b[2]);
      normal[1] += (a[2] - b[2]) * (a[0] + b[0]);
      normal[2] += (a[0] - b[0]) * (a[1] + b[1]);
    }
    const axis = normal
      .map(Math.abs)
      .indexOf(Math.max(...normal.map(Math.abs)));
    const a = (axis + 1) % 3,
      b = (axis + 2) % 3;
    const contour = points.map((v) => new THREE.Vector2(v[a], v[b]));
    for (const tri of THREE.ShapeUtils.triangulateShape(contour, [])) {
      indices.push(...tri.map((i) => face[i]));
      polygons.push(faceIndex);
    }
  }
  const geometry = new THREE.BufferGeometry();
  geometry.setAttribute(
    "position",
    new THREE.Float32BufferAttribute(node.vertices.flat(), 3),
  );
  geometry.setIndex(indices);
  geometry.computeVertexNormals();
  geometry.userData.polygons = polygons;
  return geometry;
}

export function modelObject(document) {
  const root = new THREE.Group();
  root.name = document.name;
  root.userData = { format: document.format, source: document.source };
  for (const node of document.nodes) {
    // glTF has no flatShading material flag: split corners and bake face normals.
    const indexed = meshGeometry(node),
      geometry = indexed.toNonIndexed();
    indexed.dispose();
    geometry.computeVertexNormals();
    const mesh = new THREE.Mesh(
      geometry,
      new THREE.MeshStandardMaterial({
        color: node.color,
        roughness: 0.83,
        side: THREE.DoubleSide,
      }),
    );
    mesh.name = node.id;
    mesh.userData.label = node.name;
    mesh.position.fromArray(node.position);
    root.add(mesh);
  }
  return root;
}
export function disposeObject(root) {
  root.traverse((object) => {
    object.geometry?.dispose();
    for (const m of [].concat(object.material ?? [])) m.dispose();
  });
}
export async function exportModelGLB(document) {
  const root = modelObject(document);
  try {
    const { GLTFExporter } = await import(
      "three/addons/exporters/GLTFExporter.js"
    );
    return await new GLTFExporter().parseAsync(root, { binary: true });
  } finally {
    disposeObject(root);
  }
}
