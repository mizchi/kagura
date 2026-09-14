// Read-only view models shared by the browser HUD and contract tests.

///|
struct HunterSkillView {
  key : Int
  glyph : String
  hold : String
  name : String
  description : String
  level : Int
  remaining : Int
  total : Int
} derive(ToJson)

///|
struct HunterNodeView {
  id : Int
  index : Int
  branch : Int
  x : Double
  y : Double
  prereqs : Array[Int]
  description : String
  effect : String
  next_effect : String
  glyph : String
  kind : String
  status : String
  name : String
  level : Int
  max_level : Int
  cost : Int
  available : Bool
} derive(ToJson)

///|
struct HunterExtraSkillView {
  key : Int
  name : String
  glyph : String
  remaining : Int
  total : Int
} derive(ToJson)

///|
struct HunterHudView {
  builds : Array[StartingBuildView]
  preset : Int
  preset_name : String
  presets : Array[String]
  save_slots : Array[SaveSlotView]
  active_save_slot : Int
  save_notice : String
  save_delete_slot : Int
  respawn_region : String
  terrain : TerrainLabView
  camera : HunterCameraView
  exploration : HunterExplorationView
  combat : HunterCombatView
  loot : Array[HunterLootView]
  version : Int
  mode : String
  menu : String
  paused : Bool
  muted : Bool
  cursor : Int
  hp : Int
  max_hp : Int
  level : Int
  xp : Int
  next_xp : Int
  floor : Int
  score : Int
  remaining : Int
  map_x : Double
  map_z : Double
  dodge : Int
  dodge_total : Int
  charge : HunterSkillView
  charging : Bool
  charge_frame : Int
  slot_options : Array[HunterSkillView]
  skills : Array[HunterSkillView]
  extra_skills : Array[HunterExtraSkillView]
  summons : HunterSummonsView
  arts : HunterArtsView
  atlas : HunterAtlasView?
  inventory_grid : HunterInventoryView?
  inventory : Array[String]
  equipment : Array[String]
  nodes : Array[HunterNodeView]
  skill_points : Int
  offers : Array[String]
  weapon : String
  weapon_index : Int
  weapon_action : String
  attack_remaining : Int
  weapon_locked : Bool
  weapons : Array[String]
} derive(ToJson)

///|
fn hunter_skill_name(id : @game.SkillId) -> String {
  match id {
    PowerStrike => "武器鍛錬"
    Whirlwind => "ワールウィンド"
    SplittingFireball => "分裂火弾"
    IceNova => "霜の輪"
    ChainLightning => "連鎖雷撃"
    HomingMissile => "追尾の呪弾"
    DashMastery => "回避の心得"
    Vitality => "生命力"
    CriticalHit => "急所狙い"
    LifeSteal => "吸血"
    Counter => "反撃の構え"
    LightningMastery => "雷の熟練"
    FireMastery => "炎の熟練"
    ColdMastery => "氷の熟練"
    PhysicalMastery => "刃の熟練"
    ProjectileMastery => "弾の熟練"
    AoEMastery => "範囲の熟練"
    RaiseZombie => "ゾンビ召喚"
    SummonFlamingSkull => "炎の頭蓋"
  }
}

///|
fn GameState::hunter_hud_view(self : GameState) -> HunterHudView {
  let w = self.world
  let skills = self.hunter_preset_skills()
  let inventory = w.inventory.items.map(fn(item) {
    match item {
      Some(item) =>
        item.display_name() +
        " / ATK " +
        item.total_atk().to_string() +
        " / DEF " +
        item.total_def().to_string()
      None => "空きスロット"
    }
  })
  let equipment = [w.equipment.weapon, w.equipment.armor, w.equipment.accessory].map(fn(
      item,
    ) {
      match item {
        Some(item) => item.display_name()
        None => "未装備"
      }
    },
  )
  let mut remaining = 0
  for enemy in w.enemies {
    if enemy.alive {
      remaining += 1
    }
  }
  {
    version: 1,
    builds: if w.mode == @game.CharacterSelect {
      self.starting_build_views()
    } else {
      []
    },
    slot_options: if w.ui_mode == @game.Skills {
      @game.hunter_slot_actions.map(key => self.hunter_action_view(key))
    } else {
      []
    },
    camera: self.hunter_camera_view(),
    preset: w.hunter_preset.index(),
    preset_name: w.hunter_preset.profile().name,
    presets: @game.hunter_presets.map(p => p.name),
    save_slots: self.save_slots,
    active_save_slot: self.active_save_slot,
    save_notice: self.save_notice,
    save_delete_slot: match self.pending_save_deletion {
      Some(pending) => pending.slot
      None => -1
    },
    respawn_region: self.world.atlas
    .map(a => @game.world_regions[a.last_waypoint].name)
    .or("入口"),
    terrain: self.terrain_lab_view(),
    arts: self.hunter_arts_view(),
    summons: self.hunter_summons_view(),
    combat: self.hunter_combat_view(),
    loot: self.hunter_loot_view(),
    exploration: self.hunter_exploration_view(),
    weapon: w.player_weapon.profile().name,
    weapon_index: w.player_weapon.index(),
    weapon_action: w.player_weapon.profile().action,
    attack_remaining: w.attack_timer.max(0),
    weapon_locked: w.hunter_action_locked() ||
    w.weapon_attack is Some(_) ||
    w.player.dash_timer > 0 ||
    w.player_charge is Some(_),
    charging: w.arts.action is Some({ kind: @game.DashArt, .. }),
    charge_frame: match w.arts.action {
      Some({ kind: @game.DashArt, frame, .. }) => frame
      _ => -1
    },
    charge: self.hunter_action_view(86),
    weapons: [
      @game.Cleaver,
      @game.Spear,
      @game.Knuckles,
      @game.Focus,
      @game.Bow,
    ].map(kind => kind.profile().name),
    mode: match w.mode {
      Title => "title"
      CharacterSelect => "character_select"
      Playing => "playing"
      GameOver => "gameover"
    },
    menu: match w.ui_mode {
      None => "none"
      Waypoints => "waypoints"
      Inventory => "inventory"
      Skills => "skills"
      LevelUp => "levelup"
    },
    paused: self.paused,
    muted: self.audio_bank.is_muted(),
    cursor: if w.mode == @game.CharacterSelect || w.mode == @game.Title {
      w.select_cursor
    } else {
      w.ui_cursor
    },
    hp: w.player.hp,
    max_hp: w.player_stats.max_hp,
    level: w.level_progress.level,
    xp: w.level_progress.xp,
    next_xp: w.level_progress.next_level_xp,
    floor: w.floor,
    score: w.score,
    remaining,
    map_x: w.player.x / tile_size,
    map_z: w.player.y / tile_size,
    dodge: w.player.dash_cooldown_timer,
    dodge_total: w.player_stats.dash_cooldown,
    skills,
    extra_skills: self.hunter_extra_skills(),
    atlas: self.hunter_atlas_view(),
    inventory_grid: self.hunter_inventory_view(),
    inventory,
    equipment,
    nodes: self.hunter_tree_nodes(),
    skill_points: w.skills.skill_points,
    offers: w.level_progress.current_offers.map(hunter_skill_name),
  }
}
