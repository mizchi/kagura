///|
/// Fun Metrics — StS の面白さを定量化する指標群
///
/// === StS の面白さの7仮説と対応する計測指標 ===
///
/// 1. 適切な緊張感（Tension: danger → resolution → relief）
///    → HPをロストしそうな状態がどれだけ続くか、それを対処できた達成感
///    指標: danger_turn_ratio = 敵の攻撃意図 > ブロック のターン割合
///          danger_resolution_rate = 危険ターンでダメージを完全に防げた割合
///          avg_danger_streak = 連続で危険にさらされるターン数の平均
///
/// 2. ドローによるうまくいかなさ（Draw Variance）
///    → 同じデッキでもシード違いで結果が変わる度合い
///    指標: seed_variance = 同一構成×異なるシードの勝率の分散
///          hand_quality_spread = 各ターンの手札価値の標準偏差
///
/// 3. ビルドが噛み合った時の爆発力（Synergy Explosion）
///    → アーキタイプ一致デッキ vs ランダムデッキの性能差
///    指標: synergy_multiplier = (特化デッキDPT) / (スターターDPT)
///          power_curve_slope = フロア進行に伴うDPTの増加率
///
/// 4. リソーストレードオフの深さ（Resource Tension）
///    → HPを消費するカード(Offering等)の使用頻度と勝率への影響
///    指標: hp_for_power_trades = HP消費カードの使用回数/ラン
///
/// 5. 敵パーソナリティの分化（Enemy Differentiation）
///    → 敵ごとの最適戦略の違い度合い
///    指標: strategy_divergence = 敵ごとの(攻撃的勝率 - 防御的勝率)の分散
///
/// 6. 意思決定の重み（Decision Weight）
///    → Smart AI vs Random AI の勝率差
///    指標: decision_impact = smart_win_rate - random_win_rate
///
/// 7. 逆転可能性（Comeback Potential）
///    → 低HP状態からの勝利頻度
///    指標: comeback_rate = (HP<30%から勝利した戦闘) / (HP<30%で開始した戦闘)

///|
/// Per-battle statistics for detailed analysis
pub(all) struct BattleStats {
  floor : Int
  encounter : String
  won : Bool
  turns : Int
  hp_before : Int
  hp_after : Int
  damage_dealt : Int
  damage_taken : Int
  block_generated : Int
  cards_played : Int
  min_hp_during : Int // lowest HP reached during battle
  // Danger/Resolution tracking
  danger_turns : Int // turns where incoming > block (exposed to HP loss)
  resolved_turns : Int // danger turns where player blocked all damage
  max_danger_streak : Int // longest consecutive danger turns
  total_danger_streaks : Int // number of danger streaks (for avg calculation)
  total_danger_streak_len : Int // sum of all streak lengths
} derive(Show)

///|
/// Detailed run result with per-battle stats
pub(all) struct DetailedRunResult {
  won : Bool
  floors_reached : Int
  battles : Array[BattleStats]
  final_deck : Array[CardId]
  archetype : Archetype
  cards_added : Array[CardId]
  cards_skipped : Int
} derive(Show)

///|
/// Fun metrics extracted from a set of runs
pub(all) struct FunMetrics {
  // === 1. Tension (danger → resolution → relief) ===
  danger_turn_ratio : Double // % of player turns exposed to unblocked damage
  danger_resolution_rate : Double // % of danger turns where all damage was blocked
  avg_danger_streak : Double // avg consecutive turns of sustained danger
  tension_ratio : Double // (legacy) % of battles where HP dropped below 25%
  lethal_proximity : Double // avg min-HP reached in winning runs
  close_win_rate : Double // % of wins where final HP < 20

  // === 2. Draw Variance ===
  win_rate_variance : Double // variance of win rates across seed groups
  outcome_entropy : Double // Shannon entropy of win/loss pattern

  // === 3. Synergy Explosion ===
  synergy_multiplier : Double // DPT ratio: built deck / starter deck
  power_curve_slope : Double // avg DPT increase per floor

  // === 4. Resource Tradeoff ===
  hp_trade_frequency : Double // HP-cost cards played per run

  // === 5. Enemy Differentiation ===
  strategy_divergence : Double // variance of (aggressive_wr - defensive_wr) across encounters

  // === 6. Decision Weight ===
  decision_impact : Double // smart_win% - random_win%

  // === 7. Comeback Potential ===
  comeback_rate : Double // wins from <30% HP / battles started at <30% HP

  // === 8. Attrition (消耗率) ===
  per_battle_attrition : Double // avg (hp_before - hp_after) / max_hp per battle
  act_gross_attrition : Double // sum(damage_taken) / max_hp across entire Act
  act_net_attrition : Double // (start_hp - final_hp) / max_hp (net after rests)
} derive(Show)

///|
/// Simulate a detailed run tracking per-battle stats
pub fn simulate_detailed_run(
  seed : Int,
  strategy : PlayStrategy,
) -> DetailedRunResult {
  let run = RunState::new(seed~)
  let battles : Array[BattleStats] = []
  let cards_added : Array[CardId] = []
  let mut cards_skipped = 0
  let mut safety = 0
  while safety < 100 {
    safety += 1
    match run.phase {
      Battle =>
        match run.battle {
          Some(state) => {
            let floor = run.floor
            let hp_before = state.player.hp
            let mut min_hp = hp_before
            let mut damage_dealt = 0
            let mut block_generated = 0
            let mut n_cards_played = 0
            // Track enemy HP for damage calculation
            let mut enemy_hp_sum = 0
            for e in state.enemies {
              enemy_hp_sum += e.fighter.hp
            }
            // Use potions at battle start
            let potions_copy : Array[PotionId] = []
            for p in run.potions {
              potions_copy.push(p)
            }
            let mut potions_used = 0
            // Danger/resolution tracking
            let mut danger_turns = 0
            let mut resolved_turns = 0
            let mut current_streak = 0
            let mut max_streak = 0
            let mut total_streaks = 0
            let mut total_streak_len = 0
            let mut battle_safety = 0
            while state.phase == PlayerTurn && battle_safety < 300 {
              battle_safety += 1
              // Try potions at start of each turn
              if potions_copy.length() > 0 {
                let used = try_use_potions(state, potions_copy)
                potions_used += used
              }
              if state.phase == Victory || state.phase == Defeat {
                break
              }
              let hp_before_turn = state.player.hp
              // Play all cards this turn
              let mut turn_done = false
              while not(turn_done) {
                let choice = pick_card(state, strategy)
                match choice {
                  Some((hand_idx, target)) => {
                    let mut enemy_hp_pre = 0
                    for e in state.enemies {
                      if not(e.fighter.is_dead()) {
                        enemy_hp_pre += e.fighter.hp
                      }
                    }
                    let result = play_card(state, hand_idx, target)
                    if result == Ok {
                      n_cards_played += 1
                      let mut enemy_hp_post = 0
                      for e in state.enemies {
                        if not(e.fighter.is_dead()) {
                          enemy_hp_post += e.fighter.hp
                        }
                      }
                      let dmg = enemy_hp_pre - enemy_hp_post
                      if dmg > 0 {
                        damage_dealt += dmg
                      }
                      let blk = state.player.block
                      if blk > block_generated {
                        block_generated = blk
                      }
                    } else {
                      turn_done = true
                    }
                  }
                  None => turn_done = true
                }
                if state.phase == Victory || state.phase == Defeat {
                  turn_done = true
                }
              }
              // Assess danger AFTER playing cards: incoming vs built-up block
              // This measures "did I build enough defense?" — the actual tension moment
              let incoming = calc_incoming_damage(state)
              let is_danger = incoming > state.player.block
              // End turn (triggers enemy attacks)
              if state.phase == PlayerTurn {
                end_player_turn(state)
              }
              // Track min HP after enemies attack
              if state.player.hp < min_hp {
                min_hp = state.player.hp
              }
              // Danger resolution check
              if is_danger {
                danger_turns += 1
                let hp_lost = hp_before_turn - state.player.hp
                // "Resolved" = blocked more than half the incoming damage
                // This captures "I dealt with it reasonably" not just "perfect block"
                let blocked = incoming - hp_lost
                if blocked > 0 && blocked >= incoming / 2 {
                  // Player mitigated most of the threat = resolved!
                  resolved_turns += 1
                  // End streak
                  if current_streak > 0 {
                    total_streaks += 1
                    total_streak_len += current_streak
                    if current_streak > max_streak {
                      max_streak = current_streak
                    }
                    current_streak = 0
                  }
                } else {
                  // Failed to mitigate = streak continues
                  current_streak += 1
                }
                // Not in danger — end any active streak
              } else if current_streak > 0 {
                total_streaks += 1
                total_streak_len += current_streak
                if current_streak > max_streak {
                  max_streak = current_streak
                }
                current_streak = 0
              }
              if state.phase == Victory || state.phase == Defeat {
                break
              }
            }
            // Close any remaining streak
            if current_streak > 0 {
              total_streaks += 1
              total_streak_len += current_streak
              if current_streak > max_streak {
                max_streak = current_streak
              }
            }
            let hp_after = state.player.hp
            let damage_taken = hp_before - hp_after
            let enc_name = if state.enemies.length() > 0 {
              state.enemies[0].fighter.name
            } else {
              "Unknown"
            }
            battles.push({
              floor,
              encounter: enc_name,
              won: state.phase == Victory,
              turns: state.turn,
              hp_before,
              hp_after,
              damage_dealt,
              damage_taken: if damage_taken > 0 {
                damage_taken
              } else {
                0
              },
              block_generated,
              cards_played: n_cards_played,
              min_hp_during: if min_hp > 0 {
                min_hp
              } else {
                0
              },
              danger_turns,
              resolved_turns,
              max_danger_streak: max_streak,
              total_danger_streaks: total_streaks,
              total_danger_streak_len: total_streak_len,
            })
            // Sync potions back
            run.potions.clear()
            for p in potions_copy {
              run.potions.push(p)
            }
            if state.phase == Victory {
              on_battle_victory(run)
            } else {
              on_battle_defeat(run)
            }
          }
          None => break
        }
      CardReward =>
        if run.card_rewards.length() > 0 {
          let archetype = detect_archetype(run.deck)
          let mut best_idx = 0
          let mut best_val = 0.0
          let mut i = 0
          while i < run.card_rewards.length() {
            let card = run.card_rewards[i]
            let base_val = evaluate_card(card).total
            let synergy = match (archetype, card) {
              (Strength, Twin_Strike) | (Strength, Sword_Boomerang) => 5.0
              (Strength, Pummel) => 6.0
              (Strength, Inflame) => 8.0
              (Strength, Demon_Form) => 10.0
              (Block, Barricade) => 10.0
              (Block, Entrench) => 10.0
              (Block, Metallicize) => 8.0
              (Block, Body_Slam) => 7.0
              (Exhaust, Feel_No_Pain) => 10.0
              (Exhaust, True_Grit) | (Exhaust, Offering) => 5.0
              (_, Shockwave) => 4.0
              (_, Immolate) => 4.0
              (_, Reaper) => 4.0
              (_, Battle_Trance) => 3.0
              _ => 0.0
            }
            let val = base_val + synergy
            if val > best_val {
              best_val = val
              best_idx = i
            }
            i += 1
          }
          let skip_threshold = if run.deck.length() > 18 {
            20.0
          } else if run.deck.length() > 14 {
            12.0
          } else {
            5.0
          }
          if best_val < skip_threshold {
            cards_skipped += 1
            pick_card_reward(run, -1)
          } else {
            cards_added.push(run.card_rewards[best_idx])
            pick_card_reward(run, best_idx)
          }
        } else {
          pick_card_reward(run, -1)
        }
      RestSite => rest_heal(run)
      RunVictory | RunDefeat => break
    }
  }
  {
    won: run.phase == RunVictory,
    floors_reached: run.floor,
    battles,
    final_deck: run.deck,
    archetype: detect_archetype(run.deck),
    cards_added,
    cards_skipped,
  }
}

///|
/// Analyze fun metrics from multiple detailed runs
pub fn analyze_fun_metrics(run_count : Int) -> FunMetrics {
  let detailed_runs : Array[DetailedRunResult] = []
  let mut i = 0
  while i < run_count {
    detailed_runs.push(simulate_detailed_run(i * 7 + 1, Smart))
    i += 1
  }

  // === 1. Tension (danger → resolution → relief) ===
  let mut total_turns = 0
  let mut total_danger = 0
  let mut total_resolved = 0
  let mut total_streaks = 0
  let mut total_streak_len = 0
  let mut total_battles = 0
  let mut total_wins = 0
  let mut tense_battles = 0
  let mut min_hp_sum = 0.0
  let mut min_hp_count = 0
  let mut close_wins = 0
  for run in detailed_runs {
    for battle in run.battles {
      total_battles += 1
      total_turns += battle.turns
      total_danger += battle.danger_turns
      total_resolved += battle.resolved_turns
      total_streaks += battle.total_danger_streaks
      total_streak_len += battle.total_danger_streak_len
      if battle.min_hp_during < 20 {
        tense_battles += 1
      }
      if battle.won && battle.hp_after < 20 {
        close_wins += 1
      }
    }
    if run.won {
      total_wins += 1
      let mut run_min = 80
      for battle in run.battles {
        if battle.min_hp_during < run_min {
          run_min = battle.min_hp_during
        }
      }
      min_hp_sum += run_min.to_double()
      min_hp_count += 1
    }
  }
  // New danger-based tension metrics
  let danger_turn_ratio = if total_turns > 0 {
    total_danger.to_double() / total_turns.to_double()
  } else {
    0.0
  }
  let danger_resolution_rate = if total_danger > 0 {
    total_resolved.to_double() / total_danger.to_double()
  } else {
    0.0
  }
  let avg_danger_streak = if total_streaks > 0 {
    total_streak_len.to_double() / total_streaks.to_double()
  } else {
    0.0
  }
  // Legacy metrics (still useful for context)
  let tension_ratio = if total_battles > 0 {
    tense_battles.to_double() / total_battles.to_double()
  } else {
    0.0
  }
  let lethal_proximity = if min_hp_count > 0 {
    min_hp_sum / min_hp_count.to_double()
  } else {
    80.0
  }
  let close_win_rate = if total_wins > 0 {
    close_wins.to_double() / total_wins.to_double()
  } else {
    0.0
  }

  // === 2. Draw Variance ===
  // Compare win rates across different seed groups
  let group_size = run_count / 5
  let group_wins : Array[Double] = []
  if group_size > 0 {
    let mut g = 0
    while g < 5 {
      let mut wins = 0
      let mut j = g * group_size
      while j < (g + 1) * group_size && j < run_count {
        if detailed_runs[j].won {
          wins += 1
        }
        j += 1
      }
      group_wins.push(wins.to_double() / group_size.to_double())
      g += 1
    }
  }
  let win_rate_variance = if group_wins.length() > 1 {
    let mut mean = 0.0
    for wr in group_wins {
      mean += wr
    }
    mean /= group_wins.length().to_double()
    let mut variance = 0.0
    for wr in group_wins {
      let diff = wr - mean
      variance += diff * diff
    }
    variance / group_wins.length().to_double()
  } else {
    0.0
  }
  // Outcome entropy: binary entropy of overall win rate
  let overall_wr = if run_count > 0 {
    total_wins.to_double() / run_count.to_double()
  } else {
    0.5
  }
  let outcome_entropy = if overall_wr > 0.0 && overall_wr < 1.0 {
    -(overall_wr * log2(overall_wr) +
    (1.0 - overall_wr) * log2(1.0 - overall_wr))
  } else {
    0.0
  }

  // === 3. Synergy Explosion ===
  // Compare DPT at start vs end of run
  let mut early_dpt_sum = 0.0
  let mut early_dpt_count = 0
  let mut late_dpt_sum = 0.0
  let mut late_dpt_count = 0
  for run in detailed_runs {
    for battle in run.battles {
      if battle.turns > 0 {
        let dpt = battle.damage_dealt.to_double() / battle.turns.to_double()
        if battle.floor <= 3 {
          early_dpt_sum += dpt
          early_dpt_count += 1
        } else if battle.floor >= 13 {
          late_dpt_sum += dpt
          late_dpt_count += 1
        }
      }
    }
  }
  let early_dpt = if early_dpt_count > 0 {
    early_dpt_sum / early_dpt_count.to_double()
  } else {
    15.0
  }
  let late_dpt = if late_dpt_count > 0 {
    late_dpt_sum / late_dpt_count.to_double()
  } else {
    15.0
  }
  let synergy_multiplier = if early_dpt > 0.0 {
    late_dpt / early_dpt
  } else {
    1.0
  }
  // Power curve: how fast does DPT grow per floor?
  let power_curve_slope = if late_dpt_count > 0 && early_dpt_count > 0 {
    (late_dpt - early_dpt) / 12.0 // ~12 floors between early and late
  } else {
    0.0
  }

  // === 4. Resource Tradeoff ===
  let mut hp_trade_total = 0.0
  for run in detailed_runs {
    let mut hp_trades = 0
    for card in run.cards_added {
      match card {
        Bloodletting | Offering => hp_trades += 1
        _ => ()
      }
    }
    hp_trade_total += hp_trades.to_double()
  }
  let hp_trade_frequency = if run_count > 0 {
    hp_trade_total / run_count.to_double()
  } else {
    0.0
  }

  // === 5. Enemy Differentiation ===
  let test_encounters : Array[EncounterId] = [
    SingleJawWorm,
    TwoLouses,
    SingleCultist,
    FungiPair,
    EliteNob,
    SentryPair,
  ]
  let divergence_values : Array[Double] = []
  for enc in test_encounters {
    let agg = run_simulations(enc, Aggressive, 30)
    let def = run_simulations(enc, Defensive, 30)
    let agg_wr = agg.wins.to_double() / agg.total.to_double()
    let def_wr = def.wins.to_double() / def.total.to_double()
    divergence_values.push(agg_wr - def_wr)
  }
  let strategy_divergence = if divergence_values.length() > 1 {
    let mut mean = 0.0
    for v in divergence_values {
      mean += v
    }
    mean /= divergence_values.length().to_double()
    let mut variance = 0.0
    for v in divergence_values {
      let diff = v - mean
      variance += diff * diff
    }
    variance / divergence_values.length().to_double()
  } else {
    0.0
  }

  // === 6. Decision Weight ===
  // Compare Smart vs random (Aggressive as proxy for less-informed play)
  let smart_total = total_wins
  let smart_wr = if run_count > 0 {
    smart_total.to_double() / run_count.to_double()
  } else {
    0.0
  }
  // Simulate same count with Aggressive strategy
  let mut agg_wins = 0
  let mut j = 0
  while j < run_count {
    let result = simulate_run(j * 7 + 1, Aggressive)
    if result.won {
      agg_wins += 1
    }
    j += 1
  }
  let agg_wr = if run_count > 0 {
    agg_wins.to_double() / run_count.to_double()
  } else {
    0.0
  }
  let decision_impact = smart_wr - agg_wr

  // === 7. Comeback Potential ===
  let mut low_hp_battles = 0
  let mut low_hp_wins = 0
  for run in detailed_runs {
    for battle in run.battles {
      if battle.hp_before < 35 { // entering battle at <~40% HP
        low_hp_battles += 1
        if battle.won {
          low_hp_wins += 1
        }
      }
    }
  }
  let comeback_rate = if low_hp_battles > 0 {
    low_hp_wins.to_double() / low_hp_battles.to_double()
  } else {
    0.0
  }

  // === 8. Attrition ===
  let mut attrition_sum = 0.0
  let mut attrition_count = 0
  let mut gross_attrition_sum = 0.0
  let mut net_attrition_sum = 0.0
  let mut attrition_runs = 0
  for run in detailed_runs {
    let mut run_damage = 0.0
    for battle in run.battles {
      if battle.won {
        let max_hp = if battle.hp_before > 0 {
          80.0 // use base max HP
        } else {
          80.0
        }
        let loss = battle.damage_taken.to_double() / max_hp
        attrition_sum += loss
        attrition_count += 1
        run_damage += battle.damage_taken.to_double()
      }
    }
    if run.battles.length() > 0 {
      gross_attrition_sum += run_damage / 80.0
      let first_hp = run.battles[0].hp_before.to_double()
      let last_hp = run.battles[run.battles.length() - 1].hp_after.to_double()
      net_attrition_sum += (first_hp - last_hp) / 80.0
      attrition_runs += 1
    }
  }
  let per_battle_attrition = if attrition_count > 0 {
    attrition_sum / attrition_count.to_double()
  } else {
    0.0
  }
  let act_gross_attrition = if attrition_runs > 0 {
    gross_attrition_sum / attrition_runs.to_double()
  } else {
    0.0
  }
  let act_net_attrition = if attrition_runs > 0 {
    net_attrition_sum / attrition_runs.to_double()
  } else {
    0.0
  }

  {
    danger_turn_ratio,
    danger_resolution_rate,
    avg_danger_streak,
    tension_ratio,
    lethal_proximity,
    close_win_rate,
    win_rate_variance,
    outcome_entropy,
    synergy_multiplier,
    power_curve_slope,
    hp_trade_frequency,
    strategy_divergence,
    decision_impact,
    comeback_rate,
    per_battle_attrition,
    act_gross_attrition,
    act_net_attrition,
  }
}

///|
fn log2(x : Double) -> Double {
  // ln(x) / ln(2)
  @math.ln(x) / @math.ln(2.0)
}

///|
/// === プレイヤー体験目標値（Player Experience Targets） ===
///
/// StS 実プレイの「楽しい」を7軸で定量化。
/// 各指標の目標値は「プレイヤーが最も面白いと感じるゾーン」を定義する。
///
/// ─── 目標値の設計根拠 ───
///
/// 1. TENSION（危険→対処→安堵のサイクル）
///    ・体験: "ブロック足りない！でもDefendで凌いだ！" "3ターン連続で殴られたけど立て直した"
///    ・danger_turn_ratio (敵攻撃>ブロック のターン割合)
///      - <30%: 退屈。ほとんどのターンが安全で緊張しない
///      - 30-60%: 最適。半分程度のターンで「このままだとHP減る」という脅威を感じる
///      - >60%: 圧倒的。常に殴られて無力感
///    ・danger_resolution_rate (危険ターンでの対処成功率)
///      - <40%: 無力。対処できないことが多すぎて達成感がない
///      - 40-70%: 最適。「ギリギリ防げた！」の達成感と「防げなかった」の悔しさが共存
///      - >70%: 簡単すぎ。危険に見えるだけで実際は安全
///    ・avg_danger_streak (連続危険ターン数)
///      - <1.5: 一瞬の危険。すぐ解決するので緊張が持続しない
///      - 1.5-3.0: 最適。2-3ターン続く危機=戦術的判断の余地がある
///      - >3.0: 長すぎる危機。対処不能感、「どうしようもない」
///
/// 2. DRAW VARIANCE（ドローの揺らぎ）
///    ・体験: "Offering引いてれば勝てたのに" "完璧なドロー！"
///    ・outcome_entropy (勝敗のShannonエントロピー)
///      - <0.5: 退屈。勝つか負けるか開始時に分かる
///      - 0.7-0.95: 最適。実力で傾けられるが運も絡む
///      - >0.98: 純粋コイントス。実力関係ない
///    ・win_rate_variance (シードグループ間の勝率分散)
///      - <0.005: 均一すぎ。ドロー影響なし
///      - 0.01-0.05: 最適。「今回はいいドローだった」を感じる範囲
///      - >0.1: ドロー依存すぎ
///
/// 3. SYNERGY EXPLOSION（ビルドが噛み合った時の爆発力）
///    ・体験: "Limit Break + Demon Form でSTR32！" "Corruption最高！"
///    ・synergy_multiplier (後半DPT / 序盤DPT)
///      - <1.3: 成長感なし。スターターデッキとほぼ同じ
///      - 1.8-3.0: 最適。"自分のビルドが完成した"感覚
///      - >4.0: インフレ。敵が紙になり作業化する
///    ・power_curve_slope (フロアあたりDPT成長)
///      - 0.5-1.5: 最適。フロアごとに着実に強くなる実感
///
/// 4. RESOURCE TRADEOFF（リソースの取引）
///    ・体験: "Offering打つ？HP6失うけど…" "Feed で最大HP増やしたい"
///    ・hp_trade_frequency (HP消費カード使用数/ラン)
///      - 0: 安全すぎ。HPをリソースとして使えていない
///      - 0.5-2.0: 最適。1-2回の「HP vs パワー」判断がランに含まれる
///      - >3.0: 多すぎ。HP消費が必須になりジレンマでなくなる
///
/// 5. ENEMY DIFFERENTIATION（敵による戦略変化）
///    ・体験: "Nobだ！Skill使えない！" "Sentryは速攻で片方倒す"
///    ・strategy_divergence (攻撃/防御勝率差の分散)
///      - <0.005: 全敵同じ。最適戦略が1つ
///      - 0.02-0.15: 最適。敵ごとにプレイを変える楽しさ
///      - >0.3: 極端。特定敵に対して勝ち目なし
///
/// 6. DECISION WEIGHT（判断の重み）
///    ・体験: "あそこでBashじゃなくDefend選んでたら…"
///    ・decision_impact (Smart勝率 - Aggressive勝率)
///      - <5%: 判断不要。何を選んでも結果同じ
///      - 15-40%: 最適。上手い人と下手な人で結果が変わる
///      - >60%: 厳しすぎ。最適解以外が罰ゲーム
///
/// 7. COMEBACK POTENTIAL（逆転可能性）
///    ・体験: "HP8だけど Impervious + Body Slam で逆転！"
///    ・comeback_rate (低HP<25からの勝率)
///      - 0%: 絶望。低HPは即負け
///      - 30-60%: 最適。厳しいが手段はある = 最後まで諦めない
///      - >80%: 低HPにリスクがない（= Tensionが死ぬ）

///|
/// Target ranges for each fun metric (what players find enjoyable)
pub(all) struct FunTargets {
  // 1. Tension (danger/resolution model)
  danger_turn_ratio_min : Double // 0.30 — 30% of turns should feel dangerous
  danger_turn_ratio_max : Double // 0.60 — above 60% is overwhelming
  danger_resolution_min : Double // 0.40 — resolve at least 40% (not helpless)
  danger_resolution_max : Double // 0.70 — above 70% = too easy
  danger_streak_min : Double // 1.5 — streaks under 1.5 = no sustained tension
  danger_streak_max : Double // 3.0 — above 3 = feels hopeless
  // 2. Draw Variance
  entropy_min : Double // 0.70
  entropy_max : Double // 0.95
  variance_min : Double // 0.01
  variance_max : Double // 0.05
  // 3. Synergy Explosion
  synergy_min : Double // 1.8
  synergy_max : Double // 3.0
  slope_min : Double // 0.5
  slope_max : Double // 1.5
  // 4. Resource Tradeoff
  hp_trade_min : Double // 0.5
  hp_trade_max : Double // 2.0
  // 5. Enemy Differentiation
  divergence_min : Double // 0.02
  divergence_max : Double // 0.15
  // 6. Decision Weight
  decision_min : Double // 0.15
  decision_max : Double // 0.40
  // 7. Comeback
  comeback_min : Double // 0.30
  comeback_max : Double // 0.60
  // 8. Attrition (消耗率)
  per_battle_attrition_min : Double // 0.05 (5% max HP per battle)
  per_battle_attrition_max : Double // 0.20 (20% max HP per battle)
  act_gross_attrition_min : Double // 0.60 (60% total damage / max HP)
  act_gross_attrition_max : Double // 1.20 (120% — rest sites are critical)
} derive(Show)

///|
pub fn default_targets() -> FunTargets {
  {
    danger_turn_ratio_min: 0.30,
    danger_turn_ratio_max: 0.60,
    danger_resolution_min: 0.40,
    danger_resolution_max: 0.70,
    danger_streak_min: 1.5,
    danger_streak_max: 3.0,
    entropy_min: 0.70,
    entropy_max: 0.95,
    variance_min: 0.01,
    variance_max: 0.05,
    synergy_min: 1.8,
    synergy_max: 3.0,
    slope_min: 0.5,
    slope_max: 1.5,
    hp_trade_min: 0.5,
    hp_trade_max: 2.0,
    divergence_min: 0.02,
    divergence_max: 0.15,
    decision_min: 0.15,
    decision_max: 0.40,
    comeback_min: 0.30,
    comeback_max: 0.60,
    per_battle_attrition_min: 0.05,
    per_battle_attrition_max: 0.20,
    act_gross_attrition_min: 0.60,
    act_gross_attrition_max: 1.20,
  }
}

///|
/// Grade a single metric: IN_ZONE / TOO_LOW / TOO_HIGH
fn grade(value : Double, min : Double, max : Double) -> String {
  if value >= min && value <= max {
    "IN_ZONE"
  } else if value < min {
    "TOO_LOW"
  } else {
    "TOO_HIGH"
  }
}

///|
/// Score: 0.0 (worst) to 1.0 (center of zone). Quadratic falloff outside zone.
fn zone_score(value : Double, min : Double, max : Double) -> Double {
  if value >= min && value <= max {
    // Inside zone: 0.7-1.0 based on proximity to center
    let center = (min + max) / 2.0
    let half = (max - min) / 2.0
    if half > 0.0 {
      let dist = (value - center).abs() / half
      1.0 - dist * 0.3 // 1.0 at center, 0.7 at edges
    } else {
      1.0
    }
  } else if value < min {
    // Below zone: linear falloff
    let deficit = min - value
    let range = if min > 0.0 { min } else { 0.1 }
    let ratio = deficit / range
    let score = 0.7 - ratio * 0.7
    if score < 0.0 {
      0.0
    } else {
      score
    }
  } else {
    // Above zone: linear falloff
    let excess = value - max
    let range = if max > 0.0 { max } else { 0.1 }
    let ratio = excess / range
    let score = 0.7 - ratio * 0.7
    if score < 0.0 {
      0.0
    } else {
      score
    }
  }
}

///|
/// Comprehensive fun score with per-axis breakdown
pub(all) struct FunScorecard {
  // Per-axis scores (0.0-1.0)
  tension_score : Double
  draw_variance_score : Double
  synergy_score : Double
  resource_score : Double
  enemy_diff_score : Double
  decision_score : Double
  comeback_score : Double
  attrition_score : Double
  // Per-axis grades
  tension_grade : String
  draw_grade : String
  synergy_grade : String
  resource_grade : String
  enemy_grade : String
  decision_grade : String
  comeback_grade : String
  attrition_grade : String
  // Overall
  total_score : Double // weighted average (0-100)
  overall_grade : String // S / A / B / C / D
} derive(Show)

///|
pub fn score_fun_metrics(m : FunMetrics) -> FunScorecard {
  let t = default_targets()

  // 1. Tension: danger → resolution → relief cycle
  let s_tension = (
      zone_score(
        m.danger_turn_ratio,
        t.danger_turn_ratio_min,
        t.danger_turn_ratio_max,
      ) +
      zone_score(
        m.danger_resolution_rate,
        t.danger_resolution_min,
        t.danger_resolution_max,
      ) +
      zone_score(m.avg_danger_streak, t.danger_streak_min, t.danger_streak_max)
    ) /
    3.0
  let g_tension = grade(
    m.danger_turn_ratio,
    t.danger_turn_ratio_min,
    t.danger_turn_ratio_max,
  )

  // 2. Draw Variance: average of entropy and variance
  let s_draw = (
      zone_score(m.outcome_entropy, t.entropy_min, t.entropy_max) +
      zone_score(m.win_rate_variance, t.variance_min, t.variance_max)
    ) /
    2.0
  let g_draw = grade(m.outcome_entropy, t.entropy_min, t.entropy_max)

  // 3. Synergy: average of multiplier and slope
  let s_synergy = (
      zone_score(m.synergy_multiplier, t.synergy_min, t.synergy_max) +
      zone_score(m.power_curve_slope, t.slope_min, t.slope_max)
    ) /
    2.0
  let g_synergy = grade(m.synergy_multiplier, t.synergy_min, t.synergy_max)

  // 4. Resource
  let s_resource = zone_score(
    m.hp_trade_frequency,
    t.hp_trade_min,
    t.hp_trade_max,
  )
  let g_resource = grade(m.hp_trade_frequency, t.hp_trade_min, t.hp_trade_max)

  // 5. Enemy diff
  let s_enemy = zone_score(
    m.strategy_divergence,
    t.divergence_min,
    t.divergence_max,
  )
  let g_enemy = grade(m.strategy_divergence, t.divergence_min, t.divergence_max)

  // 6. Decision
  let s_decision = zone_score(m.decision_impact, t.decision_min, t.decision_max)
  let g_decision = grade(m.decision_impact, t.decision_min, t.decision_max)

  // 7. Comeback (if no low-HP battles, score based on whether danger is also too low)
  let s_comeback = if m.comeback_rate <= 0.0 &&
    m.danger_turn_ratio < t.danger_turn_ratio_min {
    0.2 // No low-HP battles because game is too easy
  } else {
    zone_score(m.comeback_rate, t.comeback_min, t.comeback_max)
  }
  let g_comeback = if m.comeback_rate <= 0.0 &&
    m.danger_turn_ratio < t.danger_turn_ratio_min {
    "N/A (要Tension改善)"
  } else {
    grade(m.comeback_rate, t.comeback_min, t.comeback_max)
  }

  // 8. Attrition: average of per-battle and gross attrition
  let s_attrition = (
      zone_score(
        m.per_battle_attrition,
        t.per_battle_attrition_min,
        t.per_battle_attrition_max,
      ) +
      zone_score(
        m.act_gross_attrition,
        t.act_gross_attrition_min,
        t.act_gross_attrition_max,
      )
    ) /
    2.0
  let g_attrition = grade(
    m.per_battle_attrition,
    t.per_battle_attrition_min,
    t.per_battle_attrition_max,
  )

  // Weighted total (weights reflect importance to player experience)
  // Tension and Decision are most important for "fun"
  let weights : Array[(Double, Double)] = [
    (s_tension, 18.0), // 緊張感
    (s_draw, 12.0), // ドロー揺らぎ
    (s_synergy, 13.0), // ビルド爆発力
    (s_resource, 8.0), // リソースジレンマ
    (s_enemy, 9.0), // 敵の個性
    (s_decision, 18.0), // 判断の重み
    (s_comeback, 8.0), // 逆転可能性
    (s_attrition, 14.0), // 消耗率 — 重要
  ]
  let mut weighted_sum = 0.0
  let mut weight_total = 0.0
  for pair in weights {
    let (score, weight) = pair
    weighted_sum += score * weight
    weight_total += weight
  }
  let total = if weight_total > 0.0 {
    weighted_sum / weight_total * 100.0
  } else {
    0.0
  }

  let overall = if total >= 85.0 {
    "S - 理想的なバランス"
  } else if total >= 70.0 {
    "A - ほぼ最適、微調整で到達"
  } else if total >= 55.0 {
    "B - 楽しいが改善の余地あり"
  } else if total >= 40.0 {
    "C - 基本構造はあるが調整が必要"
  } else {
    "D - 大幅な調整が必要"
  }

  {
    tension_score: s_tension,
    draw_variance_score: s_draw,
    synergy_score: s_synergy,
    resource_score: s_resource,
    enemy_diff_score: s_enemy,
    decision_score: s_decision,
    comeback_score: s_comeback,
    attrition_score: s_attrition,
    tension_grade: g_tension,
    draw_grade: g_draw,
    synergy_grade: g_synergy,
    resource_grade: g_resource,
    enemy_grade: g_enemy,
    decision_grade: g_decision,
    comeback_grade: g_comeback,
    attrition_grade: g_attrition,
    total_score: total,
    overall_grade: overall,
  }
}

///|
/// Format scorecard as a visual report
pub fn format_scorecard(sc : FunScorecard) -> String {
  let buf = StringBuilder::new()
  buf.write_string("=== FUN SCORECARD ===\n\n")
  // Bar chart helper
  fn bar(score : Double) -> String {
    let filled = (score * 10.0).to_int()
    let mut s = ""
    let mut i = 0
    while i < 10 {
      s = s + (if i < filled { "█" } else { "░" })
      i += 1
    }
    s
  }

  fn line(
    buf : StringBuilder,
    name : String,
    score : Double,
    grade : String,
    weight : String,
  ) {
    buf.write_string("  ")
    buf.write_string(name)
    buf.write_string(": ")
    buf.write_string(bar(score))
    buf.write_string(" ")
    let pct = (score * 100.0).to_int()
    buf.write_string(pct.to_string())
    buf.write_string("% [")
    buf.write_string(grade)
    buf.write_string("] (x")
    buf.write_string(weight)
    buf.write_string(")\n")
  }

  line(buf, "1.緊張感    ", sc.tension_score, sc.tension_grade, "18")
  line(buf, "2.ドロー揺らぎ", sc.draw_variance_score, sc.draw_grade, "12")
  line(buf, "3.ビルド爆発力", sc.synergy_score, sc.synergy_grade, "13")
  line(buf, "4.HP取引    ", sc.resource_score, sc.resource_grade, "8")
  line(buf, "5.敵の個性   ", sc.enemy_diff_score, sc.enemy_grade, "9")
  line(buf, "6.判断の重み  ", sc.decision_score, sc.decision_grade, "18")
  line(buf, "7.逆転可能性  ", sc.comeback_score, sc.comeback_grade, "8")
  line(buf, "8.消耗率     ", sc.attrition_score, sc.attrition_grade, "14")
  buf.write_string("\n  TOTAL: ")
  let total_int = sc.total_score.to_int()
  buf.write_string(total_int.to_string())
  buf.write_string("/100  ")
  buf.write_string(sc.overall_grade)
  buf.write_string("\n")
  buf.to_string()
}

///|
/// Print a formatted fun metrics report with raw data + scorecard
pub fn format_fun_report(m : FunMetrics) -> String {
  let t = default_targets()
  let buf = StringBuilder::new()
  buf.write_string("=== Fun Metrics Report ===\n\n")

  // 1. Tension (danger → resolution → relief)
  buf.write_string("1. TENSION (危険→対処→安堵のサイクル)\n")
  buf.write_string("   危険ターン割合: ")
  buf.write_string(pct_str(m.danger_turn_ratio))
  buf.write_string(" (目標: ")
  buf.write_string(pct_str(t.danger_turn_ratio_min))
  buf.write_string("-")
  buf.write_string(pct_str(t.danger_turn_ratio_max))
  buf.write_string(")\n")
  buf.write_string("   危険対処成功率: ")
  buf.write_string(pct_str(m.danger_resolution_rate))
  buf.write_string(" (目標: ")
  buf.write_string(pct_str(t.danger_resolution_min))
  buf.write_string("-")
  buf.write_string(pct_str(t.danger_resolution_max))
  buf.write_string(")\n")
  buf.write_string("   平均危険持続ターン: ")
  buf.write_string(m.avg_danger_streak.to_string())
  buf.write_string(" (目標: ")
  buf.write_string(t.danger_streak_min.to_string())
  buf.write_string("-")
  buf.write_string(t.danger_streak_max.to_string())
  buf.write_string(")\n")
  buf.write_string("   [参考] HP<25%の戦闘割合: ")
  buf.write_string(pct_str(m.tension_ratio))
  buf.write_string(" / ギリギリ勝利: ")
  buf.write_string(pct_str(m.close_win_rate))
  buf.write_string("\n\n")

  // 2. Draw Variance
  buf.write_string("2. DRAW VARIANCE (ドローによる揺らぎ)\n")
  buf.write_string("   勝敗エントロピー: ")
  buf.write_string(m.outcome_entropy.to_string())
  buf.write_string(" (目標: ")
  buf.write_string(t.entropy_min.to_string())
  buf.write_string("-")
  buf.write_string(t.entropy_max.to_string())
  buf.write_string(")\n")
  buf.write_string("   勝率の分散: ")
  buf.write_string(m.win_rate_variance.to_string())
  buf.write_string(" (目標: ")
  buf.write_string(t.variance_min.to_string())
  buf.write_string("-")
  buf.write_string(t.variance_max.to_string())
  buf.write_string(")\n\n")

  // 3. Synergy
  buf.write_string("3. SYNERGY EXPLOSION (ビルド爆発力)\n")
  buf.write_string("   後半/序盤DPT倍率: ")
  buf.write_string(m.synergy_multiplier.to_string())
  buf.write_string("x (目標: ")
  buf.write_string(t.synergy_min.to_string())
  buf.write_string("-")
  buf.write_string(t.synergy_max.to_string())
  buf.write_string("x)\n")
  buf.write_string("   DPT成長/floor: ")
  buf.write_string(m.power_curve_slope.to_string())
  buf.write_string(" (目標: ")
  buf.write_string(t.slope_min.to_string())
  buf.write_string("-")
  buf.write_string(t.slope_max.to_string())
  buf.write_string(")\n\n")

  // 4. Resource
  buf.write_string("4. RESOURCE TRADEOFF (HP対パワーの取引)\n")
  buf.write_string("   HP消費カード使用数/ラン: ")
  buf.write_string(m.hp_trade_frequency.to_string())
  buf.write_string(" (目標: ")
  buf.write_string(t.hp_trade_min.to_string())
  buf.write_string("-")
  buf.write_string(t.hp_trade_max.to_string())
  buf.write_string(")\n\n")

  // 5. Enemy Diff
  buf.write_string("5. ENEMY DIFFERENTIATION (敵ごとの戦略差)\n")
  buf.write_string("   戦略分散: ")
  buf.write_string(m.strategy_divergence.to_string())
  buf.write_string(" (目標: ")
  buf.write_string(t.divergence_min.to_string())
  buf.write_string("-")
  buf.write_string(t.divergence_max.to_string())
  buf.write_string(")\n\n")

  // 6. Decision Weight
  buf.write_string("6. DECISION WEIGHT (意思決定の重み)\n")
  buf.write_string("   Smart - Aggressive 勝率差: ")
  buf.write_string(pct_str(m.decision_impact))
  buf.write_string(" (目標: ")
  buf.write_string(pct_str(t.decision_min))
  buf.write_string("-")
  buf.write_string(pct_str(t.decision_max))
  buf.write_string(")\n\n")

  // 7. Comeback
  buf.write_string("7. COMEBACK POTENTIAL (逆転可能性)\n")
  buf.write_string("   低HP(<25)からの勝率: ")
  buf.write_string(pct_str(m.comeback_rate))
  buf.write_string(" (目標: ")
  buf.write_string(pct_str(t.comeback_min))
  buf.write_string("-")
  buf.write_string(pct_str(t.comeback_max))
  buf.write_string(")\n\n")

  // 8. Attrition
  buf.write_string("8. ATTRITION (消耗率)\n")
  buf.write_string("   1戦闘あたりの消耗率: ")
  buf.write_string(pct_str(m.per_battle_attrition))
  buf.write_string(" (目標: ")
  buf.write_string(pct_str(t.per_battle_attrition_min))
  buf.write_string("-")
  buf.write_string(pct_str(t.per_battle_attrition_max))
  buf.write_string(")\n")
  buf.write_string("   ACT全体の総消耗率: ")
  buf.write_string(pct_str(m.act_gross_attrition))
  buf.write_string(" (目標: ")
  buf.write_string(pct_str(t.act_gross_attrition_min))
  buf.write_string("-")
  buf.write_string(pct_str(t.act_gross_attrition_max))
  buf.write_string(")\n")
  buf.write_string("   ACT正味消耗率: ")
  buf.write_string(pct_str(m.act_net_attrition))
  buf.write_string("\n\n")

  // Scorecard
  let sc = score_fun_metrics(m)
  buf.write_string(format_scorecard(sc))

  buf.to_string()
}

///|
fn pct_str(v : Double) -> String {
  let pct = (v * 1000.0).to_int().to_double() / 10.0
  pct.to_string() + "%"
}
