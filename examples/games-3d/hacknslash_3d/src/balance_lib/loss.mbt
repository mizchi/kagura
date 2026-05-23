// Loss functions for game balance optimization
// Each hypothesis targets a different player experience

///|
pub(all) struct BalanceTargets {
  target_survival_frames : Double
  target_floors : Double
  target_floor_time : Double
  target_hp_cv : Double
  // Extended targets
  target_kill_interval : Double // frames between kills
  target_kill_interval_cv : Double // kill pacing variance
  target_near_death_rate : Double // fraction of time near death
  target_kills_per_floor : Double
  target_damage_interval : Double // frames between getting hit
  target_total_damage : Double // total hits taken in a run
  target_equip_upgrades : Double // build spikes from item updates
  target_learned_skill_count : Double // breadth of learned skills
  // Weights (control which objectives matter most)
  w_survival : Double
  w_floor : Double
  w_floor_time : Double
  w_hp_cv : Double
  w_kill_interval : Double
  w_kill_cv : Double
  w_near_death : Double
  w_kills_per_floor : Double
  w_damage_interval : Double
  w_total_damage : Double
  w_equip_upgrades : Double
  w_learned_skill_count : Double
}

///|
pub(all) struct BalanceHypothesis {
  name : String
  targets : BalanceTargets
}

// ==========================================
// Hypothesis A: "Action-dense" (アクション重視)
// 目標: 戦闘密度が高く、テンポよく敵を倒し続ける爽快感
// - 短いキル間隔、適度なHP変動、速いフロアクリア
// ==========================================

///|
pub fn BalanceTargets::action_dense() -> BalanceTargets {
  {
    target_survival_frames: 9000.0,
    target_floors: 10.0, // 多くのフロアをクリア
    target_floor_time: 400.0, // 速い (~7秒/フロア)
    target_hp_cv: 0.25, // 低めの変動 = 安定感
    target_kill_interval: 60.0, // 1秒に1キル
    target_kill_interval_cv: 0.5, // 適度なリズム変化
    target_near_death_rate: 0.05, // ほぼ瀕死にならない
    target_kills_per_floor: 15.0, // 1フロアに多くの敵
    target_damage_interval: 600.0, // あまりダメージ受けない
    target_total_damage: 5.0,
    target_equip_upgrades: 3.0,
    target_learned_skill_count: 3.0,
    w_survival: 0.5,
    w_floor: 1.0,
    w_floor_time: 1.5, // フロアタイム重視
    w_hp_cv: 0.3,
    w_kill_interval: 1.5, // キル頻度重視
    w_kill_cv: 0.3,
    w_near_death: 0.5,
    w_kills_per_floor: 1.0,
    w_damage_interval: 0.3,
    w_total_damage: 0.4,
    w_equip_upgrades: 0.4,
    w_learned_skill_count: 0.2,
  }
}

// ==========================================
// Hypothesis B: "Survival horror" (サバイバル重視)
// 目標: 常に緊張感があり、リソース管理が重要
// - HP変動が大きい、頻繁に瀕死、短い生存時間
// ==========================================

///|
pub fn BalanceTargets::survival_horror() -> BalanceTargets {
  {
    target_survival_frames: 5400.0, // 1.5分で死ぬ
    target_floors: 4.0, // 少ないフロアで死ぬ
    target_floor_time: 800.0, // 各フロアは長め
    target_hp_cv: 0.6, // 高い変動 = 緊張感
    target_kill_interval: 120.0, // キルは慎重
    target_kill_interval_cv: 0.8, // 大きなリズム変化
    target_near_death_rate: 0.2, // 20%の時間が瀕死
    target_kills_per_floor: 8.0,
    target_damage_interval: 200.0, // 頻繁にダメージ
    target_total_damage: 24.0,
    target_equip_upgrades: 2.0,
    target_learned_skill_count: 2.0,
    w_survival: 1.5, // 生存時間を厳密に制御
    w_floor: 1.0,
    w_floor_time: 0.5,
    w_hp_cv: 2.0, // HP変動を最重視
    w_kill_interval: 0.3,
    w_kill_cv: 0.5,
    w_near_death: 2.0, // 瀕死率を最重視
    w_kills_per_floor: 0.3,
    w_damage_interval: 1.0,
    w_total_damage: 1.0,
    w_equip_upgrades: 0.2,
    w_learned_skill_count: 0.2,
  }
}

// ==========================================
// Hypothesis C: "Speedrun-optimized" (スピードラン向け)
// 目標: 熟練プレイヤーが素早く攻略できる
// - 非常に速いフロアクリア、高キルレート、装備更新頻度高
// ==========================================

///|
pub fn BalanceTargets::speedrun() -> BalanceTargets {
  {
    target_survival_frames: 9000.0,
    target_floors: 15.0, // 大量のフロアクリア
    target_floor_time: 300.0, // 超高速 (5秒/フロア)
    target_hp_cv: 0.3,
    target_kill_interval: 40.0, // 超高キルレート
    target_kill_interval_cv: 0.3, // 均一なペース
    target_near_death_rate: 0.02,
    target_kills_per_floor: 10.0,
    target_damage_interval: 900.0,
    target_total_damage: 2.0,
    target_equip_upgrades: 4.0,
    target_learned_skill_count: 3.0,
    w_survival: 0.3,
    w_floor: 2.0, // フロア数を最重視
    w_floor_time: 2.0, // フロアタイムを最重視
    w_hp_cv: 0.2,
    w_kill_interval: 1.0,
    w_kill_cv: 0.5,
    w_near_death: 0.3,
    w_kills_per_floor: 0.5,
    w_damage_interval: 0.2,
    w_total_damage: 0.2,
    w_equip_upgrades: 0.5,
    w_learned_skill_count: 0.2,
  }
}

// ==========================================
// Hypothesis D: "Risk-reward" (リスク・リワード)
// 目標: 死と隣り合わせだが報酬が大きい
// - 高い瀕死率だが生存、適度なフロア進行、高スコア
// ==========================================

///|
pub fn BalanceTargets::risk_reward() -> BalanceTargets {
  {
    target_survival_frames: 7200.0, // 2分
    target_floors: 6.0,
    target_floor_time: 600.0,
    target_hp_cv: 0.5, // 高めの変動
    target_kill_interval: 80.0,
    target_kill_interval_cv: 1.0, // 大きなリズム変化（群れ→静寂）
    target_near_death_rate: 0.15, // 15%瀕死
    target_kills_per_floor: 12.0,
    target_damage_interval: 300.0, // 頻繁にダメージ
    target_total_damage: 18.0,
    target_equip_upgrades: 4.0,
    target_learned_skill_count: 3.0,
    w_survival: 1.0,
    w_floor: 0.8,
    w_floor_time: 0.5,
    w_hp_cv: 1.5,
    w_kill_interval: 0.5,
    w_kill_cv: 1.5, // キルリズム変化を重視
    w_near_death: 1.5, // 瀕死率を重視
    w_kills_per_floor: 0.8,
    w_damage_interval: 1.0,
    w_total_damage: 1.2,
    w_equip_upgrades: 0.6,
    w_learned_skill_count: 0.4,
  }
}

// ==========================================
// Default (balanced)
// ==========================================

///|
pub fn BalanceTargets::default() -> BalanceTargets {
  {
    target_survival_frames: 9000.0,
    target_floors: 6.0,
    target_floor_time: 600.0,
    target_hp_cv: 0.35,
    target_kill_interval: 90.0,
    target_kill_interval_cv: 0.6,
    target_near_death_rate: 0.08,
    target_kills_per_floor: 12.0,
    target_damage_interval: 400.0,
    target_total_damage: 10.0,
    target_equip_upgrades: 3.0,
    target_learned_skill_count: 3.0,
    w_survival: 1.0,
    w_floor: 1.0,
    w_floor_time: 0.5,
    w_hp_cv: 0.5,
    w_kill_interval: 0.5,
    w_kill_cv: 0.3,
    w_near_death: 0.5,
    w_kills_per_floor: 0.3,
    w_damage_interval: 0.3,
    w_total_damage: 0.4,
    w_equip_upgrades: 0.4,
    w_learned_skill_count: 0.3,
  }
}

// ==========================================
// Current autoplay rebalance target
// 目標: いまの build で強すぎる autoplay を抑え、
//       4-5 floor 前後で適度に被弾しつつ進む状態へ寄せる
// ==========================================

///|
pub fn BalanceTargets::autoplay_rebalance() -> BalanceTargets {
  {
    target_survival_frames: 7200.0,
    target_floors: 4.5,
    target_floor_time: 1500.0,
    target_hp_cv: 0.38,
    target_kill_interval: 90.0,
    target_kill_interval_cv: 0.9,
    target_near_death_rate: 0.08,
    target_kills_per_floor: 24.0,
    target_damage_interval: 220.0,
    target_total_damage: 12.0,
    target_equip_upgrades: 4.0,
    target_learned_skill_count: 3.5,
    w_survival: 1.8,
    w_floor: 0.8,
    w_floor_time: 0.7,
    w_hp_cv: 1.4,
    w_kill_interval: 0.7,
    w_kill_cv: 0.4,
    w_near_death: 1.7,
    w_kills_per_floor: 1.0,
    w_damage_interval: 1.5,
    w_total_damage: 2.0,
    w_equip_upgrades: 1.0,
    w_learned_skill_count: 0.6,
  }
}

// ==========================================
// Autoplay variant A: progression-first
// 目標: 進行は維持しつつ、autoplay が被弾ゼロで駆け抜けないようにする
// ==========================================

///|
pub fn BalanceTargets::autoplay_progression() -> BalanceTargets {
  {
    target_survival_frames: 7200.0,
    target_floors: 5.5,
    target_floor_time: 1200.0,
    target_hp_cv: 0.34,
    target_kill_interval: 85.0,
    target_kill_interval_cv: 0.7,
    target_near_death_rate: 0.05,
    target_kills_per_floor: 22.0,
    target_damage_interval: 260.0,
    target_total_damage: 8.0,
    target_equip_upgrades: 5.0,
    target_learned_skill_count: 4.0,
    w_survival: 1.4,
    w_floor: 1.4,
    w_floor_time: 0.8,
    w_hp_cv: 1.0,
    w_kill_interval: 0.7,
    w_kill_cv: 0.3,
    w_near_death: 1.1,
    w_kills_per_floor: 0.9,
    w_damage_interval: 1.2,
    w_total_damage: 1.4,
    w_equip_upgrades: 1.4,
    w_learned_skill_count: 0.9,
  }
}

// ==========================================
// Autoplay variant A1.5: progression-first tuned mild pressure
// 目標: progression の floor 維持を残しつつ、damage / near-death を少しだけ強く要求する
// ==========================================

///|
pub fn BalanceTargets::autoplay_progression_v3() -> BalanceTargets {
  {
    target_survival_frames: 7200.0,
    target_floors: 5.25,
    target_floor_time: 1225.0,
    target_hp_cv: 0.35,
    target_kill_interval: 86.0,
    target_kill_interval_cv: 0.72,
    target_near_death_rate: 0.06,
    target_kills_per_floor: 22.0,
    target_damage_interval: 240.0,
    target_total_damage: 9.0,
    target_equip_upgrades: 5.0,
    target_learned_skill_count: 4.0,
    w_survival: 1.4,
    w_floor: 1.25,
    w_floor_time: 0.8,
    w_hp_cv: 1.1,
    w_kill_interval: 0.7,
    w_kill_cv: 0.3,
    w_near_death: 1.3,
    w_kills_per_floor: 0.9,
    w_damage_interval: 1.35,
    w_total_damage: 1.6,
    w_equip_upgrades: 1.5,
    w_learned_skill_count: 1.0,
  }
}

// ==========================================
// Autoplay variant A2: progression-first tuned
// 目標: 進行を維持しつつ、被弾と near-death を progression より少し強く要求する
// ==========================================

///|
pub fn BalanceTargets::autoplay_progression_v2() -> BalanceTargets {
  {
    target_survival_frames: 7200.0,
    target_floors: 5.0,
    target_floor_time: 1250.0,
    target_hp_cv: 0.36,
    target_kill_interval: 88.0,
    target_kill_interval_cv: 0.75,
    target_near_death_rate: 0.07,
    target_kills_per_floor: 22.0,
    target_damage_interval: 220.0,
    target_total_damage: 10.0,
    target_equip_upgrades: 5.0,
    target_learned_skill_count: 4.0,
    w_survival: 1.4,
    w_floor: 1.1,
    w_floor_time: 0.8,
    w_hp_cv: 1.2,
    w_kill_interval: 0.7,
    w_kill_cv: 0.3,
    w_near_death: 1.5,
    w_kills_per_floor: 0.9,
    w_damage_interval: 1.5,
    w_total_damage: 1.8,
    w_equip_upgrades: 1.6,
    w_learned_skill_count: 1.1,
  }
}

// ==========================================
// Autoplay variant B: pressure-first
// 目標: floor は少し落としても、被弾と near-death を明確に増やす
// ==========================================

///|
pub fn BalanceTargets::autoplay_pressure() -> BalanceTargets {
  {
    target_survival_frames: 7200.0,
    target_floors: 4.0,
    target_floor_time: 1700.0,
    target_hp_cv: 0.45,
    target_kill_interval: 95.0,
    target_kill_interval_cv: 1.0,
    target_near_death_rate: 0.14,
    target_kills_per_floor: 20.0,
    target_damage_interval: 150.0,
    target_total_damage: 18.0,
    target_equip_upgrades: 4.0,
    target_learned_skill_count: 3.0,
    w_survival: 1.7,
    w_floor: 0.7,
    w_floor_time: 0.8,
    w_hp_cv: 1.8,
    w_kill_interval: 0.5,
    w_kill_cv: 0.5,
    w_near_death: 2.0,
    w_kills_per_floor: 0.8,
    w_damage_interval: 2.0,
    w_total_damage: 2.2,
    w_equip_upgrades: 0.8,
    w_learned_skill_count: 0.5,
  }
}

// ==========================================
// Autoplay variant C: attrition
// 目標: 長くは進むが、毎 floor で消耗が積み上がる
// ==========================================

///|
pub fn BalanceTargets::autoplay_attrition() -> BalanceTargets {
  {
    target_survival_frames: 7200.0,
    target_floors: 5.0,
    target_floor_time: 1400.0,
    target_hp_cv: 0.4,
    target_kill_interval: 88.0,
    target_kill_interval_cv: 0.85,
    target_near_death_rate: 0.1,
    target_kills_per_floor: 23.0,
    target_damage_interval: 190.0,
    target_total_damage: 14.0,
    target_equip_upgrades: 5.0,
    target_learned_skill_count: 4.0,
    w_survival: 1.8,
    w_floor: 1.0,
    w_floor_time: 0.9,
    w_hp_cv: 1.5,
    w_kill_interval: 0.6,
    w_kill_cv: 0.4,
    w_near_death: 1.7,
    w_kills_per_floor: 1.0,
    w_damage_interval: 1.7,
    w_total_damage: 1.9,
    w_equip_upgrades: 1.2,
    w_learned_skill_count: 0.8,
  }
}

// ==========================================
// Item spike feedback
// 目標: アイテム更新で一気に強くなり、その後の combat density が伸びる
// ==========================================

///|
pub fn BalanceTargets::item_spike_feedback() -> BalanceTargets {
  {
    target_survival_frames: 7200.0,
    target_floors: 6.0,
    target_floor_time: 1100.0,
    target_hp_cv: 0.38,
    target_kill_interval: 75.0,
    target_kill_interval_cv: 0.8,
    target_near_death_rate: 0.08,
    target_kills_per_floor: 24.0,
    target_damage_interval: 240.0,
    target_total_damage: 10.0,
    target_equip_upgrades: 6.0,
    target_learned_skill_count: 4.0,
    w_survival: 1.2,
    w_floor: 1.0,
    w_floor_time: 0.9,
    w_hp_cv: 0.8,
    w_kill_interval: 1.0,
    w_kill_cv: 0.4,
    w_near_death: 1.0,
    w_kills_per_floor: 1.0,
    w_damage_interval: 1.2,
    w_total_damage: 1.2,
    w_equip_upgrades: 2.0,
    w_learned_skill_count: 1.2,
  }
}

// ==========================================
// Build-diverse hack-and-slash
// 目標: 爽快感重視。探索は短く、装備更新とスキル取得が頻繁に起きる
// ==========================================

///|
pub fn BalanceTargets::build_diverse_hackslash() -> BalanceTargets {
  {
    target_survival_frames: 9000.0,
    target_floors: 8.0,
    target_floor_time: 450.0,
    target_hp_cv: 0.3,
    target_kill_interval: 55.0,
    target_kill_interval_cv: 0.6,
    target_near_death_rate: 0.06,
    target_kills_per_floor: 18.0,
    target_damage_interval: 320.0,
    target_total_damage: 8.0,
    target_equip_upgrades: 7.0,
    target_learned_skill_count: 5.0,
    w_survival: 0.8,
    w_floor: 1.3,
    w_floor_time: 1.8,
    w_hp_cv: 0.6,
    w_kill_interval: 1.4,
    w_kill_cv: 0.3,
    w_near_death: 0.7,
    w_kills_per_floor: 1.3,
    w_damage_interval: 0.8,
    w_total_damage: 0.8,
    w_equip_upgrades: 1.8,
    w_learned_skill_count: 1.8,
  }
}

// ==========================================
// Mechanics-heavy roguelike
// 目標: シナジーのない選択では失速し、選択の意味が強い
// ==========================================

///|
pub fn BalanceTargets::mechanics_roguelike() -> BalanceTargets {
  {
    target_survival_frames: 7200.0,
    target_floors: 5.0,
    target_floor_time: 850.0,
    target_hp_cv: 0.45,
    target_kill_interval: 95.0,
    target_kill_interval_cv: 1.0,
    target_near_death_rate: 0.14,
    target_kills_per_floor: 14.0,
    target_damage_interval: 170.0,
    target_total_damage: 16.0,
    target_equip_upgrades: 5.0,
    target_learned_skill_count: 6.0,
    w_survival: 1.6,
    w_floor: 1.0,
    w_floor_time: 1.0,
    w_hp_cv: 1.8,
    w_kill_interval: 0.9,
    w_kill_cv: 0.8,
    w_near_death: 1.8,
    w_kills_per_floor: 0.9,
    w_damage_interval: 1.8,
    w_total_damage: 2.0,
    w_equip_upgrades: 1.5,
    w_learned_skill_count: 2.4,
  }
}

///|
pub fn BalanceTargets::mechanics_roguelike_v2() -> BalanceTargets {
  {
    target_survival_frames: 7200.0,
    target_floors: 4.5,
    target_floor_time: 900.0,
    target_hp_cv: 0.48,
    target_kill_interval: 105.0,
    target_kill_interval_cv: 1.05,
    target_near_death_rate: 0.12,
    target_kills_per_floor: 12.0,
    target_damage_interval: 210.0,
    target_total_damage: 10.0,
    target_equip_upgrades: 9.0,
    target_learned_skill_count: 3.0,
    w_survival: 1.8,
    w_floor: 1.0,
    w_floor_time: 0.8,
    w_hp_cv: 1.7,
    w_kill_interval: 0.8,
    w_kill_cv: 0.9,
    w_near_death: 1.9,
    w_kills_per_floor: 0.8,
    w_damage_interval: 1.4,
    w_total_damage: 1.6,
    w_equip_upgrades: 2.1,
    w_learned_skill_count: 3.0,
  }
}

///|
pub fn autoplay_balance_hypotheses() -> Array[BalanceHypothesis] {
  [
    { name: "default", targets: BalanceTargets::default() },
    { name: "action_dense", targets: BalanceTargets::action_dense() },
    { name: "survival_horror", targets: BalanceTargets::survival_horror() },
    { name: "speedrun", targets: BalanceTargets::speedrun() },
    { name: "risk_reward", targets: BalanceTargets::risk_reward() },
    {
      name: "item_spike_feedback",
      targets: BalanceTargets::item_spike_feedback(),
    },
    {
      name: "build_diverse_hackslash",
      targets: BalanceTargets::build_diverse_hackslash(),
    },
    {
      name: "mechanics_roguelike",
      targets: BalanceTargets::mechanics_roguelike(),
    },
    {
      name: "mechanics_roguelike_v2",
      targets: BalanceTargets::mechanics_roguelike_v2(),
    },
    {
      name: "autoplay_progression",
      targets: BalanceTargets::autoplay_progression(),
    },
    {
      name: "autoplay_progression_v3",
      targets: BalanceTargets::autoplay_progression_v3(),
    },
    {
      name: "autoplay_progression_v2",
      targets: BalanceTargets::autoplay_progression_v2(),
    },
    { name: "autoplay_pressure", targets: BalanceTargets::autoplay_pressure() },
    {
      name: "autoplay_attrition",
      targets: BalanceTargets::autoplay_attrition(),
    },
    {
      name: "autoplay_rebalance",
      targets: BalanceTargets::autoplay_rebalance(),
    },
  ]
}

///|
pub fn balance_hypothesis_from_name(name : String) -> BalanceHypothesis? {
  for hypothesis in autoplay_balance_hypotheses() {
    if hypothesis.name == name {
      return Some(hypothesis)
    }
  }
  None
}

// Compute loss for a single simulation result

///|
pub fn compute_loss(metrics : SimMetrics, t : BalanceTargets) -> Double {
  let survival = metrics.survival_frames.to_double()
  let floors = metrics.floors_cleared.to_double()
  let floor_time = if metrics.floor_times.length() > 0 {
    metrics.avg_floor_time()
  } else {
    t.target_floor_time * 3.0 // penalize no clears
  }
  let hp_cv = metrics.hp_coefficient_of_variation()
  let kill_interval = metrics.avg_kill_interval()
  let kill_cv = metrics.kill_interval_cv()
  let near_death = metrics.near_death_rate()
  let kills_pf = metrics.kills_per_floor()
  let dmg_interval = metrics.avg_damage_interval()
  let total_damage = metrics.total_damage_taken.to_double()
  let equip_upgrades = metrics.equip_upgrades.to_double()
  let learned_skill_count = metrics.learned_skill_count.to_double()
  t.w_survival * @dec.sq_err(survival, t.target_survival_frames) +
  t.w_floor * @dec.sq_err(floors, t.target_floors) +
  t.w_floor_time * @dec.sq_err(floor_time, t.target_floor_time) +
  t.w_hp_cv * @dec.sq_err(hp_cv, t.target_hp_cv) +
  t.w_kill_interval * @dec.sq_err(kill_interval, t.target_kill_interval) +
  t.w_kill_cv * @dec.sq_err(kill_cv, t.target_kill_interval_cv) +
  t.w_near_death * @dec.sq_err(near_death, t.target_near_death_rate) +
  t.w_kills_per_floor * @dec.sq_err(kills_pf, t.target_kills_per_floor) +
  t.w_damage_interval * @dec.sq_err(dmg_interval, t.target_damage_interval) +
  t.w_total_damage * @dec.sq_err(total_damage, t.target_total_damage) +
  t.w_equip_upgrades * @dec.sq_err(equip_upgrades, t.target_equip_upgrades) +
  t.w_learned_skill_count *
  @dec.sq_err(learned_skill_count, t.target_learned_skill_count)
}

// Run multiple simulations with different seeds, return average loss
// Per-seed metrics are averaged as scalars to avoid cross-seed frame concatenation bugs

///|
pub fn compute_loss_averaged(
  params : @game.BalanceParams,
  targets : BalanceTargets,
  seeds : Array[Int],
  max_frames : Int,
) -> (Double, SimMetrics) {
  let mut total_loss = 0.0
  let mut total_survival = 0
  let mut total_floors = 0
  let mut total_kills = 0
  let mut total_score = 0
  let mut total_damage = 0
  let mut total_equip = 0
  let mut total_learned_skill_count = 0
  let mut total_near_death = 0
  // Accumulate derived metrics as averages
  let mut total_avg_hp = 0.0
  let mut total_hp_cv = 0.0
  let mut total_floor_time = 0.0
  let mut total_kill_interval = 0.0
  let mut total_kill_cv = 0.0
  let mut total_near_death_rate = 0.0
  let mut total_kills_per_floor = 0.0
  let mut total_damage_interval = 0.0
  for seed in seeds {
    let m = run_simulation(params, seed, max_frames)
    total_loss = total_loss + compute_loss(m, targets)
    total_survival = total_survival + m.survival_frames
    total_floors = total_floors + m.floors_cleared
    total_kills = total_kills + m.total_kills
    total_score = total_score + m.score
    total_damage = total_damage + m.total_damage_taken
    total_equip = total_equip + m.equip_upgrades
    total_learned_skill_count = total_learned_skill_count +
      m.learned_skill_count
    total_near_death = total_near_death + m.near_death_count
    total_avg_hp = total_avg_hp + m.avg_hp_ratio()
    total_hp_cv = total_hp_cv + m.hp_coefficient_of_variation()
    total_floor_time = total_floor_time + m.avg_floor_time()
    total_kill_interval = total_kill_interval + m.avg_kill_interval()
    total_kill_cv = total_kill_cv + m.kill_interval_cv()
    total_near_death_rate = total_near_death_rate + m.near_death_rate()
    total_kills_per_floor = total_kills_per_floor + m.kills_per_floor()
    total_damage_interval = total_damage_interval + m.avg_damage_interval()
  }
  let n = seeds.length()
  let nd = n.to_double()
  // Build synthetic SimMetrics with pre-computed averages encoded in arrays
  // hp_samples: single element = avg hp ratio (mean of means)
  // floor_times: single element encoding avg floor time
  // kill_frames: two synthetic frames encoding avg kill interval
  // damage_frames: two synthetic frames encoding avg damage interval
  let avg_hp = total_avg_hp / nd
  let avg_floor_time = total_floor_time / nd
  let avg_kill_int = total_kill_interval / nd
  let avg_dmg_int = total_damage_interval / nd
  let avg_metrics : SimMetrics = {
    survival_frames: total_survival / n,
    floors_cleared: total_floors / n,
    total_damage_taken: total_damage / n,
    total_kills: total_kills / n,
    score: total_score / n,
    hp_samples: [avg_hp],
    floor_times: [avg_floor_time.to_int()],
    kill_frames: if avg_kill_int > 0.0 {
      [0, avg_kill_int.to_int()]
    } else {
      []
    },
    damage_frames: if avg_dmg_int > 0.0 {
      [0, avg_dmg_int.to_int()]
    } else {
      []
    },
    equip_upgrades: total_equip / n,
    learned_skill_count: total_learned_skill_count / n,
    near_death_count: total_near_death / n,
  }
  (total_loss / nd, avg_metrics)
}

// Averaged scalar accessors for display (bypasses array-based computation)

///|
pub(all) struct AveragedMetrics {
  base : SimMetrics
  avg_hp_ratio : Double
  hp_cv : Double
  avg_floor_time : Double
  avg_kill_interval : Double
  kill_interval_cv : Double
  near_death_rate : Double
  kills_per_floor : Double
  avg_damage_interval : Double
}

///|
pub fn compute_loss_averaged_full(
  params : @game.BalanceParams,
  targets : BalanceTargets,
  seeds : Array[Int],
  max_frames : Int,
) -> (Double, AveragedMetrics) {
  let mut total_loss = 0.0
  let mut total_survival = 0
  let mut total_floors = 0
  let mut total_kills = 0
  let mut total_score = 0
  let mut total_damage = 0
  let mut total_equip = 0
  let mut total_learned_skill_count = 0
  let mut total_near_death = 0
  let mut total_avg_hp = 0.0
  let mut total_hp_cv = 0.0
  let mut total_floor_time = 0.0
  let mut total_kill_interval = 0.0
  let mut total_kill_cv = 0.0
  let mut total_near_death_rate = 0.0
  let mut total_kills_per_floor = 0.0
  let mut total_damage_interval = 0.0
  for seed in seeds {
    let m = run_simulation(params, seed, max_frames)
    total_loss = total_loss + compute_loss(m, targets)
    total_survival = total_survival + m.survival_frames
    total_floors = total_floors + m.floors_cleared
    total_kills = total_kills + m.total_kills
    total_score = total_score + m.score
    total_damage = total_damage + m.total_damage_taken
    total_equip = total_equip + m.equip_upgrades
    total_learned_skill_count = total_learned_skill_count +
      m.learned_skill_count
    total_near_death = total_near_death + m.near_death_count
    total_avg_hp = total_avg_hp + m.avg_hp_ratio()
    total_hp_cv = total_hp_cv + m.hp_coefficient_of_variation()
    total_floor_time = total_floor_time + m.avg_floor_time()
    total_kill_interval = total_kill_interval + m.avg_kill_interval()
    total_kill_cv = total_kill_cv + m.kill_interval_cv()
    total_near_death_rate = total_near_death_rate + m.near_death_rate()
    total_kills_per_floor = total_kills_per_floor + m.kills_per_floor()
    total_damage_interval = total_damage_interval + m.avg_damage_interval()
  }
  let n = seeds.length()
  let nd = n.to_double()
  let base : SimMetrics = {
    survival_frames: total_survival / n,
    floors_cleared: total_floors / n,
    total_damage_taken: total_damage / n,
    total_kills: total_kills / n,
    score: total_score / n,
    hp_samples: [],
    floor_times: [],
    kill_frames: [],
    damage_frames: [],
    equip_upgrades: total_equip / n,
    learned_skill_count: total_learned_skill_count / n,
    near_death_count: total_near_death / n,
  }
  let am : AveragedMetrics = {
    base,
    avg_hp_ratio: total_avg_hp / nd,
    hp_cv: total_hp_cv / nd,
    avg_floor_time: total_floor_time / nd,
    avg_kill_interval: total_kill_interval / nd,
    kill_interval_cv: total_kill_cv / nd,
    near_death_rate: total_near_death_rate / nd,
    kills_per_floor: total_kills_per_floor / nd,
    avg_damage_interval: total_damage_interval / nd,
  }
  (total_loss / nd, am)
}
