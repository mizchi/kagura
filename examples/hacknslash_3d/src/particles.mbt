// Game-specific particle effect spawn functions

// Convert 2D game coords to 3D world position

///|
fn game_to_3d(x : Double, y : Double, height : Double) -> @math3d.Vec3 {
  @math3d.Vec3::new(x / tile_size, height, y / tile_size)
}

///|
fn spawn_hit_sparks(
  pm : @particle3d.ParticleManager,
  x : Double,
  y : Double,
) -> Unit {
  let pos = game_to_3d(x, y, 0.5)
  pm.spawn({
    position: pos,
    spawn_rate: 1200.0,
    initial_velocity_min: @math3d.Vec3::new(-2.0, 2.0, -2.0),
    initial_velocity_max: @math3d.Vec3::new(2.0, 5.0, 2.0),
    lifetime_min: 0.15,
    lifetime_max: 0.4,
    size_min: 0.03,
    size_max: 0.08,
    color_start: @math3d.Vec4::new(1.0, 0.9, 0.2, 1.0),
    color_end: @math3d.Vec4::new(1.0, 0.5, 0.0, 0.0),
    gravity: @math3d.Vec3::new(0.0, -8.0, 0.0),
    max_particles: 15,
  })
}

///|
fn spawn_death_burst(
  pm : @particle3d.ParticleManager,
  x : Double,
  y : Double,
) -> Unit {
  let pos = game_to_3d(x, y, 0.4)
  pm.spawn({
    position: pos,
    spawn_rate: 2000.0,
    initial_velocity_min: @math3d.Vec3::new(-3.0, 1.0, -3.0),
    initial_velocity_max: @math3d.Vec3::new(3.0, 5.0, 3.0),
    lifetime_min: 0.3,
    lifetime_max: 0.8,
    size_min: 0.05,
    size_max: 0.18,
    color_start: @math3d.Vec4::new(1.0, 0.3, 0.1, 1.0),
    color_end: @math3d.Vec4::new(0.4, 0.05, 0.0, 0.0),
    gravity: @math3d.Vec3::new(0.0, -4.0, 0.0),
    max_particles: 30,
  })
}

///|
fn spawn_dash_trail(
  pm : @particle3d.ParticleManager,
  x : Double,
  y : Double,
) -> Unit {
  let pos = game_to_3d(x, y, 0.3)
  pm.spawn({
    position: pos,
    spawn_rate: 500.0,
    initial_velocity_min: @math3d.Vec3::new(-0.3, 0.5, -0.3),
    initial_velocity_max: @math3d.Vec3::new(0.3, 1.5, 0.3),
    lifetime_min: 0.2,
    lifetime_max: 0.5,
    size_min: 0.04,
    size_max: 0.1,
    color_start: @math3d.Vec4::new(0.4, 0.87, 1.0, 0.8),
    color_end: @math3d.Vec4::new(0.2, 0.5, 1.0, 0.0),
    gravity: @math3d.Vec3::new(0.0, -1.0, 0.0),
    max_particles: 5,
  })
}

///|
fn spawn_item_pickup(
  pm : @particle3d.ParticleManager,
  x : Double,
  y : Double,
  is_health : Bool,
) -> Unit {
  let pos = game_to_3d(x, y, 0.3)
  let (cs, ce) = if is_health {
    (
      @math3d.Vec4::new(0.2, 1.0, 0.4, 1.0),
      @math3d.Vec4::new(1.0, 1.0, 1.0, 0.0),
    )
  } else {
    (
      @math3d.Vec4::new(1.0, 0.85, 0.2, 1.0),
      @math3d.Vec4::new(1.0, 1.0, 1.0, 0.0),
    )
  }
  pm.spawn({
    position: pos,
    spawn_rate: 800.0,
    initial_velocity_min: @math3d.Vec3::new(-1.5, 2.0, -1.5),
    initial_velocity_max: @math3d.Vec3::new(1.5, 4.0, 1.5),
    lifetime_min: 0.3,
    lifetime_max: 0.6,
    size_min: 0.03,
    size_max: 0.08,
    color_start: cs,
    color_end: ce,
    gravity: @math3d.Vec3::new(0.0, -3.0, 0.0),
    max_particles: 12,
  })
}

///|
fn spawn_fireball_trail(
  pm : @particle3d.ParticleManager,
  x : Double,
  y : Double,
) -> Unit {
  let pos = game_to_3d(x, y, 0.28)
  pm.spawn({
    position: pos,
    spawn_rate: 340.0,
    initial_velocity_min: @math3d.Vec3::new(-0.18, 0.35, -0.18),
    initial_velocity_max: @math3d.Vec3::new(0.18, 0.95, 0.18),
    lifetime_min: 0.16,
    lifetime_max: 0.28,
    size_min: 0.05,
    size_max: 0.11,
    color_start: @math3d.Vec4::new(1.0, 0.76, 0.18, 0.92),
    color_end: @math3d.Vec4::new(0.70, 0.10, 0.02, 0.0),
    gravity: @math3d.Vec3::new(0.0, -2.0, 0.0),
    max_particles: 9,
  })
}

///|
fn spawn_player_hurt(
  pm : @particle3d.ParticleManager,
  x : Double,
  y : Double,
) -> Unit {
  let pos = game_to_3d(x, y, 0.5)
  pm.spawn({
    position: pos,
    spawn_rate: 1500.0,
    initial_velocity_min: @math3d.Vec3::new(-2.5, 1.0, -2.5),
    initial_velocity_max: @math3d.Vec3::new(2.5, 4.0, 2.5),
    lifetime_min: 0.2,
    lifetime_max: 0.5,
    size_min: 0.04,
    size_max: 0.12,
    color_start: @math3d.Vec4::new(1.0, 0.15, 0.15, 1.0),
    color_end: @math3d.Vec4::new(0.3, 0.0, 0.0, 0.0),
    gravity: @math3d.Vec3::new(0.0, -5.0, 0.0),
    max_particles: 20,
  })
}

// Ambient dust particles — spawned periodically near the player

///|
fn spawn_ambient_dust(
  pm : @particle3d.ParticleManager,
  x : Double,
  y : Double,
  frame : Int,
) -> Unit {
  // Pseudo-random offset around player using frame as seed
  let ox = ((frame * 73 + 17) % 200 - 100).to_double() / 100.0 * 3.0
  let oz = ((frame * 37 + 53) % 200 - 100).to_double() / 100.0 * 3.0
  let pos = game_to_3d(x + ox * tile_size, y + oz * tile_size, 0.1)
  pm.spawn({
    position: pos,
    spawn_rate: 100.0,
    initial_velocity_min: @math3d.Vec3::new(-0.1, 0.1, -0.1),
    initial_velocity_max: @math3d.Vec3::new(0.1, 0.4, 0.1),
    lifetime_min: 1.5,
    lifetime_max: 3.0,
    size_min: 0.01,
    size_max: 0.03,
    color_start: @math3d.Vec4::new(0.6, 0.55, 0.4, 0.3),
    color_end: @math3d.Vec4::new(0.5, 0.45, 0.35, 0.0),
    gravity: @math3d.Vec3::new(0.0, 0.05, 0.0),
    max_particles: 3,
  })
}
