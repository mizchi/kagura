# AI Contract Draft

`src/ai/contracts.mbt` の設計意図。

## Goals

- 固定 tick で再現可能な AI 実行
- policy 実装（rule-based / behavior-tree / model-based）の差し替え
- world 実装と AI ロジックを分離

## Contract Split

1. `SensorBridge`
   - world 依存の情報収集層
   - `AgentId + tick -> SensorSnapshot`
2. `AIPolicy`
   - pure decision 層
   - `DecisionContext -> DecisionResult`
3. `ActuatorBridge`
   - world 更新層
   - `ActionIntent[]` を実 world の command へ変換
4. `AIScheduler`
   - どの agent を今 tick で更新するかを決める
   - budget を agent ごとに配布

## Determinism Rules

- `DecisionContext` に `deterministic_seed` を必ず入れる
- 外部 I/O は `SensorBridge` で完結させる
- `AIPolicy` 本体は与えられた context のみで決定する

## Runtime Integration

- `runtime` 側で update の先頭で `run_ai_tick` を呼ぶ
- `run_ai_tick` は blackboard を返し、次 tick へ引き継ぐ
- 描画や GPU 状態は AI モジュールから参照しない
