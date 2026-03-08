# TODO (kagura roadmap)

このファイルは未完了タスクのみを管理する。
完了済みは `docs/mvp.md` の `DONE` セクションへ退避。

## ゴール再確認

- 目標: `wgpu` を renderer とする host 上で、wasm guest として 2D/3D アプリケーションコードを動かす
- 優先: preview/HMR を強くした code-first 開発体験を作り、MoonBit を基準にしつつ同じ WIT を満たす guest を Rust / Zig にも開く
- 非目標: WebGL/WebGL2 フォールバック
- 非目標: Unity / Godot 風の重い統合 editor を先に作ること
- 非目標: 複雑な編集 UI をそのまま利用者に露出すること

## 現在の優先タスク (優先順位順)

### Host / Guest / HMR 方針の固定

- [x] `wgpu` renderer を host 側に固定し、guest には GPU API を直接見せない — 描画境界は `render commands` / `render graph` 相当の ABI に閉じる
- [x] wasm guest ABI v0 を WIT で定義する — `init` / `update` / `render` / `input` / `audio` / `asset` / `hot_reload` / `shutdown` の責務を明文化する
- [x] MoonBit guest を基準実装にする — 同じゲームロジックが wasm guest として動き、preview host から読み込める最小 vertical slice を作る
- [x] Rust / Zig guest の疎通サンプルを作る — 同じ WIT を満たす最小 guest を 1 本ずつ用意し、多言語対応を設計ではなく実動作で固定する
- [x] HMR 戦略 v0 を決める — まず full reload を基準にし、必要なら guest state の `serialize/restore` または migration hook を後付けできる形にする
- [x] preview-first の host shell を作る — canvas/window preview、log、error overlay、reload 状態、fps/stats を一画面で見られるようにする

### Editor / AI Authoring 方針

- [x] editor 統合は preview/inspect/debug を主目的にする — scene preview、asset preview、state inspect、input replay を優先し、複雑な direct manipulation UI は後回しにする
- [x] 複雑な編集操作は AI 経由を前提に設計する — prompt -> patch -> preview -> diff -> rollback の流れを先に作り、GUI authoring を増やし過ぎない
- [x] AI 編集の安全面を整える — file diff、runtime diff、snapshot diff、undo/redo、failure surface を host 側で可視化する
- [x] code-first authoring の参照実装を整える — scene、UI、animation、asset wiring を「コードでどう書くか」のテンプレートとして提供する

### コードレビュー起因の修正項目 (performance / API)

- [x] `runtime.run_loop` を実時間 delta で駆動し、`step_fixed_timestep` へ固定値 `16.6667ms` を渡す実装を廃止する
- [x] 低レベル API 契約の no-op を解消する — `Game.layout` の `LogicalSize`、`RunOptions.init_unfocused`、`RunOptions.screen_cleared_every_frame` を実行系に反映する
- [x] `AssetStreamer.request` の重複要求を callback fan-out 対応する — 同一 asset を待つ全 caller が `on_complete` を受け取れるようにする
- [x] `@scene` の宣言的 API の内部表現を見直す — 毎フレームの `view()` 再構築・文字列属性化・再パースを減らし、利用者向け API と内部契約の型ズレを縮小する
- [x] `scene3d` のフラスタムカリングを最適化する — mesh ごとの AABB をキャッシュし、毎フレーム・毎オブジェクトの全頂点走査を避ける
- [x] `scene3d.sort_bias` の扱いを確定する — renderer で意味を持たせるか、公開 API から整理する
- [x] `@engine.run` / `@scene.run` の更新と音声進行を frame-driven から切り離す — FPS に応じて `update` 回数や BGM フェード速度が変わらないよう、runtime と同じ時間基準へ寄せる
- [x] 高レベル実行 API のリサイズ契約を成立させる — `EngineContext.screen_w/screen_h`、描画先 `dst`、logical size を実ウィンドウ/canvas サイズ変更に追従させる
- [x] `engine.run` の失敗処理を整理する — `GraphicsDriver::new_shader` に title を渡す暫定実装をやめ、initialize/new_image/new_shader/draw の失敗を握り潰さず利用者に見える形で扱う
- [x] 高レベル描画パスの clear 契約を露出する — `debugutil.render_commands` の黒クリア固定を見直し、transparent / preserve framebuffer 相当の設定を上位 API から制御できるようにする
- [x] `gfx.new_command_queue()` の公開 API を整理する — 常に `panic()` する exported constructor を削除・非公開化・具体型 factory へ置き換える
- [x] `AssetStreamer` の完了 payload 保持戦略を見直す — duplicate callback 対応のために保持している `Bytes` が eviction まで居座らないよう、メモリ上限と cache 層の責務を整理する

### 全体レビュー起因の中期タスク (test / performance / product)

#### テスト品質

- [x] テストピラミッドを再整理する — `wbtest` は厚い一方、`@scene.run` / `@engine.run` / asset loading / audio / resize / platform 初期化をまたぐ黒箱統合テストが薄い。利用者が踏む主要経路を js/native 両方で固定する
- [x] coverage を CI に組み込む — `moon coverage analyze` を定常運用し、`core` / `runtime` / `platform` / `gfx` / `scene` / `asset_loader` など壊れると影響が大きいパッケージに下限を置く
- [x] bench を回帰ゲート化する — 既存の `ecs` / `sprite2d` / `text` / examples の benchmark に基準値を持たせ、PR ごとに悪化率を検知する
- [x] VRT の運用を「更新できる」から「壊れた理由を判断できる」に進める — 主要 example を基準シーン化し、rendering change / backend bug / snapshot drift を切り分けやすくする
- [x] 失敗系テストを増やす — WebGPU unsupported、shader compile failure、device lost、audio init failure、resize failure など「起動はするが正しく動かない」経路を contract/E2E で固定する

#### パフォーマンスと計測

- [x] host / guest 間の ABI コストを計測する — frame ごとの call 回数、command size、copy byte 数、serialization コストを見えるようにして wasm 境界のボトルネックを早期に潰す
- [x] `runtime` / `engine` / `scene` の実行系を一本化する — fixed timestep、resize、clear、audio tick、frame stats の時間基準を揃え、利用レイヤーで性能特性が変わらないようにする
- [x] 標準の profiler / stats HUD を用意する — frame time、update/draw 内訳、draw calls、buffer upload、atlas 使用率、asset inflight 数を実ゲーム上で可視化する
- [x] benchmark KPI を決める — 2D（sprite/text/tilemap）、3D（scene3d/shadow/postfx）、ゲーム例（flappy/survivor/action_rpg/arena3d）ごとに「何 fps / 何 ms / 何 draw call まで許容か」を決める
- [x] アセット常駐戦略を分離する — raw bytes cache、decode 済み image、GPU resource の責務と budget を分け、streaming 最適化がそのままメモリリーク様の挙動にならないようにする
- [x] クロスバックエンド性能比較の基準シーンを作る — browser / native で同一シーンの update・render コストを比較できるようにして、最適化の優先順位を誤らないようにする

#### 将来の伸び代

- [x] 公開 API を tier 分けする — `stable` / `experimental` / `internal` を package ごとに明示し、`@scene` / `@engine` / `scene3d` / `physics3d` / `postfx` などの利用期待値を揃える
- [x] host API と guest ABI を分離して設計する — MoonBit のライブラリ API と、wasm 越しに多言語 guest へ公開する WIT を同一視しない
- [x] README / user docs / CI / 実装のサポートマトリクスを同期する — native Linux/Windows や high-level API の実態と記述のズレを減らし、利用者が判断を誤らないようにする
- [x] content pipeline を整備する — glTF / texture / shader / atlas / font の import・前処理・cache・hot reload を個別機能ではなく一連の制作フローとしてまとめる
- [x] preview-first tooling を強化する — scene graph inspector、draw call viewer、asset viewer、input record/replay、shader reload を host shell に寄せて「動く」から「調べられる」へ進める
- [x] serialization / prefab 相当 / scene authoring を設計する — 大きいゲームで必要になるデータ駆動構成を MoonBit 側の型と整合する形で定義する
- [x] テンプレートと参照ゲームを育てる — 2D 最小ゲーム、UI-heavy、top-down action、3D sample を「おすすめの書き方」の見本として維持する

#### vs Unity / vs Godot

- [x] Unity / Godot と競う軸を先に固定する — editor の総量ではなく、「code-first」「AI-assisted editing」「small API surface」「wasm guest」「web/native parity」を主戦場にする
- [x] 重い統合 editor を追わず、preview host + AI authoring で代替する方針を固める — 複雑な direct manipulation は最小限に留める
- [x] Unity / Godot で当たり前の不足機能を棚卸しして優先順位を付ける — profiler、inspector、import pipeline、animation authoring、scene serialization、build/export workflow のうち、preview-first 戦略に効くものから段階導入する
- [x] Unity / Godot からの移行導線を作る — Blender / glTF / Tiled / Aseprite など既存資産の import、入力/シーン/Prefab 相当の対応表、実例付きチュートリアルを用意する
- [x] まず勝てるユースケースを狭く定める — 2D ゲーム、軽量 3D、web 配布、AI と一緒にコード編集する開発フロー、MoonBit/Rust/Zig の guest 差し替え実験など、Unity/Godot より速く価値を出せる領域から厚くする

### Windows / Linux Native 対応

Surface 作成のクロスプラットフォーム化と CI 整備は完了。残タスク:

- [x] Surface 作成を macOS/Linux(X11)/Windows(Win32) に分岐 — `wgpu_native_stub.c` + `_macos.m` 分離
- [x] CI: native-linux に wgpu-native + GLFW + X11 セットアップ追加、テスト・ビルド通過
- [x] CI: native-windows に wgpu-native セットアップ追加、`moon check` 通過
- [ ] Windows `moon build`: MoonBit ランタイムが `-lm` を無条件付加する問題の上流修正待ち
- [ ] Audio バックエンドの抽象化（現在 AudioToolbox に依存 → Linux: PulseAudio/ALSA、Windows: WASAPI）

### 残タスク (3D エンジン)

- [ ] glTF/OBJ ローダーを別パッケージに切り出し — 後回し: 現状 mesh3d/scene3d/skeleton3d/animation3d 等 6 パッケージに依存しており、基盤パッケージの独立とテクスチャパイプライン安定後に着手

## ベンチマークゲーム: Isometric Hack & Slash ARPG

Path of Exile スタイルの斜め見下ろしアクション RPG をターゲットに開発を進める。

- **視点**: 固定カメラ斜め見下ろし（クォータービュー）
- **ビルド**: 近接ビルド / 魔法ビルド / 召喚ビルド
- **システム**: スキルツリー、装備、ルート、マップ生成
- **地形**: `mizchi/terrain` を使用 or 参考にした procedural 地形生成

### ARPG 残タスク (優先順位順)

#### Phase 1: 最小プレイアブル

- [x] 非同期アセットストリーミング（第2段階）— `AssetStreamer` 高レベル API（距離ベース優先度、LOD、LRU eviction、`on_frame` エンジン統合）

#### Phase 2: ゲームシステム

- [x] スプライトシート自動生成 — UI アイコン、スキルアイコン用テクスチャアトラス
- [x] UI フレームワーク — インベントリ、スキルツリー画面（インタラクティブ UI は `src/ui/` を拡張）
- [x] セーブ / ロード — キャラクターデータ、進行状況の永続化

#### Phase 3: 品質・スケール

- [x] オクルージョンカリング — ルームベース可視判定 + エンティティ距離カリング
- [ ] PBR 拡張 (SSAO) — シェーダー・ターゲット・カメラ深度定義済み、レンダーパス未接続（IBL/SSR は後回し）
- [x] プロファイラ — F3 キーで FPS/draw calls/vertex count/frame time 表示
- [x] ホットリロード — Vite ベース dev サーバー + .mbt 変更検知 full-reload

#### ARPG バグ・改善 (レビュー起因)

- [x] DEF が被ダメージに反映されない — 敵接触・弾丸ダメージで `player_stats.def` を減算していない
- [x] DashMastery がハードコード定数を使用 — `dash_cooldown` 定数ではなく `player_stats.dash_cooldown` を参照すべき
- [x] Whirlwind スキルの効果未実装 — SP 消費するが攻撃に変化なし
- [x] `player.max_hp` vs `player_stats.max_hp` 二重管理 — HP 回復で旧 max_hp(10) を参照する箇所あり
- [x] SSAO が light-space depth を使用 — カメラスペース深度バッファが必要
- [x] ゲームオーバーでセーブ未削除 — 死んでも旧セーブから復活できる
- [x] インベントリ満杯時のアイテム消失 — ドロップ通知なし、地面に落とす処理もなし
- [ ] アイコンアトラスが未使用 — `create_icon_atlas()` がどこからも呼ばれていない

## アーキテクチャ課題

- [x] CPU ラスタライザ → GPU パイプライン移行: CPU painter's algorithm 削除済み、全 example が GPU Z-buffer レンダラーに統一
- 頂点フォーマットの柔軟化: 現在 stride=8 固定。スキンメッシュではボーンウェイトが必要

## テスト・CI

- [x] Playwright VRT（Visual Regression Testing）— 17 examples の描画スナップショット自動検証
- [x] moon test: 1150 テスト（js target）
- [x] CI: js / native-linux / native-windows / native-macos 4 ジョブ

## 参照

- 完了済み一覧: `docs/mvp.md`
