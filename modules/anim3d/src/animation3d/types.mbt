///|
pub(all) enum Interpolation {
  Step
  Linear
} derive(Debug)

///|
pub impl Show for Interpolation with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
pub(all) enum ChannelTarget {
  Translation
  Rotation
  Scale
} derive(Debug)

///|
pub impl Show for ChannelTarget with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

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

///|
pub(all) struct AnimTransition3D {
  from_state : String // "*" for any_state
  to_state : String
  trigger : String
  blend_duration : Double // cross-fade seconds (0.0 = instant)
}
