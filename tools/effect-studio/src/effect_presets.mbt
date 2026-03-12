///|
pub enum EffectPresetId {
  ForgeBurst
  ChainLightning
  HomingMissile
  HomingMissileImpact
  SplittingFireball
  IceNova
  GroundTelegraphRing
  GroundTelegraphLine
} derive(Eq, Show)

///|
pub fn effect_preset_id_name(id : EffectPresetId) -> String {
  match id {
    ForgeBurst => "forge_burst"
    ChainLightning => "chain_lightning"
    HomingMissile => "homing_missile"
    HomingMissileImpact => "homing_missile_impact"
    SplittingFireball => "splitting_fireball"
    IceNova => "ice_nova"
    GroundTelegraphRing => "ground_telegraph_ring"
    GroundTelegraphLine => "ground_telegraph_line"
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
fn chain_lightning_beam_track() -> EffectTrack {
  {
    id: "arc_beam",
    label: "Arc Beam",
    start_time: 0.0,
    duration: 0.16,
    burst_interval: 0.024,
    burst_particles: 14,
    pattern: Line,
    origin: @math3d.Vec3::new(0.0, 0.34, 0.0),
    secondary_origin: @math3d.Vec3::new(1.0, 0.34, 0.0),
    spread_radius: 0.06,
    initial_velocity_min: @math3d.Vec3::new(-0.08, 0.18, -0.08),
    initial_velocity_max: @math3d.Vec3::new(0.08, 0.72, 0.08),
    lifetime_min: 0.08,
    lifetime_max: 0.18,
    size_min: 0.06,
    size_max: 0.14,
    color_start: @math3d.Vec4::new(0.95, 1.0, 1.0, 0.96),
    color_end: @math3d.Vec4::new(0.22, 0.58, 1.0, 0.0),
    gravity: @math3d.Vec3::new(0.0, -0.4, 0.0),
    enabled: true,
  }
}

///|
fn chain_lightning_sparks_track() -> EffectTrack {
  {
    id: "arc_sparks",
    label: "Arc Sparks",
    start_time: 0.01,
    duration: 0.18,
    burst_interval: 0.036,
    burst_particles: 10,
    pattern: Line,
    origin: @math3d.Vec3::new(0.0, 0.28, 0.0),
    secondary_origin: @math3d.Vec3::new(1.0, 0.28, 0.0),
    spread_radius: 0.11,
    initial_velocity_min: @math3d.Vec3::new(-0.55, 0.12, -0.55),
    initial_velocity_max: @math3d.Vec3::new(0.55, 1.25, 0.55),
    lifetime_min: 0.10,
    lifetime_max: 0.22,
    size_min: 0.03,
    size_max: 0.08,
    color_start: @math3d.Vec4::new(0.72, 0.90, 1.0, 0.82),
    color_end: @math3d.Vec4::new(0.25, 0.42, 0.95, 0.0),
    gravity: @math3d.Vec3::new(0.0, -1.1, 0.0),
    enabled: true,
  }
}

///|
pub fn chain_lightning_effect_document() -> EffectDocument {
  {
    name: "chain_lightning",
    duration: 0.28,
    looping: false,
    notes: "Short chained lightning arc with a thick beam core and secondary crackle sparks.",
    ai_edit_goal: "Keep the beam readable in 0.0-0.2s, with a thick core and a brighter secondary crackle shell.",
    tracks: [
      chain_lightning_arc_track(),
      chain_lightning_beam_track(),
      chain_lightning_glow_track(),
      chain_lightning_sparks_track(),
    ],
  }
}

///|
fn homing_missile_core_track() -> EffectTrack {
  {
    id: "missile_core",
    label: "Missile Core",
    start_time: 0.0,
    duration: 0.20,
    burst_interval: 0.026,
    burst_particles: 10,
    pattern: Line,
    origin: @math3d.Vec3::new(0.0, 0.48, 0.0),
    secondary_origin: @math3d.Vec3::new(1.0, 0.52, 0.0),
    spread_radius: 0.04,
    initial_velocity_min: @math3d.Vec3::new(-0.10, 0.14, -0.10),
    initial_velocity_max: @math3d.Vec3::new(0.10, 0.72, 0.10),
    lifetime_min: 0.08,
    lifetime_max: 0.16,
    size_min: 0.05,
    size_max: 0.12,
    color_start: @math3d.Vec4::new(1.0, 0.86, 0.42, 0.96),
    color_end: @math3d.Vec4::new(1.0, 0.24, 0.10, 0.0),
    gravity: @math3d.Vec3::new(0.0, -0.5, 0.0),
    enabled: true,
  }
}

///|
fn homing_missile_glow_track() -> EffectTrack {
  {
    id: "missile_glow",
    label: "Missile Glow",
    start_time: 0.0,
    duration: 0.22,
    burst_interval: 0.05,
    burst_particles: 12,
    pattern: Line,
    origin: @math3d.Vec3::new(0.0, 0.42, 0.0),
    secondary_origin: @math3d.Vec3::new(1.0, 0.46, 0.0),
    spread_radius: 0.08,
    initial_velocity_min: @math3d.Vec3::new(-0.08, 0.10, -0.08),
    initial_velocity_max: @math3d.Vec3::new(0.08, 0.46, 0.08),
    lifetime_min: 0.10,
    lifetime_max: 0.20,
    size_min: 0.05,
    size_max: 0.14,
    color_start: @math3d.Vec4::new(1.0, 0.58, 0.24, 0.72),
    color_end: @math3d.Vec4::new(0.74, 0.10, 0.26, 0.0),
    gravity: @math3d.Vec3::new(0.0, -0.25, 0.0),
    enabled: true,
  }
}

///|
fn homing_missile_sparks_track() -> EffectTrack {
  {
    id: "missile_sparks",
    label: "Missile Sparks",
    start_time: 0.02,
    duration: 0.24,
    burst_interval: 0.04,
    burst_particles: 8,
    pattern: Line,
    origin: @math3d.Vec3::new(0.0, 0.38, 0.0),
    secondary_origin: @math3d.Vec3::new(1.0, 0.42, 0.0),
    spread_radius: 0.12,
    initial_velocity_min: @math3d.Vec3::new(-0.45, 0.12, -0.45),
    initial_velocity_max: @math3d.Vec3::new(0.45, 0.92, 0.45),
    lifetime_min: 0.12,
    lifetime_max: 0.24,
    size_min: 0.03,
    size_max: 0.07,
    color_start: @math3d.Vec4::new(1.0, 0.82, 0.48, 0.82),
    color_end: @math3d.Vec4::new(0.86, 0.18, 0.08, 0.0),
    gravity: @math3d.Vec3::new(0.0, -1.2, 0.0),
    enabled: true,
  }
}

///|
pub fn homing_missile_effect_document() -> EffectDocument {
  {
    name: "homing_missile",
    duration: 0.36,
    looping: false,
    notes: "Arcing homing missile trail with a bright core, warm glow, and spark shell.",
    ai_edit_goal: "Keep the missile path readable from the gameplay camera and make the trail feel like a rising arc with a bright nose cone.",
    tracks: [
      homing_missile_core_track(),
      homing_missile_glow_track(),
      homing_missile_sparks_track(),
    ],
  }
}

///|
fn homing_missile_impact_ring_track() -> EffectTrack {
  {
    id: "impact_ring",
    label: "Impact Ring",
    start_time: 0.0,
    duration: 0.22,
    burst_interval: 0.05,
    burst_particles: 12,
    pattern: Ring,
    origin: @math3d.Vec3::new(0.0, 0.18, 0.0),
    secondary_origin: @math3d.Vec3::new(0.0, 0.18, 0.0),
    spread_radius: 0.38,
    initial_velocity_min: @math3d.Vec3::new(-0.42, 0.26, -0.42),
    initial_velocity_max: @math3d.Vec3::new(0.42, 0.82, 0.42),
    lifetime_min: 0.16,
    lifetime_max: 0.30,
    size_min: 0.04,
    size_max: 0.08,
    color_start: @math3d.Vec4::new(1.0, 0.76, 0.38, 0.96),
    color_end: @math3d.Vec4::new(0.82, 0.18, 0.06, 0.0),
    gravity: @math3d.Vec3::new(0.0, -1.0, 0.0),
    enabled: true,
  }
}

///|
fn homing_missile_impact_column_track() -> EffectTrack {
  {
    id: "impact_column",
    label: "Impact Column",
    start_time: 0.0,
    duration: 0.28,
    burst_interval: 0.07,
    burst_particles: 14,
    pattern: Column,
    origin: @math3d.Vec3::new(0.0, 0.16, 0.0),
    secondary_origin: @math3d.Vec3::new(0.0, 0.16, 0.0),
    spread_radius: 0.12,
    initial_velocity_min: @math3d.Vec3::new(-0.12, 0.68, -0.12),
    initial_velocity_max: @math3d.Vec3::new(0.12, 1.55, 0.12),
    lifetime_min: 0.16,
    lifetime_max: 0.32,
    size_min: 0.06,
    size_max: 0.12,
    color_start: @math3d.Vec4::new(1.0, 0.94, 0.62, 0.92),
    color_end: @math3d.Vec4::new(0.78, 0.14, 0.04, 0.0),
    gravity: @math3d.Vec3::new(0.0, -2.2, 0.0),
    enabled: true,
  }
}

///|
pub fn homing_missile_impact_effect_document() -> EffectDocument {
  {
    name: "homing_missile_impact",
    duration: 0.52,
    looping: false,
    notes: "Tight impact burst for the homing missile with a hot ring and short flame column.",
    ai_edit_goal: "Keep the impact punchy and readable in under half a second with a bright ring and a short upward plume.",
    tracks: [
      homing_missile_impact_ring_track(),
      homing_missile_impact_column_track(),
    ],
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
fn splitting_fireball_impact_flame_track() -> EffectTrack {
  {
    id: "impact_flame",
    label: "Impact Flame",
    start_time: 0.0,
    duration: 0.24,
    burst_interval: 0.05,
    burst_particles: 14,
    pattern: Column,
    origin: @math3d.Vec3::new(0.0, 0.18, 0.0),
    secondary_origin: @math3d.Vec3::new(0.0, 0.18, 0.0),
    spread_radius: 0.16,
    initial_velocity_min: @math3d.Vec3::new(-0.14, 0.85, -0.14),
    initial_velocity_max: @math3d.Vec3::new(0.14, 1.8, 0.14),
    lifetime_min: 0.20,
    lifetime_max: 0.36,
    size_min: 0.08,
    size_max: 0.14,
    color_start: @math3d.Vec4::new(1.0, 0.86, 0.38, 0.96),
    color_end: @math3d.Vec4::new(0.82, 0.12, 0.02, 0.0),
    gravity: @math3d.Vec3::new(0.0, -2.6, 0.0),
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
fn splitting_fireball_split_spokes_x_track() -> EffectTrack {
  {
    id: "split_spokes_x",
    label: "Split Spokes X",
    start_time: 0.03,
    duration: 0.18,
    burst_interval: 0.036,
    burst_particles: 8,
    pattern: Line,
    origin: @math3d.Vec3::new(-0.56, 0.18, 0.0),
    secondary_origin: @math3d.Vec3::new(0.56, 0.18, 0.0),
    spread_radius: 0.04,
    initial_velocity_min: @math3d.Vec3::new(-0.25, 0.38, -0.08),
    initial_velocity_max: @math3d.Vec3::new(0.25, 0.92, 0.08),
    lifetime_min: 0.16,
    lifetime_max: 0.26,
    size_min: 0.04,
    size_max: 0.08,
    color_start: @math3d.Vec4::new(1.0, 0.76, 0.28, 0.9),
    color_end: @math3d.Vec4::new(0.90, 0.14, 0.04, 0.0),
    gravity: @math3d.Vec3::new(0.0, -1.6, 0.0),
    enabled: true,
  }
}

///|
fn splitting_fireball_split_spokes_z_track() -> EffectTrack {
  {
    id: "split_spokes_z",
    label: "Split Spokes Z",
    start_time: 0.03,
    duration: 0.18,
    burst_interval: 0.036,
    burst_particles: 8,
    pattern: Line,
    origin: @math3d.Vec3::new(0.0, 0.18, -0.56),
    secondary_origin: @math3d.Vec3::new(0.0, 0.18, 0.56),
    spread_radius: 0.04,
    initial_velocity_min: @math3d.Vec3::new(-0.08, 0.38, -0.25),
    initial_velocity_max: @math3d.Vec3::new(0.08, 0.92, 0.25),
    lifetime_min: 0.16,
    lifetime_max: 0.26,
    size_min: 0.04,
    size_max: 0.08,
    color_start: @math3d.Vec4::new(1.0, 0.76, 0.28, 0.9),
    color_end: @math3d.Vec4::new(0.90, 0.14, 0.04, 0.0),
    gravity: @math3d.Vec3::new(0.0, -1.6, 0.0),
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
pub fn splitting_fireball_cast_effect_document() -> EffectDocument {
  {
    name: "splitting_fireball_cast",
    duration: 0.42,
    looping: false,
    notes: "Launch flash with a bright core and a short column of flame.",
    ai_edit_goal: "Keep the cast readable at the player position, with a bright launch flash in the first 0.08s and a short flame wake after it.",
    tracks: [
      {
        id: "cast_core",
        label: "Cast Core",
        start_time: 0.0,
        duration: 0.12,
        burst_interval: 0.04,
        burst_particles: 12,
        pattern: Point,
        origin: @math3d.Vec3::new(0.0, 0.28, 0.0),
        secondary_origin: @math3d.Vec3::new(0.0, 0.28, 0.0),
        spread_radius: 0.0,
        initial_velocity_min: @math3d.Vec3::new(-0.24, 0.62, -0.24),
        initial_velocity_max: @math3d.Vec3::new(0.24, 1.35, 0.24),
        lifetime_min: 0.10,
        lifetime_max: 0.18,
        size_min: 0.07,
        size_max: 0.13,
        color_start: @math3d.Vec4::new(1.0, 0.94, 0.62, 1.0),
        color_end: @math3d.Vec4::new(1.0, 0.38, 0.10, 0.0),
        gravity: @math3d.Vec3::new(0.0, -2.2, 0.0),
        enabled: true,
      },
      {
        id: "cast_flame_column",
        label: "Cast Flame Column",
        start_time: 0.02,
        duration: 0.24,
        burst_interval: 0.06,
        burst_particles: 10,
        pattern: Column,
        origin: @math3d.Vec3::new(0.0, 0.18, 0.0),
        secondary_origin: @math3d.Vec3::new(0.0, 0.18, 0.0),
        spread_radius: 0.12,
        initial_velocity_min: @math3d.Vec3::new(-0.12, 0.48, -0.12),
        initial_velocity_max: @math3d.Vec3::new(0.12, 1.35, 0.12),
        lifetime_min: 0.18,
        lifetime_max: 0.34,
        size_min: 0.05,
        size_max: 0.10,
        color_start: @math3d.Vec4::new(1.0, 0.62, 0.22, 0.82),
        color_end: @math3d.Vec4::new(0.70, 0.12, 0.04, 0.0),
        gravity: @math3d.Vec3::new(0.0, -1.5, 0.0),
        enabled: true,
      },
      {
        id: "cast_ring",
        label: "Cast Ring",
        start_time: 0.0,
        duration: 0.16,
        burst_interval: 0.05,
        burst_particles: 10,
        pattern: Ring,
        origin: @math3d.Vec3::new(0.0, 0.18, 0.0),
        secondary_origin: @math3d.Vec3::new(0.0, 0.18, 0.0),
        spread_radius: 0.28,
        initial_velocity_min: @math3d.Vec3::new(-0.25, 0.18, -0.25),
        initial_velocity_max: @math3d.Vec3::new(0.25, 0.65, 0.25),
        lifetime_min: 0.14,
        lifetime_max: 0.24,
        size_min: 0.03,
        size_max: 0.06,
        color_start: @math3d.Vec4::new(1.0, 0.72, 0.22, 0.84),
        color_end: @math3d.Vec4::new(0.88, 0.18, 0.05, 0.0),
        gravity: @math3d.Vec3::new(0.0, -1.2, 0.0),
        enabled: true,
      },
    ],
  }
}

///|
pub fn splitting_fireball_effect_document() -> EffectDocument {
  {
    name: "splitting_fireball",
    duration: 0.85,
    looping: false,
    notes: "Impact burst for a splitting fireball with hot core, radial split spokes, and rising flames.",
    ai_edit_goal: "Keep the impact bright at 0.0-0.1s and make the split ring plus spokes read clearly by 0.14s.",
    tracks: [
      splitting_fireball_core_track(),
      splitting_fireball_impact_flame_track(),
      splitting_fireball_split_ring_track(),
      splitting_fireball_split_spokes_x_track(),
      splitting_fireball_split_spokes_z_track(),
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
fn ground_telegraph_ring_outline_track() -> EffectTrack {
  {
    id: "telegraph_ring_outline",
    label: "Telegraph Ring Outline",
    start_time: 0.0,
    duration: 0.30,
    burst_interval: 0.05,
    burst_particles: 36,
    pattern: Ring,
    origin: @math3d.Vec3::new(0.0, 0.03, 0.0),
    secondary_origin: @math3d.Vec3::new(0.0, 0.03, 0.0),
    spread_radius: 0.6,
    initial_velocity_min: @math3d.Vec3::new(0.0, 0.0, 0.0),
    initial_velocity_max: @math3d.Vec3::new(0.0, 0.03, 0.0),
    lifetime_min: 0.20,
    lifetime_max: 0.34,
    size_min: 0.045,
    size_max: 0.075,
    color_start: @math3d.Vec4::new(1.0, 0.18, 0.12, 0.92),
    color_end: @math3d.Vec4::new(0.75, 0.05, 0.03, 0.0),
    gravity: @math3d.Vec3::new(0.0, 0.0, 0.0),
    enabled: true,
  }
}

///|
fn ground_telegraph_ring_fill_track() -> EffectTrack {
  {
    id: "telegraph_ring_fill",
    label: "Telegraph Ring Fill",
    start_time: 0.0,
    duration: 0.30,
    burst_interval: 0.08,
    burst_particles: 28,
    pattern: Column,
    origin: @math3d.Vec3::new(0.0, 0.02, 0.0),
    secondary_origin: @math3d.Vec3::new(0.0, 0.02, 0.0),
    spread_radius: 0.48,
    initial_velocity_min: @math3d.Vec3::new(0.0, 0.0, 0.0),
    initial_velocity_max: @math3d.Vec3::new(0.0, 0.02, 0.0),
    lifetime_min: 0.18,
    lifetime_max: 0.28,
    size_min: 0.04,
    size_max: 0.07,
    color_start: @math3d.Vec4::new(1.0, 0.12, 0.08, 0.22),
    color_end: @math3d.Vec4::new(0.58, 0.03, 0.02, 0.0),
    gravity: @math3d.Vec3::new(0.0, 0.0, 0.0),
    enabled: true,
  }
}

///|
pub fn ground_telegraph_ring_effect_document() -> EffectDocument {
  {
    name: "ground_telegraph_ring",
    duration: 0.32,
    looping: false,
    notes: "Short hostile ground telegraph ring with a bright red outline and a faint fill disk.",
    ai_edit_goal: "Keep the ring readable from top-down view and pinned to the floor with a clear red perimeter.",
    tracks: [
      ground_telegraph_ring_outline_track(),
      ground_telegraph_ring_fill_track(),
    ],
  }
}

///|
fn ground_telegraph_line_core_track() -> EffectTrack {
  {
    id: "telegraph_line_core",
    label: "Telegraph Line Core",
    start_time: 0.0,
    duration: 0.26,
    burst_interval: 0.04,
    burst_particles: 28,
    pattern: Line,
    origin: @math3d.Vec3::new(0.0, 0.03, 0.0),
    secondary_origin: @math3d.Vec3::new(1.0, 0.03, 0.0),
    spread_radius: 0.03,
    initial_velocity_min: @math3d.Vec3::new(0.0, 0.0, 0.0),
    initial_velocity_max: @math3d.Vec3::new(0.0, 0.03, 0.0),
    lifetime_min: 0.18,
    lifetime_max: 0.28,
    size_min: 0.04,
    size_max: 0.065,
    color_start: @math3d.Vec4::new(1.0, 0.16, 0.10, 0.90),
    color_end: @math3d.Vec4::new(0.72, 0.04, 0.03, 0.0),
    gravity: @math3d.Vec3::new(0.0, 0.0, 0.0),
    enabled: true,
  }
}

///|
fn ground_telegraph_line_glow_track() -> EffectTrack {
  {
    id: "telegraph_line_glow",
    label: "Telegraph Line Glow",
    start_time: 0.0,
    duration: 0.26,
    burst_interval: 0.06,
    burst_particles: 18,
    pattern: Line,
    origin: @math3d.Vec3::new(0.0, 0.025, 0.0),
    secondary_origin: @math3d.Vec3::new(1.0, 0.025, 0.0),
    spread_radius: 0.08,
    initial_velocity_min: @math3d.Vec3::new(0.0, 0.0, 0.0),
    initial_velocity_max: @math3d.Vec3::new(0.0, 0.02, 0.0),
    lifetime_min: 0.18,
    lifetime_max: 0.30,
    size_min: 0.05,
    size_max: 0.085,
    color_start: @math3d.Vec4::new(1.0, 0.18, 0.12, 0.30),
    color_end: @math3d.Vec4::new(0.62, 0.04, 0.03, 0.0),
    gravity: @math3d.Vec3::new(0.0, 0.0, 0.0),
    enabled: true,
  }
}

///|
pub fn ground_telegraph_line_effect_document() -> EffectDocument {
  {
    name: "ground_telegraph_line",
    duration: 0.28,
    looping: false,
    notes: "Short hostile line telegraph pinned to the floor.",
    ai_edit_goal: "Keep the line bright and floor-hugging so melee and ranged attack paths read clearly from the gameplay camera.",
    tracks: [
      ground_telegraph_line_core_track(),
      ground_telegraph_line_glow_track(),
    ],
  }
}

///|
pub fn effect_preset_document(id : EffectPresetId) -> EffectDocument {
  match id {
    ForgeBurst => default_effect_document()
    ChainLightning => chain_lightning_effect_document()
    HomingMissile => homing_missile_effect_document()
    HomingMissileImpact => homing_missile_impact_effect_document()
    SplittingFireball => splitting_fireball_effect_document()
    IceNova => ice_nova_effect_document()
    GroundTelegraphRing => ground_telegraph_ring_effect_document()
    GroundTelegraphLine => ground_telegraph_line_effect_document()
  }
}
