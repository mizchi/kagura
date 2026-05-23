# Future Roadmap: Design Decisions

TODO.md「将来の伸び代」の方針決定。

## Content Pipeline

glTF / texture / shader / atlas / font の import -> 前処理 -> cache -> hot reload を統一フローにまとめる。

**方針:**
- `moon build` の前段として asset preprocessor を配置しない (ビルド複雑化を避ける)
- runtime での lazy decode を維持: fetch -> decode -> GPU upload の 3 段パイプライン
- hot reload は dev server (Vite) のファイル監視に委ねる
- atlas packing は `sprite_packer` で build 時に実行、結果を JSON + PNG で配布

**非目標:**
- Unity-style asset database
- binary asset bundle format (当面は個別ファイル)

## Preview-First Tooling

host shell に計測・デバッグ機能を集約する。

**実装済み:**
- scene preview (canvas + WebGPU)
- frame stats (FPS, draw calls, vertices, redraw)
- ABI boundary stats (update/render timing, serialize/deserialize cost, byte sizes)
- pause / step controls
- error overlay + HMR state
- log panel

**次のステップ (優先順):**
1. draw call viewer — 各 draw command の src image, vertex count, uniform を一覧表示
2. asset viewer — ロード済み asset のサムネイル + metadata
3. input record/replay — input snapshot 列を JSON で保存・再生
4. shader reload — WGSL 変更時に shader のみ hot reload

## Serialization / Prefab / Scene Authoring

大規模ゲームでのデータ駆動構成。

**方針:**
- MoonBit の struct literal がそのまま prefab 相当 (code-first)
- JSON schema による外部データ定義は `@scene` の属性値として読み込む
- バイナリ serialization は WASM guest の snapshot/restore ABI で対応済み
- GUI scene editor は作らない (AI authoring で代替)

## テンプレートと参照ゲーム

| テンプレート | 対応 example | 目的 |
|------------|-------------|------|
| 2D 最小ゲーム | `flappy_bird` | `@scene.run` の最小構成 |
| UI-heavy | `ui_demo` | `@ui` レイアウト + インタラクション |
| Top-down action | `action_rpg` / `survivor` | `@physics2d` + `@sprite2d` + `@camera2d` |
| 3D sample | `arena3d` / `hacknslash_3d` | `@scene3d` + `@physics3d` + `@postfx` |
| WASM guest | `wasm_game/guest/moonbit` | host-guest binary protocol |

各 example を「おすすめの書き方」として docs/tools/editor-authoring.md の code-first テンプレートと対応付ける。
