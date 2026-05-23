# hacknslash_3d Balance Tuning

`hacknslash_3d` の自動バランス調整は `mizchi/differentiable_ecs` を使って headless autoplay で回す。
実験結果は `Parquet + DuckDB` に保存し、`before_change` と `after_tune` を比較する。

## Entry Points

- 1 仮説だけ記録する:

```sh
just balance-autoplay-record
```

- 複数仮説をまとめて回す:

```sh
just balance-hypothesis-record
```

- 仮説を絞る:

```sh
just balance-hypothesis-record extra='--hypotheses default,action_dense,item_spike_feedback,build_diverse_hackslash,mechanics_roguelike,autoplay_progression'
```

- 長めの midgame 実験:

```sh
just balance-hypothesis-record extra='--hypotheses default,autoplay_progression,autoplay_progression_v2,autoplay_rebalance --start-floor 5 --sim-max-frames 3600 --max-generations 4'
```

- ビルド多様性とスタイル比較:

```sh
just balance-hypothesis-record extra='--hypotheses action_dense,item_spike_feedback,build_diverse_hackslash,mechanics_roguelike,mechanics_roguelike_v2,default --start-floor 5 --sim-max-frames 3600 --max-generations 4'
```

- floor 1 からの build diversity 実験:

```sh
just balance-hypothesis-record extra='--hypotheses item_spike_feedback,build_diverse_hackslash,mechanics_roguelike,mechanics_roguelike_v2,default --start-floor 1 --sim-max-frames 7200 --max-generations 4'
```

## Output

- 単発 export:
  - `examples/games-3d/hacknslash_3d/data/hackslash/autoplay_experiments/*.parquet`
  - `examples/games-3d/hacknslash_3d/data/hackslash/autoplay_experiments/autoplay_experiments.duckdb`
- 仮説比較:
  - `examples/games-3d/hacknslash_3d/data/hackslash/autoplay_hypothesis_experiments/*.parquet`
  - `examples/games-3d/hacknslash_3d/data/hackslash/autoplay_hypothesis_experiments/autoplay_experiments.duckdb`

各 Parquet には少なくとも次が入る。

- `experiment_id`
- `run_kind`
  - `before_change`
  - `after_tune`
- `runner`
- `hypothesis_name`
- `loss`
- `survival_frames`
- `floors_cleared`
- `total_damage`
- `near_death_rate`
- tuned parameter columns

## Current Hypotheses

- `default`
- `action_dense`
- `survival_horror`
- `speedrun`
- `risk_reward`
- `autoplay_progression`
- `autoplay_progression_v3`
- `autoplay_progression_v2`
- `autoplay_attrition`
- `autoplay_pressure`
- `autoplay_rebalance`
- `item_spike_feedback`
- `build_diverse_hackslash`
- `mechanics_roguelike`
- `mechanics_roguelike_v2`

## Style Hypotheses

- `build_diverse_hackslash`
  - 爽快感重視のハックアンドスラッシュ
  - 探索時間を短くしつつ、広場多め・装備更新多め・スキル取得も少し増やす
  - `map_room_count_scale / map_room_size_scale / pack_large_room_bonus / item_*_tier_per_floor` を広めに動かす
- `mechanics_roguelike`
  - 選択の重みを強くしたローグライク寄り
  - 階層インフレと敵圧を上げ、シナジーが薄い build では失速しやすくする
  - `enemy_*_floor_scale / enemy_bolt_damage / spell_damage_mult / spawn_density` を build-diverse より厳しく動かす
- `mechanics_roguelike_v2`
  - `mechanics_roguelike` の floor 1 実験で skill 数が伸びなかったため追加
  - XP をさらに軽くし、広場寄り・pack 密度寄りにして選択回数を増やす
  - `levelup_xp_*`, `pack_large_room_bonus`, `item_*_tier_per_floor` を強めに動かす
- `item_spike_feedback`
  - アイテム更新の瞬間に戦闘体験が変わることを重視
  - ドロップ重みと tier 上昇を強め、`equip_upgrades` を大きく取る

## Exploration vs Build Diversity

このゲームでは `戦闘 -> アイテム更新 -> 探索` のループを短く回したいので、探索時間は主に次で制御する。

- `map_room_count_scale`
- `map_room_size_scale`
- `map_corridor_width_bonus`
- `pack_large_room_bonus`

`build_diverse_hackslash` と `item_spike_feedback` は広場寄り・大部屋寄りを許し、`mechanics_roguelike` は敵圧と floor scaling を上げて「雑に強い build」へは収束しにくくする。

## Reading Results

DuckDB で見る時は `hypothesis_name`, `run_kind`, `loss`, `floors_cleared`, `total_damage`, `near_death_rate` を先に見る。

例:

```sql
select
  hypothesis_name,
  run_kind,
  loss,
  floors_cleared,
  total_damage,
  near_death_rate
from autoplay_experiments
where experiment_id = '...'
order by hypothesis_name, run_kind;
```

見るポイント:

- `loss` だけでなく `floors_cleared` と `total_damage` を分けて見る
- `autoplay` 調整では「少し進めるが無傷ではない」状態を狙う
- `action_dense` のように `loss` は下がっても `floors_cleared` が極端に落ちるものは default 採用しない

## Current Findings

短い first-pass:

- `default`: `4.612 -> 3.569`
- `action_dense`: `5.642 -> 4.750`
- `survival_horror`: `8.879 -> 5.757`
- `speedrun`: `14.136 -> 7.719`
- `risk_reward`: `7.550 -> 5.317`
- `autoplay_rebalance`: `8.319 -> 6.226`

midgame (`start_floor=5`, `sim_max_frames=3600`) の比較では:

- `default`: `4.928 -> 2.919`
- `autoplay_progression`: `6.734 -> 4.885`
- `autoplay_progression_v3`: `7.153 -> 5.032`
- `autoplay_progression_v2`: `7.565 -> 5.192`
- `autoplay_attrition`: `8.329 -> 5.333`
- `autoplay_pressure`: `9.238 -> 6.014`
- `autoplay_rebalance`: `7.789 -> 5.374`

`autoplay_progression_v3` の詳細:

- `floors_cleared`: `1.00 -> 1.25`
- `total_damage`: `0.75 -> 2.75`
- 解釈:
  - `autoplay_progression` とほぼ同じ tuned point に収束した
  - 現状の探索条件では `progression` を置き換えるほどの差は出ていない

`autoplay_progression_v2` の詳細:

- `floors_cleared`: `1.00 -> 0.75`
- `total_damage`: `0.75 -> 4.25`
- 解釈:
  - 被弾は増えた
  - ただし floor 進行を落としすぎた
  - いまの autoplay 調整目的には少し pressure 寄りすぎる

暫定判断:

- 数値上いちばん安定しているのは `default`
- `autoplay_progression` は「進行を残しつつ被弾を増やす」方向として扱いやすい
- `autoplay_progression_v3` は比較軸としては useful だが、現状は `progression` とほぼ同じ点に収束する
- `autoplay_progression_v2` は `damage/near-death` を強める比較軸としては有効だが、現状は進行を削りすぎる
- `autoplay_pressure` は痛さは出るが進行が止まりやすい
- 現時点の本命は `autoplay_progression`

style 比較 (`start_floor=5`, `sim_max_frames=3600`) では:

- `action_dense`: `7.575 -> 5.025`, `equip 4.5 -> 2.5`, `skills 1 -> 1`
- `item_spike_feedback`: `7.548 -> 6.836`, `equip 6.75 -> 6.25`, `skills 1 -> 1`
- `build_diverse_hackslash`: `9.864 -> 6.952`, `equip 6.0 -> 0.0`, `skills 1 -> 0.75`
- `mechanics_roguelike`: `16.424 -> 9.387`, `equip 5.75 -> 2.5`, `skills 1 -> 1`

この条件では midgame 開始なので `learned_skill_count` がほぼ動かず、build diversity を見る条件としては弱い。

floor 1 からの build diversity 実験 (`start_floor=1`, `sim_max_frames=7200`) では:

- `item_spike_feedback`: `7.805 -> 6.332`, `floors 2.0 -> 3.0`, `equip 10.25 -> 9.25`, `skills 1 -> 1`
- `build_diverse_hackslash`: `36.741 -> 12.574`, `floors 2.5 -> 5.0`, `equip 9.5 -> 14.0`, `skills 1 -> 2`
- `mechanics_roguelike`: `186.841 -> 10.642`, `floors 2.0 -> 4.25`, `equip 10.75 -> 10.0`, `skills 1 -> 1`

XP 探索範囲を style 仮説ごとに狭めた再実験 (`start_floor=1`, `sim_max_frames=7200`, `max_generations=4`) では:

- `default`: `8.491 -> 2.199`, `floors 2.25 -> 5.0`, `equip 8.0 -> 4.5`, `skills 1.0 -> 1.0`
- `item_spike_feedback`: `7.970 -> 6.497`, `floors 2.0 -> 3.0`, `equip 10.25 -> 9.25`, `skills 1.0 -> 1.0`
- `build_diverse_hackslash`: `37.218 -> 10.964`, `floors 2.5 -> 3.75`, `equip 9.5 -> 10.75`, `skills 1.0 -> 2.25`
- `mechanics_roguelike`: `187.483 -> 10.742`, `floors 2.0 -> 2.0`, `equip 10.75 -> 7.75`, `skills 1.0 -> 1.0`
- `mechanics_roguelike_v2`: `73.389 -> 9.303`, `floors 2.25 -> 3.75`, `equip 8.5 -> 9.5`, `skills 1.0 -> 1.25`

`mechanics_roguelike_v2` をさらに floor 1 向けに再調整した比較では:

- `mechanics_roguelike_v2`: `72.654 -> 7.443`, `floors 2.25 -> 4.5`, `equip 9.25 -> 12.5`, `skills 1.75 -> 3.0`
- `build_diverse_hackslash`: `37.218 -> 10.964`, `floors 2.5 -> 3.75`, `equip 9.5 -> 10.75`, `skills 1.0 -> 2.25`

解釈:

- `build_diverse_hackslash` は `floor` と `equip_upgrades` を一番伸ばせた
- `mechanics_roguelike` は loss 改善幅は大きいが、skill diversity はまだ伸びていない
- `build_diverse_hackslash` は `learned_skill_count` を `2.25` まで伸ばせていて、現時点で build diversity の本命
- `mechanics_roguelike_v2` は再調整後に `learned_skill_count = 3.0` まで伸び、`build_diverse_hackslash` より選択回数が多い
- `mechanics_roguelike` 系の本命は `v2` に更新
- 現時点で「爽快感重視の build diversity」の本命は `build_diverse_hackslash`
- 「選択の重さ重視」の本命は `mechanics_roguelike_v2`

## Recommended Loop

1. midgame 圧調整は `default / autoplay_progression / autoplay_rebalance` を `start_floor=5` で回す
2. build diversity は `item_spike_feedback / build_diverse_hackslash / mechanics_roguelike` を `start_floor=1` で回す
3. promising な仮説だけ `max-generations=8` 以上に延ばす
4. `before_change` と `after_tune` の差だけでなく、`equip_upgrades / learned_skill_count / floors_cleared / total_damage` をセットで見る
5. 爽快感重視は `build_diverse_hackslash`、メカニクス重視は `mechanics_roguelike` を基準に微調整する
6. 良い候補が出たら `BalanceParams::default()` へ反映して別 commit にする

## Hypothesis-specific Param Specs

いまは仮説ごとに探索範囲を分けている。

- `default`
  - `param_specs()` を使う
  - exploratory。広く動く
- `autoplay_progression / autoplay_progression_v3 / autoplay_progression_v2`
  - `param_specs_autoplay_progression()` を使う
  - `player_speed`, `spell_damage_mult`, `enemy_bolt_damage`, `ranged_shot_cooldown` などの可動域を狭くして、floor 進行を壊しにくくする
- `autoplay_rebalance / autoplay_pressure / autoplay_attrition`
  - `param_specs_autoplay_rebalance()` を使う
  - pressure を強めにかける

この切り分けを入れた後の比較では:

- `default`: `4.928 -> 2.116`, `floors 1.00 -> 3.75`, `damage 0.75 -> 0.00`
- `autoplay_progression`: `5.852 -> 4.843`, `floors 1.00 -> 1.00`, `damage 1.75 -> 5.00`
- `autoplay_progression_v3`: `6.082 -> 5.224`, `floors 1.00 -> 1.00`, `damage 1.75 -> 2.00`
- `autoplay_rebalance`: `7.789 -> 5.374`, `floors 1.00 -> 1.00`, `damage 0.75 -> 4.25`

解釈:

- `default` は相変わらず loss を最も下げるが、playtest 目的には強すぎる方向へ動く
- `autoplay_progression` は floor を壊さず、被弾だけを増やす方向として比較的素直
- `autoplay_progression_v3` は `v3` の意図ほど差が出ていない
- 次の本命は `autoplay_progression` を基準に `param_specs_autoplay_progression()` だけを微調整すること
