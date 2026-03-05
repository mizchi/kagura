///|
/// 3D Particle System.
///
/// Billboard quad particles with emitter-based spawning.
/// Uses deterministic hash RNG for reproducible effects.

///|
pub(all) struct Particle {
  mut position : @math3d.Vec3
  mut velocity : @math3d.Vec3
  mut age : Double
  max_age : Double
  color : @math3d.Vec4
  mut size : Double
}

///|
pub(all) struct EmitterConfig {
  position : @math3d.Vec3
  spawn_rate : Double
  initial_velocity_min : @math3d.Vec3
  initial_velocity_max : @math3d.Vec3
  lifetime_min : Double
  lifetime_max : Double
  size_min : Double
  size_max : Double
  color_start : @math3d.Vec4
  color_end : @math3d.Vec4
  gravity : @math3d.Vec3
  max_particles : Int
}

///|
pub fn default_emitter_config() -> EmitterConfig {
  {
    position: @math3d.Vec3::zero(),
    spawn_rate: 50.0,
    initial_velocity_min: @math3d.Vec3::new(-0.5, 1.0, -0.5),
    initial_velocity_max: @math3d.Vec3::new(0.5, 3.0, 0.5),
    lifetime_min: 0.5,
    lifetime_max: 2.0,
    size_min: 0.05,
    size_max: 0.15,
    color_start: @math3d.Vec4::new(1.0, 0.8, 0.2, 1.0),
    color_end: @math3d.Vec4::new(1.0, 0.2, 0.0, 0.0),
    gravity: @math3d.Vec3::new(0.0, -9.8, 0.0),
    max_particles: 256,
  }
}

///|
pub(all) struct ParticleEmitter {
  config : EmitterConfig
  mut particles : Array[Particle]
  mut spawn_accumulator : Double
  mut frame_count : Int
}

///|
pub fn ParticleEmitter::new(config : EmitterConfig) -> ParticleEmitter {
  { config, particles: [], spawn_accumulator: 0.0, frame_count: 0 }
}

///|
/// Deterministic hash function for RNG.
fn hash_u32(seed : Int) -> Int {
  let mut h = seed
  h = (h.reinterpret_as_uint() ^ (h.reinterpret_as_uint() >> 16)).reinterpret_as_int()
  h = h * 0x45d9f3b
  h = (h.reinterpret_as_uint() ^ (h.reinterpret_as_uint() >> 16)).reinterpret_as_int()
  h = h * 0x45d9f3b
  h = (h.reinterpret_as_uint() ^ (h.reinterpret_as_uint() >> 16)).reinterpret_as_int()
  h & 0x7FFFFFFF
}

///|
/// Convert hash to [0, 1] range.
fn hash_to_double(seed : Int) -> Double {
  let h = hash_u32(seed)
  h.to_double() / 2147483647.0
}

///|
/// Linearly interpolate between min and max using a hash-based random value.
fn hash_lerp(seed : Int, min : Double, max : Double) -> Double {
  min + hash_to_double(seed) * (max - min)
}

///|
/// Update the emitter: age particles, remove dead ones, spawn new ones.
pub fn ParticleEmitter::update(self : ParticleEmitter, dt : Double) -> Unit {
  self.frame_count = self.frame_count + 1
  let gravity = self.config.gravity
  // Update existing particles
  let mut i = 0
  while i < self.particles.length() {
    let p = self.particles[i]
    p.age = p.age + dt
    if p.age >= p.max_age {
      // Remove dead particle by swapping with last
      let last = self.particles.length() - 1
      if i < last {
        self.particles[i] = self.particles[last]
      }
      let _ = self.particles.pop()
      // Don't increment i - re-check the swapped particle
    } else {
      // Apply gravity and move
      p.velocity = p.velocity.add(gravity.scale(dt))
      p.position = p.position.add(p.velocity.scale(dt))
      i = i + 1
    }
  }
  // Spawn new particles
  self.spawn_accumulator = self.spawn_accumulator + self.config.spawn_rate * dt
  let to_spawn = self.spawn_accumulator.to_int()
  self.spawn_accumulator = self.spawn_accumulator - to_spawn.to_double()
  let available = self.config.max_particles - self.particles.length()
  let actual_spawn = if to_spawn < available { to_spawn } else { available }
  for j = 0; j < actual_spawn; j = j + 1 {
    let seed_base = self.frame_count * 1000 + j
    let vx = hash_lerp(
      seed_base,
      self.config.initial_velocity_min.x,
      self.config.initial_velocity_max.x,
    )
    let vy = hash_lerp(
      seed_base + 1,
      self.config.initial_velocity_min.y,
      self.config.initial_velocity_max.y,
    )
    let vz = hash_lerp(
      seed_base + 2,
      self.config.initial_velocity_min.z,
      self.config.initial_velocity_max.z,
    )
    let lifetime = hash_lerp(
      seed_base + 3,
      self.config.lifetime_min,
      self.config.lifetime_max,
    )
    let size = hash_lerp(
      seed_base + 4,
      self.config.size_min,
      self.config.size_max,
    )
    self.particles.push({
      position: self.config.position,
      velocity: @math3d.Vec3::new(vx, vy, vz),
      age: 0.0,
      max_age: lifetime,
      color: self.config.color_start,
      size,
    })
  }
}

///|
/// Build billboard vertices for all active particles.
/// Returns (vertex_data, indices) in stride-8 format.
/// Normal channels encode RGB color, uv.x encodes alpha.
pub fn ParticleEmitter::build_billboard_vertices(
  self : ParticleEmitter,
  camera_right : @math3d.Vec3,
  camera_up : @math3d.Vec3,
) -> (Array[Double], Array[Int]) {
  let vertex_data : Array[Double] = []
  let indices : Array[Int] = []
  let cs = self.config.color_start
  let ce = self.config.color_end
  for i = 0; i < self.particles.length(); i = i + 1 {
    let p = self.particles[i]
    let t = if p.max_age > 0.0 { p.age / p.max_age } else { 1.0 }
    // Interpolate color
    let r = cs.x + (ce.x - cs.x) * t
    let g = cs.y + (ce.y - cs.y) * t
    let b = cs.z + (ce.z - cs.z) * t
    let a = cs.w + (ce.w - cs.w) * t
    let half = p.size * 0.5
    let right = camera_right.scale(half)
    let up = camera_up.scale(half)
    let base_idx = i * 4
    // Quad corners: bottom-left, bottom-right, top-right, top-left
    let corners = [
      p.position.sub(right).sub(up),
      p.position.add(right).sub(up),
      p.position.add(right).add(up),
      p.position.sub(right).add(up),
    ]
    for c = 0; c < 4; c = c + 1 {
      let pos = corners[c]
      // position (3)
      vertex_data.push(pos.x)
      vertex_data.push(pos.y)
      vertex_data.push(pos.z)
      // normal = RGB color (3)
      vertex_data.push(r)
      vertex_data.push(g)
      vertex_data.push(b)
      // uv.x = alpha, uv.y = 0 (2)
      vertex_data.push(a)
      vertex_data.push(0.0)
    }
    // Two triangles per quad
    indices.push(base_idx)
    indices.push(base_idx + 1)
    indices.push(base_idx + 2)
    indices.push(base_idx)
    indices.push(base_idx + 2)
    indices.push(base_idx + 3)
  }
  (vertex_data, indices)
}

///|
/// Get the number of active particles.
pub fn ParticleEmitter::particle_count(self : ParticleEmitter) -> Int {
  self.particles.length()
}
