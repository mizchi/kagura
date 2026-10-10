// Reading a scene3d snapshot back, deterministic checks, and geometric
// queries. The CLI (`kagura scene3d`) and game tests share these, so what a
// check reports does not depend on who runs it.

///|
/// A snapshot that cannot be read, or a query that cannot be answered. The
/// message names the field or path, without a source location.
pub(all) suberror Scene3DSnapshotError {
  Scene3DSnapshotError(String)
}

///|
pub impl Show for Scene3DSnapshotError with fn output(self, logger) {
  let Scene3DSnapshotError(message) = self
  logger.write_string(message)
}

///|
pub extend Scene3DSnapshotError with Show::{to_string, output}

///|
fn json_number(j : Json, what : String) -> Double raise {
  match j {
    Number(x, ..) => x
    _ => raise Scene3DSnapshotError("\{what}: expected a number")
  }
}

///|
fn json_vec(j : Json?, what : String) -> @math3d.Vec3 raise {
  guard j is Some(Array(xs)) && xs.length() == 3 else {
    raise Scene3DSnapshotError("\{what}: expected [x, y, z]")
  }
  @math3d.Vec3::new(
    json_number(xs[0], what),
    json_number(xs[1], what),
    json_number(xs[2], what),
  )
}

///|
fn json_quat(j : Json?, what : String) -> @math3d.Quaternion raise {
  guard j is Some(Array(xs)) && xs.length() == 4 else {
    raise Scene3DSnapshotError("\{what}: expected [x, y, z, w]")
  }
  @math3d.Quaternion::new(
    json_number(xs[0], what),
    json_number(xs[1], what),
    json_number(xs[2], what),
    json_number(xs[3], what),
  )
}

///|
fn json_field(
  o : Map[String, Json],
  key : String,
  what : String,
) -> Double raise {
  match o.get(key) {
    Some(j) => json_number(j, "\{what}.\{key}")
    None => raise Scene3DSnapshotError("\{what}: missing \{key}")
  }
}

///|
fn camera_from_json(o : Map[String, Json]) -> @camera3d.Camera3D raise {
  let position = json_vec(o.get("position"), "camera.position")
  let target = json_vec(o.get("target"), "camera.target")
  let up = json_vec(o.get("up"), "camera.up")
  let near = json_field(o, "near", "camera")
  let far = json_field(o, "far", "camera")
  guard o.get("projection") is Some(Object(p)) else {
    raise Scene3DSnapshotError("camera: missing projection")
  }
  match p.get("kind") {
    Some(String("perspective")) =>
      @camera3d.Camera3D::new_perspective(
        position,
        target,
        up,
        json_field(p, "fov_y_rad", "camera.projection"),
        json_field(p, "aspect", "camera.projection"),
        near,
        far,
      )
    Some(String("orthographic")) =>
      @camera3d.Camera3D::new_orthographic(
        position,
        target,
        up,
        json_field(p, "left", "camera.projection"),
        json_field(p, "right", "camera.projection"),
        json_field(p, "bottom", "camera.projection"),
        json_field(p, "top", "camera.projection"),
        near,
        far,
      )
    _ =>
      raise Scene3DSnapshotError(
        "camera.projection.kind: expected perspective or orthographic",
      )
  }
}

///|
/// Parses the document `Scene3DSnapshot::to_json` writes. Raises with the
/// offending field on anything else, so a broken capture is reported as
/// such rather than as an empty scene.
pub fn Scene3DSnapshot::from_json(json : Json) -> Scene3DSnapshot raise {
  guard json is Object(root) else {
    raise Scene3DSnapshotError("snapshot: expected an object")
  }
  guard root.get("schema") is Some(String(schema)) &&
    schema == scene3d_snapshot_schema else {
    raise Scene3DSnapshotError(
      "snapshot: schema is not \{scene3d_snapshot_schema}",
    )
  }
  guard root.get("version") is Some(Number(1.0, ..)) else {
    raise Scene3DSnapshotError("snapshot: unsupported version")
  }
  let camera = match root.get("camera") {
    Some(Object(c)) => Some(camera_from_json(c))
    Some(Null) | None => None
    _ =>
      raise Scene3DSnapshotError("snapshot.camera: expected an object or null")
  }
  guard root.get("nodes") is Some(Array(items)) else {
    raise Scene3DSnapshotError("snapshot.nodes: expected an array")
  }
  let nodes = []
  for i, item in items {
    guard item is Object(o) else {
      raise Scene3DSnapshotError("nodes[\{i}]: expected an object")
    }
    guard o.get("path") is Some(String(path)) else {
      raise Scene3DSnapshotError("nodes[\{i}].path: expected a string")
    }
    let what = "node \{path}"
    let box = match o.get("box") {
      Some(Object(b)) =>
        Some({
          center: json_vec(b.get("center"), "\{what}.box.center"),
          half_extents: json_vec(
            b.get("half_extents"),
            "\{what}.box.half_extents",
          ),
          rotation: json_quat(b.get("rotation"), "\{what}.box.rotation"),
        })
      Some(Null) | None => None
      _ => raise Scene3DSnapshotError("\{what}.box: expected an object or null")
    }
    nodes.push({
      path,
      name: match o.get("name") {
        Some(String(s)) => s
        _ => path
      },
      kind: match o.get("kind") {
        Some(String(s)) => s
        _ => if box is Some(_) { "mesh" } else { "group" }
      },
      subject: match o.get("subject") {
        Some(String(s)) => Some(s)
        _ => None
      },
      position: json_vec(o.get("position"), "\{what}.position"),
      rotation: json_quat(o.get("rotation"), "\{what}.rotation"),
      scale: json_vec(o.get("scale"), "\{what}.scale"),
      box,
    })
  }
  { camera, nodes, }
}

///|
/// One problem `Scene3DSnapshot::check` found.
pub(all) struct Scene3DFinding {
  /// `non_finite`, `unnormalized_rotation`, `zero_scale`, `outside_view` or
  /// `overlap`.
  kind : String
  /// The node, or both nodes of an overlap.
  paths : Array[String]
  message : String
} derive(Debug)

///|
pub extend Scene3DFinding with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub let scene3d_finding_kinds : Array[String] = [
  "non_finite", "unnormalized_rotation", "zero_scale", "outside_view", "overlap",
]

///|
fn finite(v : @math3d.Vec3) -> Bool {
  !(v.x.is_nan() ||
  v.x.is_inf() ||
  v.y.is_nan() ||
  v.y.is_inf() ||
  v.z.is_nan() ||
  v.z.is_inf())
}

///|
fn box_shape(b : Scene3DSnapshotBox) -> @convex.Shape {
  @convex.Shape::Box(
    center=b.center,
    half_extents=b.half_extents,
    rotation=b.rotation.normalize(),
  )
}

///|
fn box_corners(b : Scene3DSnapshotBox) -> Array[@math3d.Vec3] {
  let r = b.rotation.normalize()
  let h = b.half_extents
  let corners = []
  for sx in [-1.0, 1.0] {
    for sy in [-1.0, 1.0] {
      for sz in [-1.0, 1.0] {
        corners.push(
          b.center.add(
            r.rotate_vec3(@math3d.Vec3::new(sx * h.x, sy * h.y, sz * h.z)),
          ),
        )
      }
    }
  }
  corners
}

///|
/// True when the whole box is outside one plane of the view volume (clip
/// space, WebGPU depth [0, 1]). Conservative: a box that straddles two planes
/// near a frustum corner can be reported as visible.
fn outside_view(camera : @camera3d.Camera3D, b : Scene3DSnapshotBox) -> Bool {
  let vp = camera.view_projection_matrix()
  let clip = box_corners(b).map(p => {
    vp.mul_vec4(@math3d.Vec4::new(p.x, p.y, p.z, 1.0))
  })
  let planes : Array[(@math3d.Vec4) -> Bool] = [
    c => c.x < -c.w,
    c => c.x > c.w,
    c => c.y < -c.w,
    c => c.y > c.w,
    c => c.z < 0.0,
    c => c.z > c.w,
  ]
  planes.iter().any(outside => clip.iter().all(outside))
}

///|
/// `a` is `b` or one of its ancestors (or the other way round).
fn related(a : String, b : String) -> Bool {
  a == b || b.has_prefix(a + "/") || a.has_prefix(b + "/")
}

///|
/// Deterministic problems in the snapshot:
/// - `non_finite`: NaN or infinity in a transform or box
/// - `unnormalized_rotation`: a rotation whose length is off by more than 1e-3
/// - `zero_scale`: a scale component within 1e-6 of zero
/// - `outside_view`: a mesh entirely outside the camera's view volume
/// - `overlap`: two meshes bound to different subjects whose boxes intersect
///   (subjects are game objects; scenery overlapping itself is not reported)
pub fn Scene3DSnapshot::check(self : Scene3DSnapshot) -> Array[Scene3DFinding] {
  let findings = []
  for n in self.nodes {
    let box_ok = match n.box {
      Some(b) => finite(b.center) && finite(b.half_extents)
      None => true
    }
    let q = n.rotation
    if !finite(n.position) ||
      !finite(n.scale) ||
      !finite(@math3d.Vec3::new(q.x, q.y, q.z)) ||
      q.w.is_nan() ||
      q.w.is_inf() ||
      !box_ok {
      findings.push({
        kind: "non_finite",
        paths: [n.path],
        message: "\{n.path}: transform or box has NaN or infinity",
      })
      continue
    }
    let length = q.length()
    if (length - 1.0).abs() > 1.0e-3 {
      findings.push({
        kind: "unnormalized_rotation",
        paths: [n.path],
        message: "\{n.path}: rotation length is \{length}, not 1",
      })
    }
    if n.scale.x.abs() < 1.0e-6 ||
      n.scale.y.abs() < 1.0e-6 ||
      n.scale.z.abs() < 1.0e-6 {
      findings.push({
        kind: "zero_scale",
        paths: [n.path],
        message: "\{n.path}: scale \{n.scale.x}, \{n.scale.y}, \{n.scale.z} has a zero component",
      })
    }
    if self.camera is Some(camera) &&
      n.box is Some(b) &&
      outside_view(camera, b) {
      findings.push({
        kind: "outside_view",
        paths: [n.path],
        message: "\{n.path}: mesh is entirely outside the camera's view",
      })
    }
  }
  let bodies = self.nodes.filter(n => {
    n.subject is Some(_) &&
    n.box is Some(_) &&
    !findings.iter().any(f => f.kind == "non_finite" && f.paths[0] == n.path)
  })
  for i in 0..<bodies.length() {
    for j in (i + 1)..<bodies.length() {
      let a = bodies[i]
      let b = bodies[j]
      if a.subject == b.subject || related(a.path, b.path) {
        continue
      }
      let d = @convex.distance(
        box_shape(a.box.unwrap()),
        box_shape(b.box.unwrap()),
      )
      if d.intersecting {
        findings.push({
          kind: "overlap",
          paths: [a.path, b.path],
          message: "\{a.path} (\{a.subject.unwrap()}) overlaps \{b.path} (\{b.subject.unwrap()})",
        })
      }
    }
  }
  findings
}

///|
/// Boxes of the node at `path` and of every mesh below it.
pub fn Scene3DSnapshot::shapes_under(
  self : Scene3DSnapshot,
  path : String,
) -> Array[@convex.Shape] {
  self.nodes
  .filter(n => n.path == path || n.path.has_prefix(path + "/"))
  .filter_map(n => n.box.map(box_shape))
}

///|
/// Minimum distance between two nodes, each taken with every mesh below it,
/// so a group (a character, a building) counts as the union of its parts.
pub fn Scene3DSnapshot::distance(
  self : Scene3DSnapshot,
  a : String,
  b : String,
) -> @convex.Distance raise {
  let pieces_a = self.shapes_under(a)
  let pieces_b = self.shapes_under(b)
  guard !pieces_a.is_empty() else {
    raise Scene3DSnapshotError("\{a}: no mesh at or below this path")
  }
  guard !pieces_b.is_empty() else {
    raise Scene3DSnapshotError("\{b}: no mesh at or below this path")
  }
  @convex.distance_between_unions(pieces_a, pieces_b)
}

///|
/// Every pair of meshes whose boxes intersect, leaving out a node and its
/// own descendants.
pub fn Scene3DSnapshot::overlaps(
  self : Scene3DSnapshot,
) -> Array[(String, String)] {
  let meshes = self.nodes.filter(n => n.box is Some(_))
  let pairs = []
  for i in 0..<meshes.length() {
    for j in (i + 1)..<meshes.length() {
      let a = meshes[i]
      let b = meshes[j]
      if related(a.path, b.path) {
        continue
      }
      let d = @convex.distance(
        box_shape(a.box.unwrap()),
        box_shape(b.box.unwrap()),
      )
      if d.intersecting {
        pairs.push((a.path, b.path))
      }
    }
  }
  pairs
}

///|
/// Meshes hit by the ray from `origin` along `direction`, nearest first, with
/// the distance along the (normalised) direction to where it enters the box.
/// A ray starting inside a box hits it at 0.
pub fn Scene3DSnapshot::raycast(
  self : Scene3DSnapshot,
  origin : @math3d.Vec3,
  direction : @math3d.Vec3,
) -> Array[(String, Double)] raise {
  let dir = direction.normalize()
  guard dir.length() > 0.0 else {
    raise Scene3DSnapshotError("raycast: direction is zero")
  }
  let hits = []
  for n in self.nodes {
    guard n.box is Some(b) else { continue }
    let inverse = b.rotation.normalize().conjugate()
    let o = inverse.rotate_vec3(origin.sub(b.center))
    let d = inverse.rotate_vec3(dir)
    let h = b.half_extents
    let mut enter = 0.0
    let mut leave = @double.infinity
    let mut missed = false
    for axis in [(o.x, d.x, h.x), (o.y, d.y, h.y), (o.z, d.z, h.z)] {
      let (oc, dc, hc) = axis
      if dc.abs() < 1.0e-12 {
        if oc < -hc || oc > hc {
          missed = true
        }
      } else {
        let t1 = (-hc - oc) / dc
        let t2 = (hc - oc) / dc
        enter = @cmp.maximum(enter, @cmp.minimum(t1, t2))
        leave = @cmp.minimum(leave, @cmp.maximum(t1, t2))
      }
    }
    if !missed && enter <= leave {
      hits.push((n.path, enter))
    }
  }
  hits.sort_by((x, y) => x.1.compare(y.1))
  hits
}
