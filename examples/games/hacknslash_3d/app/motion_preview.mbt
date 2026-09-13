///|
/// Deterministic authoring fixture: ?snapshot=motions&frames=0..48. Uses the
/// actual game rig, materials and rendering path. P resumes normal combat.
fn apply_enemy_motion_preview(state : GameState, frame : Int) -> Unit {
  state.world.mode = @game.Playing
  state.world.enemies.clear()
  state.world.projectiles.clear()
  let px = state.world.player.x
  let py = state.world.player.y
  let roles = [
    (@game.Basic, @game.Punch),
    (@game.Fast, @game.SpearThrust),
    (@game.Caster, @game.CastSpell),
  ]
  for i in 0..<roles.length() {
    let (kind, motion) = roles[i]
    let x = px + (i - 1).to_double() * tile_size * 1.8
    let y = py - tile_size * 2.5
    let enemy = @game.make_enemy(x, y, kind, 100, 0.0, 10.0)
    enemy.begin_attack(motion, 24, 24, x, y + 100.0)
    enemy.attack_frame = frame.max(0).min(48)
    state.world.enemies.push(enemy)
  }
  state.camera = state.camera
    .with_distance(9.5)
    .orbit(-state.camera.yaw, 0.85 - state.camera.pitch)
    .with_target(@math3d.Vec3::new(px / tile_size, 0.45, py / tile_size - 1.8))
  state.motion_preview = true
}

///|
/// Bow authoring fixture: ?snapshot=bow&frames=0..48, release at frame 24.
fn apply_bow_motion_preview(state : GameState, frame : Int) -> Unit {
  apply_enemy_motion_preview(state, frame)
  state.world.enemies.clear()
  let x = state.world.player.x
  let y = state.world.player.y - tile_size * 2.5
  let archer = @game.make_enemy(x, y, @game.Ranged, 100, 0.0, 10.0)
  archer.begin_attack(@game.BowShot, 24, 24, x, y + 100.0)
  archer.attack_frame = frame.max(0).min(48)
  state.world.enemies.push(archer)
  if frame >= 24 {
    state.world.projectiles.push({
      x,
      y: y + (frame - 24).to_double() * 3.0,
      vx: 0.0,
      vy: 3.0,
      age: frame - 24,
      alive: true,
      damage: 1,
      is_player: false,
      kind: @game.Arrow,
    })
  }
  state.camera = state.camera.with_distance(6.0).orbit(0.6, -0.15)
}

///|
/// Player authoring fixture: ?snapshot=hunter&weapon=bow&frames=29.
fn apply_hunter_motion_preview(
  state : GameState,
  kind : @game.PlayerWeaponKind,
  frame : Int,
  combo? : @game.CleaverComboStep = @game.Opening,
) -> Unit {
  state.world.mode = @game.Playing
  state.world.enemies.clear()
  state.world.projectiles.clear()
  let _ = state.world.equip_player_weapon(kind)
  state.character.equip_weapon(kind)
  state.world.cleaver_next = combo
  let _ = state.world.request_basic_attack(@math.PI / 2.0)
  state.character.trigger_attack(combo~)
  let profile = state.world.weapon_attack.unwrap().profile()
  let count = frame.max(0).min(profile.windup + profile.recovery)
  for _ in 0..<count {
    state.world.tick_player_weapon_attack()
  }
  state.character.update(count.to_double() / 60.0)
  let _ = state.world.drain_events()
  let x = state.world.player.x / tile_size
  let z = state.world.player.y / tile_size
  state.camera = state.camera
    .with_distance(4.5)
    .orbit(0.65 - state.camera.yaw, 0.6 - state.camera.pitch)
    .with_target(@math3d.Vec3::new(x, 0.48, z))
  state.motion_preview = true
}

///|
/// Side-by-side in-engine authoring view: ?snapshot=charge&frames=0..42.
fn apply_charge_motion_preview(state : GameState, frame : Int) -> Unit {
  state.world.mode = @game.Playing
  state.world.enemies.clear()
  state.world.projectiles.clear()
  let _ = state.world.equip_player_weapon(@game.Spear)
  state.character.equip_weapon(@game.Spear)
  let _ = state.world.request_charge(@math.PI / 2.0)
  let frame = frame.max(0).min(@game.player_charge_profile.duration())
  state.world.player_charge.unwrap().frame = frame
  state.character.anim_state = Charging
  state.character.action_time = frame.to_double() / 60.0
  state.character.skinning_cache_dirty = true
  let x = state.world.player.x
  let y = state.world.player.y
  let enemy = @game.make_enemy(
    x - tile_size * 1.8,
    y,
    @game.Fast,
    100,
    0.0,
    8.0,
  )
  enemy.begin_attack(
    @game.Charge,
    @game.enemy_charge_profile.windup,
    @game.enemy_charge_profile.active + @game.enemy_charge_profile.recovery,
    enemy.x,
    y + 1000.0,
  )
  enemy.attack_frame = frame.min(@game.enemy_charge_profile.duration())
  state.world.enemies.push(enemy)
  state.camera = state.camera
    .with_distance(6.0)
    .orbit(-state.camera.yaw + 0.15, 0.6 - state.camera.pitch)
    .with_target(@math3d.Vec3::new(x / tile_size - 0.9, 0.45, y / tile_size))
  state.motion_preview = true
}

///|
/// Static authoring fixture uses the exact equipment path, with inventory enabled.
fn apply_character_wardrobe_preview(state : GameState, outfit : String) -> Unit {
  state.world.mode = @game.Playing
  state.world.enemies.clear()
  state.world.projectiles.clear()
  state.world.equipment.clear()
  let rarity = match outfit {
    "none" => None
    "leather" => Some(@game.Uncommon)
    "plate" => Some(@game.Rare)
    "occult" => Some(@game.Epic)
    _ => Some(@game.Common)
  }
  if rarity is Some(rarity) {
    for
      slot in [
        @game.Armor,
        @game.Helmet,
        @game.Gloves,
        @game.Boots,
        @game.Accessory,
        @game.Amulet,
        @game.Offhand,
      ] {
      ignore(
        state.world.equipment.equip(@game.hunter_equipment_item(slot, rarity~)),
      )
    }
  }
  state.sync_character_equipment()
  let x = state.world.player.x / tile_size
  let z = state.world.player.y / tile_size
  state.world.player.facing_angle = @math.PI / 2.0
  state.camera = state.camera
    .with_distance(3.6)
    .orbit(0.4 - state.camera.yaw, 0.40 - state.camera.pitch)
    .with_target(@math3d.Vec3::new(x, 0.65, z))
  state.motion_preview = true
}

///|
/// ?snapshot=wolf&motion=walk|run|bite&frames=N; static authoring pose.
fn apply_wolf_motion_preview(
  state : GameState,
  motion : String,
  frame : Int,
) -> Unit {
  state.world.mode = @game.Playing
  state.world.enemies.clear()
  state.world.projectiles.clear()
  let x = state.world.player.x
  let y = state.world.player.y - tile_size * 2.5
  let wolf = @game.make_enemy(x, y, @game.Wolf, 100, 1.0, 11.0)
  wolf.move_angle = @math.PI / 2.0
  if motion == "bite" {
    let profile = @game.Bite.melee_profile().unwrap()
    wolf.begin_attack(
      @game.Bite,
      profile.windup,
      profile.recovery,
      x,
      y + 100.0,
    )
    wolf.attack_frame = frame.max(0).min(profile.windup + profile.recovery)
  } else {
    let running = motion == "run"
    wolf.move_speed = if running { 1.0 } else { 0.3 }
    wolf.travel_distance = frame.max(0).to_double() /
      (if running { 30.0 } else { 54.0 }) *
      (if running { 28.0 } else { 16.0 })
  }
  state.world.enemies.push(wolf)
  state.camera = state.camera
    .with_distance(4.8)
    .orbit(0.9 - state.camera.yaw, 0.5 - state.camera.pitch)
    .with_target(@math3d.Vec3::new(x / tile_size, 0.45, y / tile_size))
  state.motion_preview = true
}
