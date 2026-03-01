///|
pub(all) enum Interpolation {
  Step
  Linear
} derive(Show)

///|
pub(all) enum ChannelTarget {
  Translation
  Rotation
  Scale
} derive(Show)

///|
pub(all) struct AnimChannel {
  node_index : Int
  target : ChannelTarget
  interpolation : Interpolation
  times : Array[Double]
  values : Array[Double] // flat: 3 for vec3, 4 for quat
}

///|
pub(all) struct AnimationClip {
  name : String
  channels : Array[AnimChannel]
  duration : Double
}

///|
pub(all) struct NodePose {
  node_index : Int
  translation : @math3d.Vec3?
  rotation : @math3d.Quaternion?
  scale : @math3d.Vec3?
}

///|
pub struct AnimationPlayer {
  clip : AnimationClip
  mut time : Double
  mut playing : Bool
  mut looping : Bool
  mut speed : Double
}
