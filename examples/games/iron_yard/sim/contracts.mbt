///|
pub(all) struct Input {
  forward : Double
  strafe : Double
  boost : Bool
  jump : Bool
  fire : Bool
  lock : Bool
  yaw : Double
  pitch : Double
}

///|
pub fn input(
  forward? : Double = 0.0,
  strafe? : Double = 0.0,
  boost? : Bool = false,
  jump? : Bool = false,
  fire? : Bool = false,
  lock? : Bool = false,
  yaw? : Double = 0.0,
  pitch? : Double = 0.25,
) -> Input {
  { forward, strafe, boost, jump, fire, lock, yaw, pitch, }
}

///|
pub(all) struct Pilot {
  mut position : @math3d.Vec3
  mut velocity : @math3d.Vec3
  yaw : Double
  pitch : Double
  mut gait : Double
  mut boost : Double
  mut grounded : Bool
  mut jump_held : Double
  mut jump_down : Bool
}

///|
pub(all) struct Solid {
  id : String
  kind : String
  center : @math3d.Vec3
  size : @math3d.Vec3
  color : Int
}

///|
pub(all) struct Stage {
  min_x : Double
  max_x : Double
  min_z : Double
  max_z : Double
  spawn : @math3d.Vec3
  solids : Array[Solid]
}

///|
pub fn vec(x : Double, y : Double, z : Double) -> @math3d.Vec3 {
  @math3d.Vec3::new(x, y, z)
}

///|
pub fn solid(
  id : String,
  center : @math3d.Vec3,
  size : @math3d.Vec3,
  color : Int,
  kind? : String = "",
) -> Solid {
  { id, kind, center, size, color, }
}

///|
pub fn clamp(v : Double, a : Double, b : Double) -> Double {
  if v < a {
    a
  } else if v > b {
    b
  } else {
    v
  }
}

///|
pub fn min(a : Double, b : Double) -> Double {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn max(a : Double, b : Double) -> Double {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn distance(a : @math3d.Vec3, b : @math3d.Vec3) -> Double {
  let d = a.sub(b)
  (d.x * d.x + d.z * d.z).sqrt()
}

///|
pub fn default_stage() -> Stage {
  {
    min_x: -48.0,
    max_x: 48.0,
    min_z: -60.0,
    max_z: 54.0,
    spawn: vec(0.0, 0.0, -36.0),
    solids: [
      solid("hangar-a", vec(-28.0, 7.0, -15.0), vec(22.0, 14.0, 30.0), 0x656f74),
      solid("hangar-b", vec(28.0, 9.0, -4.0), vec(22.0, 18.0, 26.0), 0x616a6c),
      solid(
        "cooling-a",
        vec(-33.0, 13.0, 34.0),
        vec(16.0, 26.0, 14.0),
        0x707b7e,
      ),
      solid("cooling-b", vec(33.0, 16.0, 38.0), vec(16.0, 32.0, 18.0), 0x606e76),
      solid("central-cover", vec(0.0, 1.7, 6.0), vec(12.0, 3.4, 3.0), 0x69716e),
      solid("container-a", vec(-12.0, 1.6, 20.0), vec(5.0, 3.2, 12.0), 0x9a6746),
      solid("container-b", vec(-17.0, 1.6, 20.0), vec(5.0, 3.2, 12.0), 0x415e64),
      solid("container-c", vec(16.0, 1.6, -28.0), vec(5.0, 3.2, 12.0), 0x9b7949),
      solid("container-d", vec(14.0, 1.6, 34.0), vec(5.0, 3.2, 12.0), 0x415e64),
      solid("north-wall", vec(0.0, 4.0, 55.0), vec(100.0, 8.0, 2.0), 0x677271),
      solid("south-wall", vec(0.0, 4.0, -61.0), vec(100.0, 8.0, 2.0), 0x677271),
      solid("east-wall", vec(49.0, 4.0, -3.0), vec(2.0, 8.0, 114.0), 0x677271),
      solid("west-wall", vec(-49.0, 4.0, -3.0), vec(2.0, 8.0, 114.0), 0x677271),
    ],
  }
}
