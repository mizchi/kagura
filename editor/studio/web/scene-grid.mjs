import * as THREE from 'three';

/**
 * Ground-plane guide covering authored world bounds. Tile lines stay on world
 * integers even when a scene is translated or has a fractional center.
 * @param {THREE.Box3} bounds World-space scene bounds (not modified).
 * @returns {THREE.LineSegments} Caller owns the geometry and material.
 */
export function createSceneGrid(bounds) {
  const footprint = bounds.isEmpty()
    ? new THREE.Box3(new THREE.Vector3(-20, 0, -20), new THREE.Vector3(20, 0, 20))
    : bounds.clone().expandByVector(new THREE.Vector3(2, 0, 2));
  const span = Math.max(footprint.max.x - footprint.min.x, footprint.max.z - footprint.min.z);
  // Keep one-meter tiles for normal levels; cap line count for large worlds.
  const step = Math.max(1, 10 ** Math.ceil(Math.log10(span / 200)));
  const minX = Math.floor(footprint.min.x / step);
  const maxX = Math.ceil(footprint.max.x / step);
  const minZ = Math.floor(footprint.min.z / step);
  const maxZ = Math.ceil(footprint.max.z / step);
  const positions = [], colors = [];
  const axis = new THREE.Color(0x697784).toArray();
  const line = new THREE.Color(0x384450).toArray();
  function add(x1, z1, x2, z2, isAxis) {
    positions.push(x1, 0, z1, x2, 0, z2);
    const color = isAxis ? axis : line;
    colors.push(...color, ...color);
  }
  for (let x = minX; x <= maxX; x++) add(x * step, minZ * step, x * step, maxZ * step, x === 0);
  for (let z = minZ; z <= maxZ; z++) add(minX * step, z * step, maxX * step, z * step, z === 0);
  const geometry = new THREE.BufferGeometry();
  geometry.setAttribute('position', new THREE.Float32BufferAttribute(positions, 3));
  geometry.setAttribute('color', new THREE.Float32BufferAttribute(colors, 3));
  const grid = new THREE.LineSegments(geometry, new THREE.LineBasicMaterial({ vertexColors: true, toneMapped: false }));
  // Authoring uses Y=0 ground; the small lift prevents z-fighting with floors.
  grid.position.y = 0.01;
  return grid;
}
