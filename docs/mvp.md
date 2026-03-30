# MVP Progress (Ebiten 同等機能)

このドキュメントは、`TODO.md` から退避した完了済み項目の保管先。
`TODO.md` は未完了タスクのみを保持する。

## DONE

### 実行確認スナップショット (2026-02-21)

- `moon test --target native`: 575 passed / 0 failed
- `moon test --target js`: 574 passed / 0 failed
- `moon run src/examples/runtime_smoke --target js`: pass (`runtime_smoke(js): ok (hooked)`)
- `moon run src/examples/runtime_smoke_native --target native`: pass (hook_font_load + hook_font_load_full + hook_font_load_cjk + audio_smoke)
- `pnpm e2e:smoke`: 21 passed / 0 failed

### 機能領域 (判定: 完了)

- 固定 timestep 計画 (`step_fixed_timestep` + 単体テスト)
- CommandQueue 集約/flush（merge 条件 + explicit geometry merge + 上限）
- 画像 codec（PNG/BMP/JPEG decode/encode/resize + auto 判別 + repository helper）
- Shader frontend/hash（前処理、hash、`//kage:unit`、`//kage:noperspective`）
- Uniform 正規化（preserved/user layout 正規化 + unused 0 化 + f32 bit 変換）
- Builtin shader source（filter/address 差分 source + cache/evict + ClampToEdge + int roundtrip）
- 共通 2D payload decoder（`src/payload2d` 分離、native/web/js/wasm hooks 利用）
- AI tick 実行基盤（`run_ai_tick` + runtime hook 接続 + trace/history）
- SVG 描画（SVG -> RGBA、path 変換、stroke/fill 頂点化）
- Utility レイヤー（`vector`/`colorm`/`debugutil`/`inpututil`）

### 優先 TODO で完了済み (退避)

- P1-11: `collision3d.SpatialHashGrid::get_pairs` dense-case 改善（canonical overlap cell の start-mask で非 canonical bucket を丸ごとスキップし、scratch bench で `dense 512 = 89.86ms -> 2.16ms`、`sparse 512 = 12.13µs`）
- P0-1: native 実 backend への draw command 接続（tile/sprite/text 3 command まで smoke 検証）
- P0-2: WebGPU 実装を `WebCanvasPlatform`/`gfx` hook 経由で接続
- P0-3: WebGL2 フォールバックは非目標として確定
- P0-4: backend 共通 resize/reconfigure + no-op 抑制 + stats
- P0-5: cross-backend parity/e2e/read_pixels 検証
- P1-6: CommandQueue merge 条件の実装
- P1-7: ImageRepository + AtlasAllocator（MultiPage/compact/stats）
- P1-8: Shader frontend 強化（validation/noperspective）
- P1-9: Uniform canonicalize 強化（validation + IEEE754）
- P1-10: Builtin shader 実ソース化（MirrorRepeat/extended cache）
- P1-12: `inpututil` 相当 API + runtime 導線
- P2-15: `ui` + `mizchi/layout` input/render bridge
- P2-16: `ai.run_ai_tick` の `runtime.run_loop` 統合
- P2-18: utility 拡張テスト一式
- P2-19: mobile ターゲット戦略を 2 段階で定義（Phase 1 Web、Phase 2 Native）
- P0-20: 入力 snapshot 実機差分（TouchSource enum + NSTouch type 区別 + mouse fallback opt-in）
- P0-21: window/system API 非同期状態同期（AsyncRequestStatus + fullscreen/pointer lock ポーリング）
- P1-3: FontLoadHooks（text パッケージ hook + native C FFI + Web JS/WASM bridge）
- P1-4: Audio Web Backend（Web Audio API ScriptProcessorNode + ring buffer, JS/WASM 両対応）
- P2-1: フォント動的ロード運用検証（hook 経由 E2E + 複数サイズ glyph cache + native smoke）
- P2-2: Native Audio Backend（miniaudio + ring buffer + MoonBit FFI bridge + native hooks 接続）
- P3-2: WASM Audio Backend 接続（WASM host extern 7関数 + font stub + runtime_smoke audio smoke E2E）
- P3-1: E2E テスト拡張（WASM font load 実装 + font smoke + native hook_font_load/audio_smoke アサーション, 16 tests）
- P3-3: 複数フォント・複数サイズ本格運用（full-set TTF multi-char measure + multi-size + missing glyph degradation + atlas stress, 18 e2e tests）
- P4-1: 日本語テキスト対応（CJK サブセットフォント + multi-page atlas + eviction + CJK E2E 検証, 21 e2e tests）

### 3D / Audio (2026-02-28)

- scene3d パッケージ抽出（`src/scene3d/`）— `scene3d()` ビルダー + `render_scene3d()` + CPU 側 3D→2D 投影
- arena3d オーディオ SE 対応（サイン波 PCM 生成、Web/Native 両方で動作確認）
- MixerAudioContext ボイスライフサイクル修正（create_player の GC 問題、play の状態遷移）
- arena3d 初期化バグ修正（platform.initialize / graphics.initialize 欠落）

### scene3d / GPU レンダラー (2026-03)

- arena3d を `scene3d` API に移行（SceneGraph + GPU Z-buffer renderer）
- GPU Z-buffer レンダラー実装 (`src/gfx_webgpu/`) — painter's algorithm の精度問題を根本解決

### 3D エンジン Tier 1 (2026-03)

- 衝突判定 (collision3d) - AABB/Sphere/Ray
- 衝突判定ブロードフェーズ - SpatialHashGrid
- シーングラフ (親子階層) - 親子 Transform 伝播
- 複数光源 - PointLight, SpotLight, 複数灯対応
- glTF loader - 業界標準フォーマット対応
- テクスチャ付き 3D シェーダ (UV マッピング + sampler) — `shader3d_lit_wgsl()`
- glTF baseColorTexture の読み込み・適用 — `load_gltf()` で画像抽出 + material_texture_map
- レンダラのシェーダ自動切替 — `render_scene3d_graph_gpu` の `shader3d_textured~` 引数
- 2D スプライトのテクスチャアトラスからの描画
- PNG/JPEG/BMP デコード（`mizchi/image` パッケージ経由）
- スプライトシートアニメーション（フレーム定義 + 再生制御）— `animation2d` パッケージ
- スプライトアトラスからのリージョン切り出し — `split_sprite_sheet()`, `extract_subimage_spec()`
- アニメーションステートマシン（idle/walk/attack 等の遷移）— `SpriteAnimationStateMachine`

### 3D エンジン Tier 2 (2026-03)

- スケルタルアニメーション - ボーン, スキンメッシュ, キーフレーム補間（skeleton3d + animation3d パッケージ）
- 物理エンジン 3D - リジッドボディ, 重力, 衝突応答（physics3d: soft-constraint solver, CCD, ジョイント）
- 物理エンジン 2D - physics2d: circle/AABB/OBB 衝突, SpatialHashGrid2D broadphase, soft-constraint solver, revolute joint
- ラグドール物理 - physics2d revolute joint ベース（ragdoll_demo）
- シャドウマッピング - 深度バッファベースの影（shadow3d パッケージ: depth-to-color + PCF）
- パーティクルシステム - エフェクト（particle3d パッケージ: エミッタ, ビルボード, ハッシュ RNG）

### 3D エンジン Tier 3 (2026-03)

- PBR マテリアル - Metallic/Roughness ワークフロー（Cook-Torrance BRDF, pbr_demo）
- 法線マップ - バンプ表現（derivative-based TBN + normal map shader）
- ポストエフェクト - ブルーム, トーンマッピング (Reinhard/ACES), FXAA（postfx_demo）
- 3D オーディオ定位 - 距離減衰, パンニング（audio3d パッケージ）
- フラスタムカリング - オブジェクト単位の視錐台カリング
- LOD - 距離に応じたメッシュ切替（LodMesh, select_lod_mesh, sphere_lod）

### ARPG Phase 1 完了分 (2026-03)

- テクスチャ付き 3D lit シェーダの GPU パス統合
- GPU スキニング（第1〜2段階）
- パスファインディング — A* on Grid2D（`pathfind` パッケージ）
- 地形システム — `mizchi/terrain` Grid2D → Mesh3D 変換（`terrain3d` パッケージ）
- インスタンスレンダリング — 同一メッシュ大量描画
- シーン遷移 / ステート管理（scene_manager パッケージ）
- 非同期アセットローダー（第1段階）

### ARPG Phase 2 完了分 (2026-03)

- ECS / コンポーネントシステム（ecs パッケージ）
- 3D アニメーションステートマシン（animation3d: AnimationStateMachine3D）
- IK (Inverse Kinematics)（ik3d パッケージ）
- HUD ウィジェットフレームワーク — `src/hud/` パッケージ（HudContext, StatusBar, TextLabel, IconSlot, Panel）

## NOTE

- 現在進行中の項目は `TODO.md` を参照。
- 詳細な実装ログは Git 履歴を正とする。
