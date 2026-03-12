///|
pub enum EffectPresetId {
  ForgeBurst
  ChainLightning
  SplittingFireball
  IceNova
} derive(Eq, Show)

///|
pub fn effect_preset_id_name(id : EffectPresetId) -> String {
  match id {
    ForgeBurst => "forge_burst"
    ChainLightning => "chain_lightning"
    SplittingFireball => "splitting_fireball"
    IceNova => "ice_nova"
  }
}

///|
fn chain_lightning_arc_track() -> EffectTrack {
  {
    id: "arc_core",
    label: "Arc Core",
    start_time: 0.0,
    duration: 0.14,
    burst_interval: 0.028,
    burst_particles: 9,
    pattern: Line,
    origin: @math3d.Vec3::new(0.0, 0.35, 0.0),
    secondary_origin: @math3d.Vec3::new(1.0, 0.35, 0.0),
    spread_radius: 0.04,
    initial_velocity_min: @math3d.Vec3::new(-0.2, 0.1, -0.2),
    initial_velocity_max: @math3d.Vec3::new(0.2, 1.2, 0.2),
    lifetime_min: 0.06,
    lifetime_max: 0.14,
    size_min: 0.03,
    size_max: 0.08,
    color_start: @math3d.Vec4::new(0.8, 0.95, 1.0, 1.0),
    color_end: @math3d.Vec4::new(0.2, 0.55, 1.0, 0.0),
    gravity: @math3d.Vec3::new(0.0, -0.6, 0.0),
    enabled: true,
  }
}

///|
fn chain_lightning_glow_track() -> EffectTrack {
  {
    id: "arc_glow",
    label: "Arc Glow",
    start_time: 0.0,
    duration: 0.18,
    burst_interval: 0.06,
    burst_particles: 12,
    pattern: Line,
    origin: @math3d.Vec3::new(0.0, 0.28, 0.0),
    secondary_origin: @math3d.Vec3::new(1.0, 0.28, 0.0),
    spread_radius: 0.08,
    initial_velocity_min: @math3d.Vec3::new(-0.12, 0.1, -0.12),
    initial_velocity_max: @math3d.Vec3::new(0.12, 0.5, 0.12),
    lifetime_min: 0.08,
    lifetime_max: 0.18,
    size_min: 0.04,
    size_max: 0.10,
    color_start: @math3d.Vec4::new(0.55, 0.8, 1.0, 0.65),
    color_end: @math3d.Vec4::new(0.15, 0.3, 0.8, 0.0),
    gravity: @math3d.Vec3::new(0.0, -0.3, 0.0),
    enabled: true,
  }
}

///|
pub fn chain_lightning_effect_document() -> EffectDocument {
  {
    name: "chain_lightning",
    duration: 0.24,
    looping: false,
    notes: "Short chained lightning arc. Use multiple instances for each hop.",
    ai_edit_goal: "Keep the beam readable in 0.0-0.18s and bias the brightest energy toward the first 60% of the timeline.",
    tracks: [chain_lightning_arc_track(), chain_lightning_glow_track()],
  }
}

///|
fn splitting_fireball_core_track() -> EffectTrack {
  {
    id: "fireball_core",
    label: "Fireball Core",
    start_time: 0.0,
    duration: 0.18,
    burst_interval: 0.06,
    burst_particles: 16,
    pattern: Point,
    origin: @math3d.Vec3::new(0.0, 0.32, 0.0),
    secondary_origin: @math3d.Vec3::new(0.0, 0.32, 0.0),
    spread_radius: 0.0,
    initial_velocity_min: @math3d.Vec3::new(-0.3, 1.2, -0.3),
    initial_velocity_max: @math3d.Vec3::new(0.3, 2.0, 0.3),
    lifetime_min: 0.10,
    lifetime_max: 0.22,
    size_min: 0.08,
    size_max: 0.16,
    color_start: @math3d.Vec4::new(1.0, 0.92, 0.55, 1.0),
    color_end: @math3d.Vec4::new(1.0, 0.38, 0.08, 0.0),
    gravity: @math3d.Vec3::new(0.0, -2.2, 0.0),
    enabled: true,
  }
}

///|
fn splitting_fireball_split_ring_track() -> EffectTrack {
  {
    id: "split_ring",
    label: "Split Ring",
    start_time: 0.06,
    duration: 0.26,
    burst_interval: 0.08,
    burst_particles: 10,
    pattern: Ring,
    origin: @math3d.Vec3::new(0.0, 0.20, 0.0),
    secondary_origin: @math3d.Vec3::new(0.0, 0.20, 0.0),
    spread_radius: 0.42,
    initial_velocity_min: @math3d.Vec3::new(-0.4, 0.6, -0.4),
    initial_velocity_max: @math3d.Vec3::new(0.4, 1.4, 0.4),
    lifetime_min: 0.24,
    lifetime_max: 0.42,
    size_min: 0.04,
    size_max: 0.08,
    color_start: @math3d.Vec4::new(1.0, 0.62, 0.18, 1.0),
    color_end: @math3d.Vec4::new(0.68, 0.10, 0.02, 0.0),
    gravity: @math3d.Vec3::new(0.0, -2.8, 0.0),
    enabled: true,
  }
}

///|
fn splitting_fireball_smoke_track() -> EffectTrack {
  {
    id: "fireball_smoke",
    label: "Fireball Smoke",
    start_time: 0.10,
    duration: 0.55,
    burst_interval: 0.14,
    burst_particles: 7,
    pattern: Column,
    origin: @math3d.Vec3::new(0.0, 0.12, 0.0),
    secondary_origin: @math3d.Vec3::new(0.0, 0.12, 0.0),
    spread_radius: 0.18,
    initial_velocity_min: @math3d.Vec3::new(-0.08, 0.4, -0.08),
    initial_velocity_max: @math3d.Vec3::new(0.08, 1.0, 0.08),
    lifetime_min: 0.55,
    lifetime_max: 0.90,
    size_min: 0.10,
    size_max: 0.18,
    color_start: @math3d.Vec4::new(0.55, 0.48, 0.42, 0.55),
    color_end: @math3d.Vec4::new(0.08, 0.06, 0.05, 0.0),
    gravity: @math3d.Vec3::new(0.0, -0.2, 0.0),
    enabled: true,
  }
}

///|
pub fn splitting_fireball_effect_document() -> EffectDocument {
  {
    name: "splitting_fireball",
    duration: 0.85,
    looping: false,
    notes: "Impact burst for a splitting fireball with hot core, radial split sparks, and smoke.",
    ai_edit_goal: "Keep the impact bright at 0.0-0.1s and make the split ring read clearly by 0.14s.",
    tracks: [
      splitting_fireball_core_track(),
      splitting_fireball_split_ring_track(),
      splitting_fireball_smoke_track(),
    ],
  }
}

///|
fn ice_nova_ring_track() -> EffectTrack {
  {
    id: "nova_ring",
    label: "Nova Ring",
    start_time: 0.0,
    duration: 0.22,
    burst_interval: 0.04,
    burst_particles: 18,
    pattern: Ring,
    origin: @math3d.Vec3::new(0.0, 0.18, 0.0),
    secondary_origin: @math3d.Vec3::new(0.0, 0.18, 0.0),
    spread_radius: 0.66,
    initial_velocity_min: @math3d.Vec3::new(-1.0, 0.35, -1.0),
    initial_velocity_max: @math3d.Vec3::new(1.0, 0.9, 1.0),
    lifetime_min: 0.20,
    lifetime_max: 0.36,
    size_min: 0.05,
    size_max: 0.10,
    color_start: @math3d.Vec4::new(0.86, 0.98, 1.0, 1.0),
    color_end: @math3d.Vec4::new(0.34, 0.80, 1.0, 0.0),
    gravity: @math3d.Vec3::new(0.0, -1.2, 0.0),
    enabled: true,
  }
}

///|
fn ice_nova_ring_echo_track() -> EffectTrack {
  {
    id: "nova_ring_echo",
    label: "Nova Ring Echo",
    start_time: 0.05,
    duration: 0.28,
    burst_interval: 0.05,
    burst_particles: 12,
    pattern: Ring,
    origin: @math3d.Vec3::new(0.0, 0.16, 0.0),
    secondary_origin: @math3d.Vec3::new(0.0, 0.16, 0.0),
    spread_radius: 0.88,
    initial_velocity_min: @math3d.Vec3::new(-1.1, 0.25, -1.1),
    initial_velocity_max: @math3d.Vec3::new(1.1, 0.75, 1.1),
    lifetime_min: 0.24,
    lifetime_max: 0.42,
    size_min: 0.04,
    size_max: 0.08,
    color_start: @math3d.Vec4::new(0.68, 0.90, 1.0, 0.72),
    color_end: @math3d.Vec4::new(0.22, 0.60, 0.90, 0.0),
    gravity: @math3d.Vec3::new(0.0, -0.9, 0.0),
    enabled: true,
  }
}

///|
fn ice_nova_spokes_x_track() -> EffectTrack {
  {
    id: "nova_spokes_x",
    label: "Nova Spokes X",
    start_time: 0.0,
    duration: 0.16,
    burst_interval: 0.032,
    burst_particles: 8,
    pattern: Line,
    origin: @math3d.Vec3::new(-0.72, 0.20, 0.0),
    secondary_origin: @math3d.Vec3::new(0.72, 0.20, 0.0),
    spread_radius: 0.02,
    initial_velocity_min: @math3d.Vec3::new(-0.2, 0.15, -0.05),
    initial_velocity_max: @math3d.Vec3::new(0.2, 0.55, 0.05),
    lifetime_min: 0.16,
    lifetime_max: 0.28,
    size_min: 0.04,
    size_max: 0.08,
    color_start: @math3d.Vec4::new(0.88, 0.98, 1.0, 0.92),
    color_end: @math3d.Vec4::new(0.42, 0.78, 1.0, 0.0),
    gravity: @math3d.Vec3::new(0.0, -0.8, 0.0),
    enabled: true,
  }
}

///|
fn ice_nova_spokes_z_track() -> EffectTrack {
  {
    id: "nova_spokes_z",
    label: "Nova Spokes Z",
    start_time: 0.0,
    duration: 0.16,
    burst_interval: 0.032,
    burst_particles: 8,
    pattern: Line,
    origin: @math3d.Vec3::new(0.0, 0.20, -0.72),
    secondary_origin: @math3d.Vec3::new(0.0, 0.20, 0.72),
    spread_radius: 0.02,
    initial_velocity_min: @math3d.Vec3::new(-0.05, 0.15, -0.2),
    initial_velocity_max: @math3d.Vec3::new(0.05, 0.55, 0.2),
    lifetime_min: 0.16,
    lifetime_max: 0.28,
    size_min: 0.04,
    size_max: 0.08,
    color_start: @math3d.Vec4::new(0.88, 0.98, 1.0, 0.92),
    color_end: @math3d.Vec4::new(0.42, 0.78, 1.0, 0.0),
    gravity: @math3d.Vec3::new(0.0, -0.8, 0.0),
    enabled: true,
  }
}

///|
fn ice_nova_mist_track() -> EffectTrack {
  {
    id: "nova_mist",
    label: "Nova Mist",
    start_time: 0.04,
    duration: 0.42,
    burst_interval: 0.14,
    burst_particles: 5,
    pattern: Column,
    origin: @math3d.Vec3::new(0.0, 0.10, 0.0),
    secondary_origin: @math3d.Vec3::new(0.0, 0.10, 0.0),
    spread_radius: 0.22,
    initial_velocity_min: @math3d.Vec3::new(-0.10, 0.28, -0.10),
    initial_velocity_max: @math3d.Vec3::new(0.10, 0.72, 0.10),
    lifetime_min: 0.32,
    lifetime_max: 0.62,
    size_min: 0.08,
    size_max: 0.14,
    color_start: @math3d.Vec4::new(0.72, 0.9, 1.0, 0.22),
    color_end: @math3d.Vec4::new(0.18, 0.34, 0.55, 0.0),
    gravity: @math3d.Vec3::new(0.0, -0.25, 0.0),
    enabled: true,
  }
}

///|
fn ice_nova_core_track() -> EffectTrack {
  {
    id: "nova_core",
    label: "Nova Core",
    start_time: 0.0,
    duration: 0.12,
    burst_interval: 0.12,
    burst_particles: 18,
    pattern: Point,
    origin: @math3d.Vec3::new(0.0, 0.22, 0.0),
    secondary_origin: @math3d.Vec3::new(0.0, 0.22, 0.0),
    spread_radius: 0.0,
    initial_velocity_min: @math3d.Vec3::new(-0.25, 0.2, -0.25),
    initial_velocity_max: @math3d.Vec3::new(0.25, 1.4, 0.25),
    lifetime_min: 0.10,
    lifetime_max: 0.22,
    size_min: 0.06,
    size_max: 0.12,
    color_start: @math3d.Vec4::new(0.96, 1.0, 1.0, 1.0),
    color_end: @math3d.Vec4::new(0.55, 0.85, 1.0, 0.0),
    gravity: @math3d.Vec3::new(0.0, -2.0, 0.0),
    enabled: true,
  }
}

///|
pub fn ice_nova_effect_document() -> EffectDocument {
  {
    name: "ice_nova",
    duration: 0.75,
    looping: false,
    notes: "Circular frost burst around the caster with a clear ring, radial spokes, and lingering mist.",
    ai_edit_goal: "Keep the ring and spoke expansion readable from top-down view and let the cold mist linger only as a secondary layer.",
    tracks: [
      ice_nova_ring_track(),
      ice_nova_ring_echo_track(),
      ice_nova_spokes_x_track(),
      ice_nova_spokes_z_track(),
      ice_nova_mist_track(),
      ice_nova_core_track(),
    ],
  }
}

///|
pub fn effect_preset_document(id : EffectPresetId) -> EffectDocument {
  match id {
    ForgeBurst => default_effect_document()
    ChainLightning => chain_lightning_effect_document()
    SplittingFireball => splitting_fireball_effect_document()
    IceNova => ice_nova_effect_document()
  }
}
