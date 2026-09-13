// Read-only view models shared by the browser HUD and contract tests.

///|
struct HunterSkillView {
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
  skills : Array[HunterSkillView]
  extra_skills : Array[HunterExtraSkillView]
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
    PowerStrike => "処刑の一撃"
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
  }
}

///|
fn GameState::hunter_hud_view(self : GameState) -> HunterHudView {
  let w = self.world
  let skills : Array[HunterSkillView] = []
  let ids = [
    @game.PowerStrike,
    @game.Whirlwind,
    @game.SplittingFireball,
    @game.IceNova,
  ]
  let descriptions = [
    "周囲を強く斬る。通常攻撃と待ち時間を共有。", "2／ボタンを長押しして回転しながら移動。全武器対応、離すと停止。",
    "前方の敵を緩く追う火弾。命中後に分裂した弾も追尾する。",
    "自分を中心に冷気を放つ範囲攻撃。",
  ]
  let timers = [
    w.attack_timer,
    w.attack_timer,
    w.splitting_fireball_cooldown_timer,
    w.ice_nova_cooldown_timer,
  ]
  let totals = [
    w.params.attack_cooldown.to_int(),
    @game.whirlwind_recovery_frames,
    w.params.splitting_fireball_cooldown_frames(),
    w.params.ice_nova_cooldown_frames(),
  ]
  for i in 0..<ids.length() {
    skills.push({
      name: hunter_skill_name(ids[i]),
      description: descriptions[i],
      level: w.skills.get_level(ids[i]),
      remaining: @cmp.maximum(0, timers[i]),
      total: totals[i],
    })
  }
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
    arts: self.hunter_arts_view(),
    weapon: w.player_weapon.profile().name,
    weapon_index: w.player_weapon.index(),
    weapon_action: w.player_weapon.profile().action,
    attack_remaining: w.attack_timer.max(0),
    weapon_locked: w.hunter_action_locked() ||
    w.weapon_attack is Some(_) ||
    w.player.dash_timer > 0 ||
    w.player_charge is Some(_),
    charging: w.player_charge is Some(_),
    charge_frame: match w.player_charge {
      Some(charge) => charge.frame
      None => -1
    },
    charge: {
      name: "突進",
      description: "構えてから前方へ突進。壁で止まり、敵ごとに一度だけダメージ。移動方向、停止中は近くの敵へ向かう。回避で中断。",
      level: 1,
      remaining: w.charge_cooldown,
      total: @game.player_charge_cooldown,
    },
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
    cursor: if w.mode == @game.CharacterSelect {
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
