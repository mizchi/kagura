# API Tiers

package ごとの安定性レベル。利用者が依存判断できるよう tier を明示する。

## Tier A: Stable (API 変更は semver major)

ゲーム開発の基本ループに必要な package。

| Package | 説明 |
|---------|------|
| `core` | Game trait, InputSnapshot, FixedStepConfig, FrameBudget |
| `scene` | 宣言的シーン API (`@scene.run`, `@scene.rect`, `@scene.label`) |
| `vector` | Vec2 演算 |
| `math3d` | Vec3, Mat4, Quaternion |
| `gfx` | DrawTrianglesCommand, ShaderHandle, ImageHandle |
| `platform` | PlatformDriver, OutsideSize |
| `inpututil` | just-pressed / just-released 検出 |
| `colorm` | Color 変換 |

## Tier B: Stable Features (API 安定だが拡張あり)

特定機能領域の package。API は安定しているが新機能追加で型が増える可能性あり。

| Package | 説明 |
|---------|------|
| `sprite2d` | スプライト描画 + atlas |
| `tilemap2d` | タイルマップ |
| `camera2d` | 2D カメラ |
| `animation2d` | 2D アニメーション |
| `physics2d` | 2D 物理 (rigid body, broadphase, CCD) |
| `draw2d` | 低レベル 2D 描画 |
| `payload2d` | hitbox / payload |
| `scene3d` | 3D シーングラフ |
| `mesh3d` | メッシュ |
| `camera3d` | 3D カメラ |
| `transform3d` | Transform |
| `skeleton3d` | スケルトン |
| `animation3d` | 3D アニメーション |
| `collision3d` | 3D 衝突検出 |
| `physics3d` | 3D 物理 |
| `light3d` | ライティング |
| `shadow3d` | シャドウ |
| `particle3d` | パーティクル |
| `text` | テキスト描画 |
| `ui` | UINode, layout |
| `audio` | オーディオミキサー |
| `audio3d` | 3D 空間オーディオ |
| `asset` | アセットリポジトリ |
| `asset_loader` | ストリーミングローダー |
| `svg` | SVG レンダリング |

## Tier C: Experimental (API 変更あり)

新しい機能。フィードバックに応じて API が変わる可能性あり。

| Package | 説明 |
|---------|------|
| `ecs` | Entity Component System |
| `sprite_packer` | スプライトシートパッキング |
| `scene_manager` | シーン遷移管理 |
| `postfx` | ポストプロセス (Bloom, Tonemap, FXAA) |
| `ik3d` | Inverse Kinematics |
| `gltf` | glTF ローダー |
| `pathfind` | パスファインディング |
| `terrain3d` | 地形レンダリング |
| `hud` | HUD ユーティリティ |

## Tier D: Internal (直接使用非推奨)

エンジン内部実装。利用者は上位 API を使うべき。

| Package | 説明 |
|---------|------|
| `engine` | 内部ゲームループ実行 (JS/native 分岐) |
| `runtime` | 低レベルループ実行 |
| `gfx_wgpu_native` | wgpu-native FFI バックエンド |
| `image_palette` | 内部パレットユーティリティ |
| `debugutil` | デバッグ描画 (開発時のみ) |
| `ai` | AI 統合ブリッジ (実験的) |
