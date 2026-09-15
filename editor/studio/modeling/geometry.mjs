import * as THREE from "three";
import { evaluateModel } from "./model.mjs";

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
  const expressions = document.expressions ?? [];
  const poses = expressions.map(
    (expression) => evaluateModel(document, { [expression.id]: 1 }).nodes,
  );
  for (const [nodeIndex, node] of document.nodes.entries()) {
    // glTF has no flatShading material flag: split corners and bake face normals.
    const indexed = meshGeometry(node),
      geometry = indexed.toNonIndexed();
    const corners = Array.from(indexed.index.array);
    indexed.dispose();
    geometry.computeVertexNormals();
    if (
      expressions.some((expression) =>
        expression.targets.some((target) => target.node === node.id),
      )
    ) {
      geometry.morphTargetsRelative = true;
      geometry.morphAttributes.position = [];
      geometry.morphAttributes.normal = [];
      for (const [i, expression] of expressions.entries()) {
        const target = poses[i][nodeIndex];
        // Object translations become vertex deltas so all facial controls export as morphs.
        const targetPositions = corners.flatMap((index) =>
          target.vertices[index].map(
            (v, k) => v + target.position[k] - node.position[k],
          ),
        );
        const posed = new THREE.BufferGeometry();
        posed.setAttribute(
          "position",
          new THREE.Float32BufferAttribute(targetPositions, 3),
        );
        posed.computeVertexNormals();
        for (const kind of ["position", "normal"]) {
          const delta = posed.getAttribute(kind).clone();
          const base = geometry.getAttribute(kind);
          for (let j = 0; j < delta.array.length; j++)
            delta.array[j] -= base.array[j];
          delta.name = expression.id;
          geometry.morphAttributes[kind].push(delta);
        }
        posed.dispose();
      }
    }
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
