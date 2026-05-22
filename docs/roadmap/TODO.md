# TODO (kagura roadmap)

このファイルは未完了タスクのみを管理する。
完了済みは `docs/roadmap/mvp.md` の `DONE` セクションへ退避する。

3D modeling / VLM authoring 関連の未完了は `tools/modeling3d/TODO.md` で管理する。

## ゴール

- `wgpu` renderer を持つ host 上で、wasm guest として 2D/3D アプリケーションコードを動かす
- preview/HMR を強くした code-first 開発体験を作り、MoonBit を基準にしつつ同じ WIT を満たす guest を Rust / Zig にも開く
- WebGL/WebGL2 フォールバックは非目標
- Unity / Godot 風の重い統合 editor を先に作ることは非目標
- 複雑な編集 UI をそのまま利用者に露出することは非目標

## 現在のオープンタスク

### P0: Toolchain / Platform

- [x] Windows native build workaround を GitHub Actions / 実機で確定する
  CI で check + test + build が通る状態になった。`moon test --target native` を追加済み。
  実際の描画実行テストはヘッドレス GPU 不在のため CI では非対応（build 確認のみ）。

### P1: Engine Architecture

- [x] 頂点フォーマットのハードコード stride を定数化する
  `* 8` / `/ 8` リテラルを `vertex3d_stride` 定数に置換済み（gltf, mesh3d, particle3d）。
- [x] 頂点フォーマットを柔軟化する
  `VertexAttribute` enum + `VertexFormat` struct を `mesh3d` に導入。
  - `Mesh3D` に `format` フィールドを追加（デフォルト = `standard_3d`、stride 8）
  - `Mesh3D::new_with_format()` で任意フォーマットのメッシュを作成可能
  - `vertex_count()` / `compute_mesh_bounds()` が format.stride() を使用
  - `skeleton3d` の skinned buffer 構築が `VertexFormat::skinned_3d()` を使用
  - `DrawTrianglesCommand` に `vertex_stride_hint` を追加、WebGPU pipeline が hint 優先・shader regex フォールバック
  - 将来の拡張属性 (Tangent4, Color4) も enum に定義済み

### P1: Engine Performance

- [ ] `physics3d.PhysicsWorld::step` の substep hot path をさらに削る
  `raw_contacts` / `new_cache` の中継除去、sleep island 判定の `Map` → 配列化、active world での sleep island early skip、contact solve 用 cross/friction の precompute、body write の 1 回化、runtime constraint field の direct mutate、zero-angular normal/friction fast path、soft constraint 定数の step 単位 precompute、zero-torque angular integration fast path は入れた。
  `src/physics3d/world_bench.mbt` の段階 bench では `pairs dense 64 = 30-31µs`、`constraints dense 64 = 49-52µs`、`velocity dense 64 = 2.5-2.6µs`、`solve dense 64 = 75-80µs`、`solve_only dense 64 = 6.8-7.0µs`、`position dense 64 = 2.6µs`、`substeps dense 64 = 198-199µs`、`full dense 64 = 223-226µs`。
  scratch bench の全体実行は揺れるが、最新再計測は `dense 64 = 240.57µs`、`sparse 64 = 69.20µs`。残りは `solve_constraint3d` の tangent/angular path と、persistent world で意味がある broadphase / constraint バッファ再利用の切り分け。

- [ ] `scene3d` の object ごとの command 生成コストをさらに下げる
  index sort 化、white tint fast path、plain unskinned object の common-case fast path、`Transform3D::to_mat4()` の translation-only fast path、translation-only normal matrix fast path、shared light dwords + exact-size uniform packing、`transform_aabb` の temp array 削減は入れた。再計測は 1024 object で best-run `930µs`、sorted は `1.07-1.10ms` 帯。
  残りは `DstRegion` / `dst_regions` / `src_image_ids` の小配列割り当てと、PBR / skinned 経路の uniform packing。

- [ ] explicit geometry の command merge 戦略を再設計する
  `sprite2d` bench で `same_state 10000 = 2.84ms`、`alternating_texture_pages 10000 = 2.15ms`。CPU 側の全 vertex/index 連結が律速になっている。

### P2: Package Boundary / Deferred

- [ ] Paint パイプラインのモジュール分界を整理する
  **現状の問題:**
  `PaintNode → DrawTrianglesCommand` のブリッジ層が `examples/experimental/crater_paint/` に閉じており再利用できない。
  ```
  crater (セマンティクス層)
    html/css/dom → style → layout → Node + Layout ツリー
         ↓
  crater/paint (変換層) ← crater 内、crater の型にのみ依存。適切
    Node + Layout → PaintNode ツリー
         ↓
  examples/experimental/crater_paint (ブリッジ層) ← 宙ぶらりん
    PaintNode → kagura DrawTrianglesCommand
         ↓
  kagura (レンダリング層)
    DrawTrianglesCommand → wgpu GPU 描画
  ```
  **選択肢:**
  - A) kagura 側に `src/engine/crater_bridge/` を追加 — kagura が crater に依存（重い）
  - B) 独立パッケージ `mizchi/crater_paint` を新設 — crater と kagura の両方に依存するグルー
  - C) crater 側に `PaintBackend` trait を定義 — kagura 側で実装を提供（最も正しい分離）
  **前提タスク:**
  - [ ] crater を mooncakes に publish する（B, C いずれも必要）
  - [ ] `examples/experimental/crater_paint/` のローカルパス依存 (`../../../crater`) を解消
  **移動対象コード（examples/experimental/crater_paint → 新パッケージ）:**
  - `render_paint_node()` — PaintNode ツリーを再帰的に描画コマンドに変換
  - `make_draw_cmd()` / `make_draw_cmd_alpha()` — DrawTrianglesCommand 生成ヘルパー
  - `crater_color_to_hex()` — crater Color → hex 変換
  - `push_text()` — テキスト描画（TextRenderer / ドットフォント fallback）
  - `install_font_metrics_provider()` — crater レイアウト用フォントメトリクス接続
  **native_runtime_hooks の変更（済）:**
  - [x] `get_engine_context()` — ヘッドレス描画用 EngineContext 取得
  - [x] `render_frame_from_commands()` — コマンド配列から1フレーム GPU レンダリング

## ベンチマーク方針

- ベンチマークゲームは Isometric Hack & Slash ARPG を継続する
- 既存の Phase 進行、レビュー修正、周辺機能の完了分は `docs/roadmap/mvp.md` を参照する
- 新規の ARPG 固有タスクは、完了済み checklist を増やさず、このファイルの open task として再整理して追加する

## 参照

- 完了済み一覧: `docs/roadmap/mvp.md`
- 詳細な実装ログ: Git 履歴
