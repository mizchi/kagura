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
  name : String
  level : Int
  max_level : Int
  cost : Int
  available : Bool
} derive(ToJson)

///|
struct HunterHudView {
  version : Int
  mode : String
  menu : String
  paused : Bool
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
  skills : Array[HunterSkillView]
  inventory : Array[String]
  equipment : Array[String]
  nodes : Array[HunterNodeView]
  offers : Array[String]
} derive(ToJson)

///|
fn hunter_skill_name(id : @game.SkillId) -> String {
  match id {
    PowerStrike => "処刑の一撃"
    Whirlwind => "回転斬り"
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
    "周囲を強く斬る。通常攻撃と待ち時間を共有。", "広い範囲をなぎ払う。通常攻撃と待ち時間を共有。",
    "敵を狙い、命中すると分裂する火の弾。", "自分を中心に冷気を放つ範囲攻撃。",
  ]
  let timers = [
    w.attack_timer,
    w.attack_timer,
    w.splitting_fireball_cooldown_timer,
    w.ice_nova_cooldown_timer,
  ]
  let totals = [
    w.params.attack_cooldown.to_int(),
    w.params.attack_cooldown.to_int() + 5,
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
    mode: match w.mode {
      Title => "title"
      CharacterSelect => "character_select"
      Playing => "playing"
      GameOver => "gameover"
    },
    menu: match w.ui_mode {
      None => "none"
      Inventory => "inventory"
      Skills => "skills"
      LevelUp => "levelup"
    },
    paused: self.paused,
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
    inventory,
    equipment,
    nodes: w.skills.nodes.map(fn(node) {
      {
        name: hunter_skill_name(node.id),
        level: node.level,
        max_level: node.max_level,
        cost: node.cost,
        available: w.skills.skill_points >= node.cost &&
        w.archetype.can_learn_skill(node.id) &&
        w.skills.can_learn_level_up_skill(node.id),
      }
    }),
    offers: w.level_progress.current_offers.map(hunter_skill_name),
  }
}
