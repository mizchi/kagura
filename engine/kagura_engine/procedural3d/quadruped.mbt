///|
/// Metres, Y up, +Z forward. A colorless rig for wolves, hounds and other four-legged actors.
pub(all) struct QuadrupedProportions {
  shoulder_height : Double
  hip_height : Double
  half_width : Double
  front_z : Double
  rear_z : Double
  head_height : Double
  head_z : Double
}

///|
pub fn default_quadruped_proportions() -> QuadrupedProportions {
  {
    shoulder_height: 0.68,
    hip_height: 0.60,
    half_width: 0.21,
    front_z: 0.36,
    rear_z: -0.42,
    head_height: 0.79,
    head_z: 0.64,
  }
}

///|
/// Stable joints: root, body, neck, head, jaw, tail, tail tip,
/// left/right front upper/lower legs, left/right rear upper/lower legs.
pub fn build_quadruped_skeleton(
  p : QuadrupedProportions,
) -> @skeleton3d.Skeleton {
  let anchors = [
    ("root", -1, 0.0, 0.0, 0.0),
    ("body", 0, 0.0, p.hip_height, 0.0),
    ("neck", 1, 0.0, p.shoulder_height, p.front_z),
    ("head", 2, 0.0, p.head_height, p.head_z),
    ("jaw", 3, 0.0, p.head_height - 0.08, p.head_z + 0.14),
    ("tail", 1, 0.0, p.hip_height + 0.02, p.rear_z - 0.10),
    ("tail_tip", 5, 0.0, p.hip_height - 0.22, p.rear_z - 0.50),
    ("front_left_upper", 1, -p.half_width, p.shoulder_height, p.front_z),
    (
      "front_left_lower",
      7,
      -p.half_width,
      p.shoulder_height * 0.46,
      p.front_z + 0.02,
    ),
    ("front_right_upper", 1, p.half_width, p.shoulder_height, p.front_z),
    (
      "front_right_lower",
      9,
      p.half_width,
      p.shoulder_height * 0.46,
      p.front_z + 0.02,
    ),
    ("rear_left_upper", 1, -p.half_width, p.hip_height, p.rear_z),
    ("rear_left_lower", 11, -p.half_width, p.hip_height * 0.40, p.rear_z - 0.17),
    ("rear_right_upper", 1, p.half_width, p.hip_height, p.rear_z),
    ("rear_right_lower", 13, p.half_width, p.hip_height * 0.40, p.rear_z - 0.17),
  ]
  let bones : Array[@skeleton3d.Bone] = []
  let inverse_bind : Array[@math3d.Mat4] = []
  for (name, parent, x, y, z) in anchors {
    let position = @math3d.Vec3::new(x, y, z)
    let parent_position = if parent < 0 {
      @math3d.Vec3::zero()
    } else {
      let (_, _, px, py, pz) = anchors[parent]
      @math3d.Vec3::new(px, py, pz)
    }
    bones.push({
      name,
      parent,
      local_transform: @transform3d.Transform3D::from_position(
        position.sub(parent_position),
      ),
    })
    inverse_bind.push(@math3d.Mat4::translation(-x, -y, -z))
  }
  @skeleton3d.Skeleton::new(bones, inverse_bind)
}
