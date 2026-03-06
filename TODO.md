# TODO (Ebiten 同等機能ロードマップ)

このファイルは未完了タスクのみを管理する。
完了済みは `docs/mvp.md` の `DONE` セクションへ退避。

## ゴール再確認

- 目標: 2D/3D 両対応のゲームエンジンを MoonBit で提供する
- 優先: WebGPU (browser) と native wgpu (macOS) で同一ゲームロジックを早期に動かす
- 非目標: WebGL/WebGL2 フォールバック

## 現在の優先タスク (優先順位順)

### Windows / Linux Native 対応

現在 Native ビルドは macOS のみ対応。wgpu-native と GLFW 自体は Windows/Linux をサポートしているため、以下の対応で拡張可能:

- [ ] `scripts/setup-wgpu-native.sh` を Windows (MSYS2/MinGW) / Linux に対応
- [ ] `moon.pkg` の `cc-link-flags` をプラットフォーム別に分岐（macOS: Metal frameworks、Linux: Vulkan + X11/Wayland、Windows: D3D12/Vulkan）
- [ ] Audio バックエンドの抽象化（現在 AudioToolbox に依存 → Linux: PulseAudio/ALSA、Windows: WASAPI）
- [x] CI に `native-linux` / `native-windows` ジョブ追加（moon check のみ）

### scene3d API 改善

- [x] arena3d を `scene3d` API に移行（SceneGraph + GPU Z-buffer renderer）

### GPU Z-buffer レンダラー

- [x] GPU Z-buffer レンダラー実装 (`src/gfx_webgpu/`) — painter's algorithm の精度問題を根本解決

## 3D ゲームエンジン拡張ロードマップ

### Tier 1: 最低限のゲーム制作に必要

- [x] 衝突判定 (collision3d) - AABB/Sphere/Ray
- [x] 衝突判定ブロードフェーズ - SpatialHashGrid
- [x] シーングラフ (親子階層) - 親子 Transform 伝播
- [x] 複数光源 - PointLight, SpotLight, 複数灯対応
- [x] glTF loader - 業界標準フォーマット対応
- [ ] glTF/OBJ ローダーを別パッケージに切り出し（mizchi/glfw と同様に mooncakes 化）

### テクスチャ付きレンダリング

- [x] テクスチャ付き 3D シェーダ (UV マッピング + sampler) — `shader3d_lit_wgsl()`
- [x] glTF baseColorTexture の読み込み・適用 — `load_gltf()` で画像抽出 + material_texture_map
- [x] レンダラのシェーダ自動切替 — `render_scene3d_graph_gpu` の `shader3d_textured~` 引数
- [x] 2D スプライトのテクスチャアトラスからの描画

### 画像フォーマット対応

`mizchi/image` パッケージ経由で対応済み。

- [x] PNG デコード（RGBA ピクセルデータ取得）
- [x] JPEG デコード
- [x] BMP デコード
- [ ] WebP デコード（オプション）

### 2D アニメーション

- [x] スプライトシートアニメーション（フレーム定義 + 再生制御）— `animation2d` パッケージ
- [x] スプライトアトラスからのリージョン切り出し — `split_sprite_sheet()`, `extract_subimage_spec()`
- [x] アニメーションステートマシン（idle/walk/attack 等の遷移）— `SpriteAnimationStateMachine`

### Tier 2: まともな 3D ゲームに必要

- [x] スケルタルアニメーション - ボーン, スキンメッシュ, キーフレーム補間（skeleton3d + animation3d パッケージ, skeletal_anim デモ）
- [x] 物理エンジン 3D - リジッドボディ, 重力, 衝突応答（physics3d: soft-constraint solver, CCD, ジョイント）
- [x] 物理エンジン 2D - physics2d: circle/AABB/OBB 衝突, SpatialHashGrid2D broadphase, soft-constraint solver, revolute joint
- [x] ラグドール物理 - physics2d revolute joint ベース（ragdoll_demo）
- [x] シャドウマッピング - 深度バッファベースの影（shadow3d パッケージ: depth-to-color + PCF）
- [x] パーティクルシステム - エフェクト (煙, 火, 爆発)（particle3d パッケージ: エミッタ, ビルボード, ハッシュ RNG, particle_demo）

### Tier 3: 品質向上

- [x] PBR マテリアル - Metallic/Roughness ワークフロー（Cook-Torrance BRDF, pbr_demo）
- [x] 法線マップ - バンプ表現（derivative-based TBN + normal map shader）
- [x] ポストエフェクト - ブルーム, トーンマッピング (Reinhard/ACES), FXAA（postfx_demo）
- [x] 3D オーディオ定位 - 距離減衰, パンニング（audio3d パッケージ: Inverse/Linear/Exponential 減衰, ステレオ pan, set_pan 追加）
- [x] フラスタムカリング - オブジェクト単位の視錐台カリング
- [x] LOD - 距離に応じたメッシュ切替（LodMesh, select_lod_mesh, sphere_lod）

## ベンチマークゲーム: Isometric Hack & Slash ARPG

Path of Exile スタイルの斜め見下ろしアクション RPG をターゲットに開発を進める。

- **視点**: 固定カメラ斜め見下ろし（クォータービュー）
- **ビルド**: 近接ビルド / 魔法ビルド / 召喚ビルド
- **システム**: スキルツリー、装備、ルート、マップ生成
- **地形**: `mizchi/terrain` を使用 or 参考にした procedural 地形生成

### ARPG 実現に必要な機能 (優先順位順)

#### Phase 1: 最小プレイアブル

- [x] テクスチャ付き 3D lit シェーダの GPU パス統合 — `render_scene3d_gpu` で textured/PBR shader 自動選択（Material 拡張 + shader3d_textured/pbr/pbr_textured パラメータ）
- [x] GPU スキニング（第1段階）— CPU `apply_skin` を廃止し、`render_scene3d_gpu` の skinned shader パスへ移行（多数の敵表示の基盤）
- [x] GPU スキニング最適化（第2段階）— WebGPU で skinned command をコンピュートシェーダ事前スキニング（prepacked 頂点キャッシュ + pre-skinned 描画分岐）
- [x] パスファインディング — A* on Grid2D（`pathfind` パッケージ, Manhattan heuristic, カスタム walkable 関数）
- [x] 地形システム — `mizchi/terrain` Grid2D → Mesh3D 変換（`terrain3d` パッケージ）+ terrain_demo（BSP ダンジョン + A* パス表示）
- [x] インスタンスレンダリング — 同一メッシュ大量描画（敵の群れ、パーティクル）（DrawTrianglesCommand instance_count + WGSL instanced shader + SceneGraph 統合）
- [x] シーン遷移 / ステート管理 — タイトル → ゲーム → リザルト、マップ間遷移（scene_manager パッケージ: Scene trait + SceneManager + フェード遷移）
- [x] 非同期アセットローダー（第1段階）— 非同期キュー/進捗/完了通知 + リポジトリ反映（ロード画面の基盤）
- [ ] 非同期アセットストリーミング（第2段階）— チャンク読み込みと優先度制御（遠景/近景の段階ロード）

#### Phase 2: ゲームシステム

- [x] ECS / コンポーネントシステム — エンティティ管理（敵、プレイヤー、ドロップアイテム、投射物）（ecs パッケージ: Map ベース World + クエリ + movement/death/physics sync システム）
- [x] 3D アニメーションステートマシン — idle/walk/attack/cast/death のブレンド遷移（animation3d: AnimationStateMachine3D）
- [x] IK (Inverse Kinematics) — 武器持ち替え、地形追従（ik3d パッケージ）
- [ ] スプライトシート自動生成 — UI アイコン、スキルアイコン用テクスチャアトラス
- [ ] UI フレームワーク — HP バー、スキルバー、インベントリ、スキルツリー画面
- [ ] セーブ / ロード — キャラクターデータ、進行状況の永続化

#### Phase 3: 品質・スケール

- [ ] オクルージョンカリング — 大規模マップでの描画負荷軽減
- [ ] PBR 拡張 (IBL, SSR, SSAO) — 環境マッピング、スクリーンスペース反射
- [ ] ネットワーク同期 — マルチプレイヤー対応（WebSocket / WebRTC）
- [ ] プロファイラ — フレーム時間、ドローコール、メモリ使用量の可視化
- [ ] ホットリロード — WASM モジュール差し替えによるイテレーション高速化
- [ ] ビジュアルエディタ — シーン配置、パラメータ調整 GUI

## アーキテクチャ課題

- CPU ラスタライザ → GPU パイプライン移行: scene3d は CPU で頂点変換して 2D コマンドに変換している。`src/gfx_webgpu/` で GPU Z-buffer レンダラーを実装済み、段階的に移行
- 頂点フォーマットの柔軟化: 現在 stride=8 固定。スキンメッシュではボーンウェイトが必要

## テスト・CI

- [x] Playwright VRT（Visual Regression Testing）— 17 examples の描画スナップショット自動検証
- [x] moon test: 999 テスト（js target）
- [x] CI: js / native-linux / native-windows / native-macos 4 ジョブ

## 参照

- 完了済み一覧: `docs/mvp.md`
