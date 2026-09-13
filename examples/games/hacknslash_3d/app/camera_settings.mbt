// Camera preferences are independent of character/world saves and combat clocks.

///|
struct HunterCameraTuning {
  tilt : Double
  distance : Double
  side : Double
  height : Double
  forward : Double
} derive(ToJson, FromJson, Eq)

///|
fn hunter_camera_defaults(mode : Int) -> HunterCameraTuning {
  if mode == 1 {
    { tilt: 18.0, distance: 4.5, side: 0.55, height: 1.0, forward: 0.65, }
  } else {
    {
      tilt: 0.78 * 180.0 / @math.PI,
      distance: 18.0,
      side: 0.0,
      height: 0.4,
      forward: 0.0,
    }
  }
}

///|
fn HunterCameraTuning::clamped(
  self : HunterCameraTuning,
  mode : Int,
) -> HunterCameraTuning {
  {
    tilt: self.tilt.clamp(
      min=if mode == 1 { 5.0 } else { 20.0 },
      max=if mode == 1 { 60.0 } else { 80.0 },
    ),
    distance: self.distance.clamp(
      min=if mode == 1 { 2.0 } else { 8.0 },
      max=if mode == 1 { 8.0 } else { 26.0 },
    ),
    side: self.side.clamp(min=-2.0, max=2.0),
    height: self.height.clamp(min=0.2, max=2.0),
    forward: self.forward.clamp(min=-2.0, max=3.0),
  }
}

///|
struct HunterCameraPreferences {
  version : Int
  mode : Int
  quarter : HunterCameraTuning
  tps : HunterCameraTuning
} derive(ToJson, FromJson)

///|
struct HunterCameraSettings {
  mut mode : Int
  mut quarter : HunterCameraTuning
  mut tps : HunterCameraTuning
  mut editing : Bool
}

///|
fn HunterCameraSettings::new() -> HunterCameraSettings {
  {
    mode: 0,
    quarter: hunter_camera_defaults(0),
    tps: hunter_camera_defaults(1),
    editing: false,
  }
}

///|
fn HunterCameraSettings::active(
  self : HunterCameraSettings,
) -> HunterCameraTuning {
  if self.mode == 1 {
    self.tps
  } else {
    self.quarter
  }
}

///|
fn HunterCameraSettings::set_active(
  self : HunterCameraSettings,
  tuning : HunterCameraTuning,
) -> Unit {
  let tuning = tuning.clamped(self.mode)
  if self.mode == 1 {
    self.tps = tuning
  } else {
    self.quarter = tuning
  }
}

///|
fn HunterCameraSettings::serialize(self : HunterCameraSettings) -> String {
  HunterCameraPreferences::{
    version: 1,
    mode: self.mode,
    quarter: self.quarter,
    tps: self.tps,
  }
  .to_json()
  .stringify()
}

///|
fn HunterCameraSettings::restore(
  self : HunterCameraSettings,
  source : String,
) -> Bool {
  try {
    let prefs : HunterCameraPreferences = @json.from_json(@json.parse(source))
    if prefs.version != 1 || (prefs.mode != 0 && prefs.mode != 1) {
      return false
    }
    self.mode = prefs.mode
    self.quarter = prefs.quarter.clamped(0)
    self.tps = prefs.tps.clamped(1)
    true
  } catch {
    _ => false
  }
}

///|
struct HunterCameraView {
  mode : Int
  editing : Bool
  tuning : HunterCameraTuning
  crosshair : Bool
} derive(ToJson)

///|
fn GameState::hunter_camera_view(self : GameState) -> HunterCameraView {
  {
    mode: self.camera_settings.mode,
    editing: self.camera_settings.editing,
    tuning: self.camera_settings.active(),
    crosshair: self.camera_settings.mode == 1 &&
    self.aim.pointer is Some(_) &&
    !self.paused &&
    !self.ground_targeting,
  }
}

///|
fn GameState::apply_camera_tuning(self : GameState) -> Unit {
  let settings = self.camera_settings
  let tuning = settings.active()
  self.camera = self.camera
    .orbit(0.0, tuning.tilt * @math.PI / 180.0 - self.camera.pitch)
    .with_distance(tuning.distance)
  self.camera = hunter_responsive_camera(
    self.camera,
    canvas_css_width(),
    canvas_css_height(),
    tps=settings.mode == 1,
  )
  self.combat_feedback.look_x = 0.0
  self.combat_feedback.look_y = 0.0
  self.update_combat_camera()
}

///|
// Bridge command: [field, value]. 0 mode, 1 tilt, 2 distance, 3 side,
// 4 target height, 5 forward, 6 reset. Invalid messages leave preferences intact.
fn GameState::apply_camera_command(
  self : GameState,
  command : Array[Double],
) -> Bool {
  if command.length() != 2 ||
    command[0].is_nan() ||
    command[0] < 0.0 ||
    command[0] > 6.0 ||
    command[0] != command[0].to_int().to_double() ||
    command[1].is_nan() ||
    command[1].abs() > 1.0e9 {
    return false
  }
  let settings = self.camera_settings
  let value = command[1]
  let tuning = settings.active()
  match command[0].to_int() {
    0 => {
      if value != 0.0 && value != 1.0 {
        return false
      }
      if settings.mode != value.to_int() {
        settings.mode = value.to_int()
        if settings.mode == 1 {
          // Enter TPS from behind the hunter; movement thereafter stays camera-relative.
          self.align_tps_camera()
        }
      }
    }
    1 => settings.set_active({ ..tuning, tilt: value, })
    2 => settings.set_active({ ..tuning, distance: value, })
    3 => settings.set_active({ ..tuning, side: value, })
    4 => settings.set_active({ ..tuning, height: value, })
    5 => settings.set_active({ ..tuning, forward: value, })
    6 => settings.set_active(hunter_camera_defaults(settings.mode))
    _ => return false
  }
  self.apply_camera_tuning()
  hunter_save_camera_preferences(settings.serialize())
  true
}

///|
fn GameState::camera_framing_target(
  self : GameState,
  height : Double,
) -> @math3d.Vec3 {
  let tuning = self.camera_settings.active()
  let sy = @math.sin(self.camera.yaw)
  let cy = @math.cos(self.camera.yaw)
  @math3d.Vec3::new(
    self.world.player.x / tile_size + cy * tuning.side - sy * tuning.forward,
    height + tuning.height,
    self.world.player.y / tile_size - sy * tuning.side - cy * tuning.forward,
  )
}

///|
// Short boom sweep with a camera-sized margin. Only TPS needs wall avoidance;
// the requested distance remains a preference so it is recovered in open space.
fn GameState::camera_clear_segment(
  self : GameState,
  start : @math3d.Vec3,
  end : @math3d.Vec3,
) -> Double {
  let delta = end.sub(start)
  let length = delta.length()
  if length < 0.001 {
    return 1.0
  }
  let steps = (length / 0.12).to_int() + 1
  for i in 1..<=steps {
    let t = i.to_double() / steps.to_double()
    let point = start.add(delta.scale(t))
    let floor = @game.get_tile_height(
      self.world.dungeon,
      point.x * tile_size,
      point.z * tile_size,
    )
    let blocked = point.y < floor + 0.18 ||
      (
        point.y < floor + 3.2 &&
        @game.check_wall_collision(
          self.world.dungeon.grid,
          point.x * tile_size,
          point.z * tile_size,
          tile_size * 0.18,
        )
      )
    if blocked {
      return ((i - 1).to_double() / steps.to_double()).max(0.0)
    }
  }
  1.0
}

///|
fn GameState::resolve_tps_camera(self : GameState, height : Double) -> Unit {
  let anchor = @math3d.Vec3::new(
    self.world.player.x / tile_size,
    height + 1.0,
    self.world.player.y / tile_size,
  )
  let target = self.camera.target
  let t = self.camera_clear_segment(anchor, target)
  self.camera = self.camera.with_target(anchor.add(target.sub(anchor).scale(t)))
  self.camera = self.camera.with_distance(
    self.camera_settings.active().distance,
  )
  let clear = self.camera_clear_segment(
    self.camera.target,
    self.camera.position(),
  )
  self.camera = self.camera.with_distance(
    (self.camera.distance * clear).max(0.15),
  )
}

///|
fn GameState::align_tps_camera(self : GameState) -> Unit {
  let facing = self.world.player.facing_angle
  self.camera = self.camera.orbit(
    @math.atan2(-@math.cos(facing), -@math.sin(facing)) - self.camera.yaw,
    0.0,
  )
}
