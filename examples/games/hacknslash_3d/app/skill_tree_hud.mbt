///|
fn hunter_skill_branch(id : @game.SkillId) -> Int {
  match id {
    PowerStrike
    | Whirlwind
    | CriticalHit
    | PhysicalMastery
    | AoEMastery
    | Counter => 0
    Vitality | DashMastery | LifeSteal => 1
    _ => 2
  }
}

///|
fn hunter_skill_description(id : @game.SkillId) -> String {
  match id {
    PowerStrike =>
      "周囲を強く斬る技。筋力と通常攻撃も高める。物理キー1で発動。"
    Whirlwind =>
      "大きく回転し、周囲の群れをなぎ払う。物理キー2で発動。"
    CriticalHit =>
      "敵の隙を見抜き、すべての攻撃の会心率を高める。"
    Counter =>
      "短時間、無敵の構えを取り、敵の弾を反射する。物理キー8で発動。"
    DashMastery =>
      "回避を素早く繰り返せるようにし、技量も高める。"
    Vitality => "最大体力を高め、激しい戦闘を生き延びる。"
    LifeSteal =>
      "攻撃で与えたダメージの一部を体力として奪う。急所狙いと生命力が必要。"
    SplittingFireball =>
      "腕を振って火弾を放つ。敵や壁への接触で円内に爆発し、3方向へ分裂。白い閃光と命中数がヒットの目印。物理キー3で発動。"
    IceNova =>
      "自分を中心に冷気の輪を広げる。物理キー4で発動。"
    ChainLightning =>
      "腕を突き出し、見通せる敵を次々につなぐ雷撃。白い雷の芯と敵の発光が命中の目印。物理キー5で発動。"
    HomingMissile =>
      "敵へ向かって軌道を変える呪弾。物理キー6で発動。"
    PhysicalMastery =>
      "物理の技を磨く。処刑の一撃・回転斬りなどを強化。"
    AoEMastery =>
      "範囲攻撃の威力と会心率、効果半径を広げる。"
    LightningMastery => "雷の技の威力と会心率を高める。"
    FireMastery => "炎の技の威力と会心率を高める。"
    ColdMastery => "冷気の技の威力と会心率を高める。"
    ProjectileMastery => "投射する技の威力と会心率を高める。"
  }
}

///|
fn hunter_skill_effect(id : @game.SkillId, level : Int) -> String {
  match id {
    Vitality => "最大体力 +" + (level * 3).to_string()
    DashMastery =>
      "回避待ち時間 " +
      hunter_frames_seconds(40 - level * 8) +
      " / 技量 +" +
      level.to_string()
    CriticalHit => "会心率 +" + (level * 10).to_string() + "%"
    LifeSteal => "与ダメージの " + (level * 5).to_string() + "% を吸収"
    Counter =>
      if level == 0 {
        "未習得"
      } else {
        "無敵・反射 2秒 / 再使用 " +
        hunter_frames_seconds(@game.counter_cooldown_for_level(level))
      }
    PhysicalMastery
    | LightningMastery
    | FireMastery
    | ColdMastery
    | ProjectileMastery =>
      "対象の技: 威力 +" +
      (level * 8).to_string() +
      "% / 会心 +" +
      (level * 2).to_string() +
      "%"
    AoEMastery =>
      "範囲の技: 威力 +" +
      (level * 8).to_string() +
      "% / 会心 +" +
      (level * 2).to_string() +
      "% / 半径 +" +
      (level * 10).to_string() +
      "%"
    _ =>
      if level == 0 {
        "未習得"
      } else {
        "技の威力 " +
        (@game.skill_level_damage_multiplier(id, level) * 100.0)
        .to_int()
        .to_string() +
        "%" +
        (if id == @game.PowerStrike {
          " / 筋力 +" + level.to_string()
        } else {
          ""
        })
      }
  }
}

///|
fn GameState::hunter_extra_skills(
  self : GameState,
) -> Array[HunterExtraSkillView] {
  let w = self.world
  let skills : Array[HunterExtraSkillView] = []
  for
    entry in [
      (
        @game.ChainLightning,
        53,
        w.chain_lightning_cooldown_timer,
        w.params.chain_lightning_cooldown_frames(),
      ),
      (
        @game.HomingMissile,
        54,
        w.homing_missile_cooldown_timer,
        w.params.homing_missile_cooldown_frames(),
      ),
      (
        @game.Counter,
        56,
        w.player.counter_cooldown_timer,
        @game.counter_cooldown_for_level(w.skills.get_level(@game.Counter)),
      ),
    ] {
    let (id, key, remaining, total) = entry
    if w.skills.get_level(id) > 0 {
      skills.push({
        key,
        name: hunter_skill_name(id),
        glyph: hunter_skill_glyph(id),
        remaining,
        total,
      })
    }
  }
  skills
}

///|
fn hunter_frames_seconds(frames : Int) -> String {
  let hundredths = frames % 60 * 100 / 60
  (frames / 60).to_string() +
  "." +
  (if hundredths < 10 { "0" } else { "" }) +
  hundredths.to_string() +
  "秒"
}

///|
fn hunter_skill_glyph(id : @game.SkillId) -> String {
  match id {
    PowerStrike | PhysicalMastery => "blade"
    Whirlwind | AoEMastery => "whirl"
    CriticalHit => "eye"
    Vitality => "heart"
    DashMastery => "dodge"
    LifeSteal => "blood"
    Counter => "shield"
    ChainLightning | LightningMastery => "lightning"
    SplittingFireball | FireMastery => "fire"
    IceNova | ColdMastery => "frost"
    HomingMissile | ProjectileMastery => "bow"
  }
}

///|
fn GameState::hunter_tree_nodes(self : GameState) -> Array[HunterNodeView] {
  let w = self.world
  let nodes : Array[HunterNodeView] = []
  for index, node in w.skills.nodes {
    let branch = hunter_skill_branch(node.id)
    let status = if node.level >= node.max_level {
      "maxed"
    } else if !w.skill_allowed(node.id) {
      "class"
    } else if node.prereqs.any(id => w.skills.get_level(id) == 0) {
      "prerequisite"
    } else if w.skills.skill_points < node.cost {
      "points"
    } else {
      "available"
    }
    nodes.push({
      id: @game.skill_id_to_int(node.id),
      index,
      branch,
      x: node.tree_x * 3.0 - branch.to_double(),
      y: node.tree_y,
      prereqs: node.prereqs.map(@game.skill_id_to_int),
      name: hunter_skill_name(node.id),
      description: hunter_skill_description(node.id),
      effect: hunter_skill_effect(node.id, node.level),
      next_effect: hunter_skill_effect(
        node.id,
        (node.level + 1).min(node.max_level),
      ),
      glyph: hunter_skill_glyph(node.id),
      kind: match node.id {
        PowerStrike
        | Whirlwind
        | Counter
        | ChainLightning
        | SplittingFireball
        | IceNova
        | HomingMissile => "発動技"
        _ => "常時効果"
      },
      status,
      level: node.level,
      max_level: node.max_level,
      cost: node.cost,
      available: status == "available",
    })
  }
  nodes
}
