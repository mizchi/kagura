///|
/// Metres, Y up, +Z forward. Head dimensions are radii except head_height.
pub(all) struct BipedProportions {
  hip_height : Double
  knee_height : Double
  shoulder_height : Double
  shoulder_width : Double
  head_height : Double
  head_width : Double
  head_depth : Double
  torso_width : Double
  limb_radius : Double
}

///|
pub fn default_biped_proportions() -> BipedProportions {
  {
    hip_height: 0.42,
    knee_height: 0.22,
    shoulder_height: 0.68,
    shoulder_width: 0.23,
    head_height: 0.46,
    head_width: 0.23,
    head_depth: 0.20,
    torso_width: 0.18,
    limb_radius: 0.065,
  }
}

///|
/// Colorless mannequin parts can be replaced or decorated independently.
pub struct BipedBase {
  skeleton : @skeleton3d.Skeleton
  head : RigidGeometry
  torso : RigidGeometry
  arms : RigidGeometry
  legs : RigidGeometry
}

///|
/// Stable joints: root, torso, head, left upper arm/forearm, right upper arm/forearm,
/// left thigh/shin, right thigh/shin, tail. Anchors are in the mesh's bind space.
pub fn build_biped_skeleton(p : BipedProportions) -> @skeleton3d.Skeleton {
  let elbow = (p.shoulder_height + p.hip_height) / 2.0 - 0.04
  let anchors = [
    ("root", -1, 0.0, 0.0, 0.0),
    ("torso", 0, 0.0, p.hip_height + 0.12, 0.0),
    ("head", 1, 0.0, p.shoulder_height + 0.04, 0.0),
    ("left_upper_arm", 1, -p.shoulder_width, p.shoulder_height, 0.0),
    ("left_forearm", 3, -p.shoulder_width - 0.025, elbow, 0.025),
    ("right_upper_arm", 1, p.shoulder_width, p.shoulder_height, 0.0),
    ("right_forearm", 5, p.shoulder_width + 0.025, elbow, 0.025),
    ("left_thigh", 0, -0.105, p.hip_height, 0.0),
    ("left_shin", 7, -0.105, p.knee_height, 0.0),
    ("right_thigh", 0, 0.105, p.hip_height, 0.0),
    ("right_shin", 9, 0.105, p.knee_height, 0.0),
    ("tail", 0, 0.0, p.hip_height, -0.10),
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

///|
pub fn build_biped_base(p : BipedProportions) -> BipedBase {
  let head = RigidGeometry::new()
  let torso = RigidGeometry::new()
  let arms = RigidGeometry::new()
  let legs = RigidGeometry::new()
  let head_y = p.shoulder_height + 0.04
  head.loft(
    0.0,
    0.0,
    [
      (head_y, p.head_width * 0.65, p.head_depth * 0.68),
      (head_y + p.head_height * 0.22, p.head_width, p.head_depth),
      (head_y + p.head_height * 0.78, p.head_width * 0.96, p.head_depth * 0.96),
      (head_y + p.head_height, p.head_width * 0.58, p.head_depth * 0.60),
    ],
    8,
    2,
  )
  torso.loft(
    0.0,
    0.0,
    [
      (p.hip_height - 0.06, p.torso_width * 0.70, 0.11),
      (p.hip_height + 0.08, p.torso_width, 0.14),
      (p.shoulder_height - 0.04, p.torso_width * 1.04, 0.12),
      (head_y, p.torso_width * 0.55, 0.09),
    ],
    6,
    1,
  )
  let elbow = (p.shoulder_height + p.hip_height) / 2.0 - 0.04
  for side in [-1.0, 1.0] {
    let upper = if side < 0.0 { 3 } else { 5 }
    let forearm = upper + 1
    let thigh = if side < 0.0 { 7 } else { 9 }
    let shin = thigh + 1
    arms.segment(
      @math3d.Vec3::new(side * p.shoulder_width, p.shoulder_height, 0.0),
      @math3d.Vec3::new(side * (p.shoulder_width + 0.025), elbow, 0.025),
      p.limb_radius * 1.10,
      p.limb_radius * 0.85,
      6,
      upper,
    )
    arms.segment(
      @math3d.Vec3::new(side * (p.shoulder_width + 0.025), elbow, 0.025),
      @math3d.Vec3::new(
        side * (p.shoulder_width + 0.045),
        p.hip_height - 0.07,
        0.06,
      ),
      p.limb_radius,
      p.limb_radius * 0.80,
      6,
      forearm,
    )
    arms.box(
      side * (p.shoulder_width + 0.045),
      p.hip_height - 0.08,
      0.075,
      p.limb_radius * 1.9,
      p.limb_radius * 1.7,
      p.limb_radius * 2.1,
      forearm,
    )
    legs.segment(
      @math3d.Vec3::new(side * 0.105, p.hip_height, 0.0),
      @math3d.Vec3::new(side * 0.105, p.knee_height, 0.0),
      p.limb_radius * 1.2,
      p.limb_radius,
      6,
      thigh,
    )
    legs.segment(
      @math3d.Vec3::new(side * 0.105, p.knee_height, 0.0),
      @math3d.Vec3::new(side * 0.105, 0.055, 0.0),
      p.limb_radius,
      p.limb_radius * 0.75,
      6,
      shin,
    )
    legs.box(side * 0.105, 0.045, 0.04, p.limb_radius * 2.3, 0.09, 0.22, shin)
  }
  { skeleton: build_biped_skeleton(p), head, torso, arms, legs, }
}
