// Loss functions for game balance optimization
// Each hypothesis targets a different player experience

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
}

// ==========================================
// Hypothesis A: "Action-dense" (アクション重視)
// 目標: 戦闘密度が高く、テンポよく敵を倒し続ける爽快感
// - 短いキル間隔、適度なHP変動、速いフロアクリア
// ==========================================
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
    w_survival: 0.5,
    w_floor: 1.0,
    w_floor_time: 1.5, // フロアタイム重視
    w_hp_cv: 0.3,
    w_kill_interval: 1.5, // キル頻度重視
    w_kill_cv: 0.3,
    w_near_death: 0.5,
    w_kills_per_floor: 1.0,
    w_damage_interval: 0.3,
  }
}

// ==========================================
// Hypothesis B: "Survival horror" (サバイバル重視)
// 目標: 常に緊張感があり、リソース管理が重要
// - HP変動が大きい、頻繁に瀕死、短い生存時間
// ==========================================
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
    w_survival: 1.5, // 生存時間を厳密に制御
    w_floor: 1.0,
    w_floor_time: 0.5,
    w_hp_cv: 2.0, // HP変動を最重視
    w_kill_interval: 0.3,
    w_kill_cv: 0.5,
    w_near_death: 2.0, // 瀕死率を最重視
    w_kills_per_floor: 0.3,
    w_damage_interval: 1.0,
  }
}

// ==========================================
// Hypothesis C: "Speedrun-optimized" (スピードラン向け)
// 目標: 熟練プレイヤーが素早く攻略できる
// - 非常に速いフロアクリア、高キルレート、装備更新頻度高
// ==========================================
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
    w_survival: 0.3,
    w_floor: 2.0, // フロア数を最重視
    w_floor_time: 2.0, // フロアタイムを最重視
    w_hp_cv: 0.2,
    w_kill_interval: 1.0,
    w_kill_cv: 0.5,
    w_near_death: 0.3,
    w_kills_per_floor: 0.5,
    w_damage_interval: 0.2,
  }
}

// ==========================================
// Hypothesis D: "Risk-reward" (リスク・リワード)
// 目標: 死と隣り合わせだが報酬が大きい
// - 高い瀕死率だが生存、適度なフロア進行、高スコア
// ==========================================
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
    w_survival: 1.0,
    w_floor: 0.8,
    w_floor_time: 0.5,
    w_hp_cv: 1.5,
    w_kill_interval: 0.5,
    w_kill_cv: 1.5, // キルリズム変化を重視
    w_near_death: 1.5, // 瀕死率を重視
    w_kills_per_floor: 0.8,
    w_damage_interval: 1.0,
  }
}

// ==========================================
// Default (balanced)
// ==========================================
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
    w_survival: 1.0,
    w_floor: 1.0,
    w_floor_time: 0.5,
    w_hp_cv: 0.5,
    w_kill_interval: 0.5,
    w_kill_cv: 0.3,
    w_near_death: 0.5,
    w_kills_per_floor: 0.3,
    w_damage_interval: 0.3,
  }
}

// Compute loss for a single simulation result
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
  t.w_survival * @dec.sq_err(survival, t.target_survival_frames) +
    t.w_floor * @dec.sq_err(floors, t.target_floors) +
    t.w_floor_time * @dec.sq_err(floor_time, t.target_floor_time) +
    t.w_hp_cv * @dec.sq_err(hp_cv, t.target_hp_cv) +
    t.w_kill_interval * @dec.sq_err(kill_interval, t.target_kill_interval) +
    t.w_kill_cv * @dec.sq_err(kill_cv, t.target_kill_interval_cv) +
    t.w_near_death * @dec.sq_err(near_death, t.target_near_death_rate) +
    t.w_kills_per_floor * @dec.sq_err(kills_pf, t.target_kills_per_floor) +
    t.w_damage_interval * @dec.sq_err(dmg_interval, t.target_damage_interval)
}

// Run multiple simulations with different seeds, return average loss
// Per-seed metrics are averaged as scalars to avoid cross-seed frame concatenation bugs
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
    kill_frames: if avg_kill_int > 0.0 { [0, avg_kill_int.to_int()] } else { [] },
    damage_frames: if avg_dmg_int > 0.0 { [0, avg_dmg_int.to_int()] } else { [] },
    equip_upgrades: total_equip / n,
    near_death_count: total_near_death / n,
  }
  (total_loss / nd, avg_metrics)
}

// Averaged scalar accessors for display (bypasses array-based computation)
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
