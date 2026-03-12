///|
fn game_to_effect_world_position(
  x : Double,
  y : Double,
  height : Double,
) -> @math3d.Vec3 {
  @math3d.Vec3::new(x / tile_size, height, y / tile_size)
}

///|
fn queue_active_effect(
  state : GameState,
  label : String,
  doc : @effect.EffectDocument,
  placement : @effect.EffectPlacement,
) -> Unit {
  state.active_effects.push({ label, doc, placement, elapsed: 0.0 })
}

///|
fn chain_lightning_effect_placement(
  start_x : Double,
  start_y : Double,
  end_x : Double,
  end_y : Double,
) -> @effect.EffectPlacement {
  @effect.new_effect_placement(
    game_to_effect_world_position(start_x, start_y, 0.45),
    Some(game_to_effect_world_position(end_x, end_y, 0.45)),
    1.0,
  )
}

///|
fn fireball_burst_effect_placement(
  x : Double,
  y : Double,
  scale : Double,
) -> @effect.EffectPlacement {
  @effect.new_effect_placement(
    game_to_effect_world_position(x, y, 0.35),
    None,
    scale,
  )
}

///|
fn ice_nova_effect_placement(
  x : Double,
  y : Double,
  radius : Double,
) -> @effect.EffectPlacement {
  @effect.new_effect_placement(
    game_to_effect_world_position(x, y, 0.18),
    None,
    @cmp.maximum(1.0, radius / tile_size),
  )
}

///|
fn GameState::queue_chain_lightning_effect(
  self : GameState,
  start_x : Double,
  start_y : Double,
  end_x : Double,
  end_y : Double,
) -> Unit {
  queue_active_effect(
    self,
    "chain_lightning",
    @effect.chain_lightning_effect_document(),
    chain_lightning_effect_placement(start_x, start_y, end_x, end_y),
  )
}

///|
fn GameState::queue_fireball_burst_effect(
  self : GameState,
  x : Double,
  y : Double,
) -> Unit {
  queue_active_effect(
    self,
    "splitting_fireball",
    @effect.splitting_fireball_effect_document(),
    fireball_burst_effect_placement(x, y, 1.2),
  )
}

///|
fn GameState::queue_fireball_cast_effect(
  self : GameState,
  x : Double,
  y : Double,
) -> Unit {
  queue_active_effect(
    self,
    "splitting_fireball_cast",
    @effect.splitting_fireball_cast_effect_document(),
    fireball_burst_effect_placement(x, y, 0.9),
  )
}

///|
fn GameState::queue_ice_nova_effect(
  self : GameState,
  x : Double,
  y : Double,
  radius : Double,
) -> Unit {
  queue_active_effect(
    self,
    "ice_nova",
    @effect.ice_nova_effect_document(),
    ice_nova_effect_placement(x, y, radius),
  )
}

///|
fn GameState::update_active_effects(self : GameState, dt : Double) -> Unit {
  for active_effect in self.active_effects {
    let next_elapsed = active_effect.elapsed + dt
    let bursts = @effect.build_effect_runtime_window(
      active_effect.doc,
      active_effect.elapsed,
      next_elapsed,
      active_effect.placement,
    )
    for burst in bursts {
      self.particle_manager.spawn(burst.config)
    }
    active_effect.elapsed = next_elapsed
  }
  let still_active : Array[ActiveEffectInstance] = []
  for active_effect in self.active_effects {
    if active_effect.elapsed <= active_effect.doc.duration + 0.000001 {
      still_active.push(active_effect)
    }
  }
  self.active_effects = still_active
}
