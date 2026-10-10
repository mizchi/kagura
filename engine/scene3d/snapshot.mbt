///|
/// World-space record of a `SceneRoot`, for reading and checking a 3D scene
/// as data instead of as pixels: `scene3d-check` and the `kagura scene3d`
/// queries work on this. Conventions follow
/// `docs/architecture/coordinates.md`; quaternions are `(x, y, z, w)`.
pub(all) struct Scene3DSnapshot {
  camera : @camera3d.Camera3D?
  /// Every element of the scene, parents before children.
  nodes : Array[Scene3DSnapshotNode]
}

///|
pub(all) struct Scene3DSnapshotNode {
  /// Hierarchy path, `parent/child` keys.
  path : String
  name : String
  /// `"mesh"` or `"group"`.
  kind : String
  /// Logical state id from `subject()`, when inspection is enabled.
  subject : String?
  /// World transform, decomposed. With non-uniform scale under a rotated
  /// parent the world matrix has shear, and these are the closest fit.
  position : @math3d.Vec3
  rotation : @math3d.Quaternion
  scale : @math3d.Vec3
  /// The mesh's local bounds carried into world space as an oriented box.
  /// None for groups. Skinned meshes use their bind-pose bounds.
  box : Scene3DSnapshotBox?
  /// A ball around the box centre holding every vertex. Like the box it never
  /// cuts into the mesh; the two together fit round and boxy meshes tighter
  /// than either alone. None for groups, and in snapshots written before it.
  sphere : Scene3DSnapshotSphere?
}

///|
pub(all) struct Scene3DSnapshotSphere {
  center : @math3d.Vec3
  radius : Double
}

///|
pub(all) struct Scene3DSnapshotBox {
  center : @math3d.Vec3
  half_extents : @math3d.Vec3
  rotation : @math3d.Quaternion
}

///|
fn column(m : @math3d.Mat4, index : Int) -> @math3d.Vec3 {
  let e = m.elements
  @math3d.Vec3::new(e[index * 4], e[index * 4 + 1], e[index * 4 + 2])
}

///|
fn transform_point(m : @math3d.Mat4, p : @math3d.Vec3) -> @math3d.Vec3 {
  column(m, 0)
  .scale(p.x)
  .add(column(m, 1).scale(p.y))
  .add(column(m, 2).scale(p.z))
  .add(column(m, 3))
}

///|
fn world_box(world : @math3d.Mat4, mesh : @mesh3d.Mesh3D) -> Scene3DSnapshotBox {
  let b = mesh.bounds
  let center = @math3d.Vec3::new(
    (b.min_x + b.max_x) * 0.5,
    (b.min_y + b.max_y) * 0.5,
    (b.min_z + b.max_z) * 0.5,
  )
  let half = @math3d.Vec3::new(
    (b.max_x - b.min_x) * 0.5,
    (b.max_y - b.min_y) * 0.5,
    (b.max_z - b.min_z) * 0.5,
  )
  {
    center: transform_point(world, center),
    half_extents: @math3d.Vec3::new(
      column(world, 0).length() * half.x,
      column(world, 1).length() * half.y,
      column(world, 2).length() * half.z,
    ),
    rotation: @transform3d.Transform3D::from_mat4(world).rotation.normalize(),
  }
}

///|
/// Bounding ball around the centre of the mesh's local bounds, carried into
/// world space. The radius grows by the largest axis scale, so it stays a
/// bound under non-uniform scale.
fn world_sphere(
  world : @math3d.Mat4,
  mesh : @mesh3d.Mesh3D,
) -> Scene3DSnapshotSphere {
  let b = mesh.bounds
  let cx = (b.min_x + b.max_x) * 0.5
  let cy = (b.min_y + b.max_y) * 0.5
  let cz = (b.min_z + b.max_z) * 0.5
  let data = mesh.vertex_data
  let stride = @mesh3d.vertex3d_stride
  let mut r2 = 0.0
  for i in 0..<mesh.vertex_count() {
    let dx = data[i * stride] - cx
    let dy = data[i * stride + 1] - cy
    let dz = data[i * stride + 2] - cz
    r2 = @cmp.maximum(r2, dx * dx + dy * dy + dz * dz)
  }
  let grow = @cmp.maximum(
    column(world, 0).length(),
    @cmp.maximum(column(world, 1).length(), column(world, 2).length()),
  )
  {
    center: transform_point(world, @math3d.Vec3::new(cx, cy, cz)),
    radius: r2.sqrt() * grow,
  }
}

///|
/// Snapshot of the scene this root last rendered. Pass the camera the frame
/// is drawn with so `scene3d-check` can tell what is in view.
pub fn SceneRoot::snapshot(
  self : SceneRoot,
  camera? : @camera3d.Camera3D,
) -> Scene3DSnapshot {
  let paths : Map[Int, String] = Map([])
  for path, id in self.ids {
    paths[id] = path
  }
  let labels : Map[String, (String, String?)] = Map([])
  fn collect(nodes : Array[@hierarchy.Node]) -> Unit {
    for n in nodes {
      labels[n.id] = (n.name, n.subject)
      collect(n.children)
    }
  }
  collect(self.outline)
  let graph = self.current
  let nodes = []
  fn visit(id : Int, parent : @math3d.Mat4) -> Unit {
    guard graph.nodes.get(id) is Some(node) else { return }
    let world = parent.multiply(node.transform.to_mat4())
    let path = paths.get(id).unwrap_or("#\{id}")
    let key = match path.rev_find("/") {
      Some(i) => path.unsafe_substring(start=i + 1, end=path.length())
      None => path
    }
    let (name, subject) = labels.get(path).unwrap_or((key, None))
    let t = @transform3d.Transform3D::from_mat4(world)
    nodes.push({
      path,
      name,
      kind: if node.mesh is Some(_) {
        "mesh"
      } else {
        "group"
      },
      subject,
      position: t.position,
      rotation: t.rotation.normalize(),
      scale: t.scale,
      box: node.mesh.map(m => world_box(world, m)),
      sphere: node.mesh.map(m => world_sphere(world, m)),
    })
    for child in node.children {
      visit(child, world)
    }
  }
  for root in graph.roots {
    visit(root, @math3d.Mat4::identity())
  }
  { camera, nodes, }
}

///|
/// Rounds for reading. Five decimals keeps a rotation's length check
/// meaningful while a node still fits on a line.
fn rounded(x : Double) -> Json {
  if x.is_nan() || x.is_inf() {
    Json::null()
  } else {
    ((x * 100000.0).round() / 100000.0 + 0.0).to_json()
  }
}

///|
fn vec_json(v : @math3d.Vec3) -> Json {
  [rounded(v.x), rounded(v.y), rounded(v.z)]
}

///|
fn quat_json(q : @math3d.Quaternion) -> Json {
  [rounded(q.x), rounded(q.y), rounded(q.z), rounded(q.w)]
}

///|
fn camera_json(c : @camera3d.Camera3D) -> Json {
  let projection : Json = match c.projection_mode {
    Perspective =>
      {
        "kind": "perspective",
        "fov_y_rad": rounded(c.fov_y_rad),
        "aspect": rounded(c.aspect),
      }
    Orthographic(left, right, bottom, top) =>
      {
        "kind": "orthographic",
        "left": rounded(left),
        "right": rounded(right),
        "bottom": rounded(bottom),
        "top": rounded(top),
      }
  }
  {
    "position": vec_json(c.position),
    "target": vec_json(c.target),
    "up": vec_json(c.up),
    "near": rounded(c.near),
    "far": rounded(c.far),
    "projection": projection,
  }
}

///|
pub let scene3d_snapshot_schema : String = "kagura.scene3d-snapshot"

///|
pub fn Scene3DSnapshot::to_json(self : Scene3DSnapshot) -> Json {
  let nodes = self.nodes.map(n => {
    let node : Map[String, Json] = {
      "path": n.path.to_json(),
      "name": n.name.to_json(),
      "kind": n.kind.to_json(),
      "subject": match n.subject {
        Some(s) => s.to_json()
        None => Json::null()
      },
      "position": vec_json(n.position),
      "rotation": quat_json(n.rotation),
      "scale": vec_json(n.scale),
      "sphere": match n.sphere {
        Some(b) => { "center": vec_json(b.center), "radius": rounded(b.radius) }
        None => Json::null()
      },
      "box": match n.box {
        Some(b) =>
          {
            "center": vec_json(b.center),
            "half_extents": vec_json(b.half_extents),
            "rotation": quat_json(b.rotation),
          }
        None => Json::null()
      },
    }
    Json::object(node)
  })
  {
    "schema": scene3d_snapshot_schema.to_json(),
    "version": 1,
    "conventions": {
      "handedness": "right",
      "up": "+y",
      "camera_forward": "-z",
      "quaternion": "xyzw",
    },
    "camera": match self.camera {
      Some(c) => camera_json(c)
      None => Json::null()
    },
    "nodes": Json::array(nodes),
  }
}
