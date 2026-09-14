# Module Boundaries

配置は実装言語ではなく責務で決める。純粋な計算、描画・実行基盤、ゲームの意味を分離する。

| 層 | 所有するもの | 主な配置 |
| --- | --- | --- |
| `core` | 入力値と状態から結果を計算する処理。ホスト・GPU・ゲームルールに依存しない | `geom`, `mesh3d`, `physics2d`, `physics3d`, `collision3d`, `anim3d/ik3d`, `pathfind`, `terrain3d`, `procedural3d`, `hierarchy`, `inputstate` |
| `engine` | 描画コマンド、表示ツリー、アセット、音声、アプリケーションの実行 | `draw3d`, `scene3d`, `scene`, `hud`, `tilemap2d`, `sprite_packer`, `inspection`, `application`, `runtime` |
| `game` | プレイヤー・敵・アイテムなどの意味とルール、進行や遷移 | `gameplay2d`, `inventory`, `inpututil`, `ecs`, `progression`, `interactable2d`, `scene_flow`, `scene_manager`, `scene_data`, `scene_document`, `machinations`, `inventory_web` |
| `platform` | ウィンドウ・入力・surface の共通コントラクトと型付き hook | `PlatformDriver`, `WebCanvasHooks`, `DesktopNativeHooks` |
| `platform_web` | ブラウザ環境の実装と接続 | `input`, `render`, `diagnostics`, `playback`, `ui_sync`, `services`, `fetch`, `host`, `runtime_hooks` |
| `platform_native` | ネイティブ環境の実装と接続 | `gfx_wgpu_native`, `capture`, root hooks |
| `editor` | オーサリングと検証ツール | Studio、model-viewer、effect-studio、modeling3d |

`core` の「純粋」は、すべて immutable にするという意味ではない。物理 world やキャッシュなど、
呼び出し元が所有する状態の更新は許容する。時刻・乱数 seed・入力は外から渡し、ホスト FFI、
GPU リソース、描画 callback を持たせない。頂点・index の配列や骨格行列の計算は `core`、
その結果を GPU に送り描画する処理は `engine` / platform 実装が受け持つ。

`core.InputSnapshot`、サイズ、固定 timestep は共通のデータ・計算コントラクト。
`Game` / `FinalScreenDrawer` と `RunOptions` は描画・実行 callback を持つため
`mizchi/kagura_engine/application` に配置する。ゲームルールを持たない実行契約なので、
`game` への逆依存は作らない。

`game/ecs` は Health・Player/Enemy タグ・死亡処理を含むゲーム用 world。
`engine/scene` は 2D の表示ツリーで、`engine/scene2d` は表示ドキュメント。
`game/scene_flow` / `scene_manager` は遷移、`scene_data` / `scene_document` は
プレイヤー・敵・障害物・ポータルに結びつく定義を所有する。

入力の押下差分・押下時間は `core/inputstate`。WASD の移動や決定キーの解釈と
`InputHelper` は `game/inpututil` が所有する。UI と実行ループは core の入力状態だけを参照する。

## 依存方向

```text
core ← engine ← game
  ↑       ↑
platform contract
  ↑       ↑
platform implementations / startup integration
```

- `core` は別の core module と宣言済みの計算ライブラリだけを参照する。
- `engine` は core / engine / platform contract を参照でき、game や platform 実装を参照しない。
- `game` は core / engine / game / platform contract を参照できる。
- `platform` は実装に依存しない。`platform_web` の基礎 adapter は core と contract のみに依存する。
- `platform_web/runtime_hooks` と `platform_native` は起動時の統合 module。
  engine・音声・描画の hook を結線するため engine を参照できるが、game には依存しない。
- `editor` は利用側。ライブラリから editor への参照は禁止する。

`gfx_wgpu_native` とネイティブキャプチャは、既存の `mizchi/native_runtime_hooks`
module 内に置く。共通 prebuild 変数を同じ module で解決できるため、独立 module 化時に
問題になった変数のスコープを回避する。engine は backend 実装を import せず hook を使う。

## モジュールと配布

ディレクトリと配布単位は別。正しい名前は各 `moon.mod` の `name`。

| 配置 | モジュール名 |
| --- | --- |
| `core` | `mizchi/kagura_core` |
| `core/geom`, `core/mesh3d`, `core/anim3d`, `core/pathfind` | `mizchi/geom`, `mizchi/mesh3d`, `mizchi/anim3d`, `mizchi/pathfind` |
| `engine` | `mizchi/kagura_engine` |
| `engine/ui`, `engine/audio`, `engine/asset_loader` | `mizchi/kagura_ui`, `mizchi/kagura_audio`, `mizchi/kagura_asset_loader` |
| `engine/renderer2d`, `text`, `atlas`, `widget2d` | 同名の `mizchi/*` module |
| `game`, `game/machinations` | `mizchi/kagura_game`, `mizchi/machinations` |
| `platform` | `mizchi/kagura_platform` |
| `platform_web`, `platform_web/runtime_hooks` | `mizchi/kagura_platform_web`, `mizchi/web_runtime_hooks` |
| `platform_native` | `mizchi/native_runtime_hooks` |

入れ子の独立 module は親の配布物に含めない。`just release-stage` で配布内容を確認する。
ブラウザ配信用には `just web-runtime-build` が二つの ESM を生成する。

- `platform_web/web_core` → `assets/web/kagura-runtime.generated.js`
- `game/inventory_web` → `assets/web/kagura-inventory.generated.js`

両方に `.d.ts` の契約と生成元ハッシュを持ち、ゲーム・Studio・Pages の同じ配布 manifest で扱う。

## 自動検証

`just check-release` で次を検証する。

- `moon-layer-utils.mjs`：全 workspace member の manifest と `moon.pkg` を検査。
  入れ子の独立 module、外部 gfx への core 依存、core のホスト FFI も対象。
- `moon-boundary-utils.mjs` / `moon-release-utils.mjs`：公開 module の import / version / staging 境界。
- `repository-layout.test.mjs`：責務の所属、親の配布物への子 module 混入、各 workspace の依存参照漏れ。
- `platform-layout.test.mjs`：共通 contract と実装の配布分離、native prebuild の参照。

移動時は MoonBit import、module 依存、全 `moon.work`、justfile、配布・ビルドスクリプト、
生成インターフェース、ドキュメントを同時に更新する。公開 import の移行一覧は以下。

| 旧 import | 新 import |
| --- | --- |
| `mizchi/physics/{physics2d,physics3d,collision3d}` | `mizchi/kagura_core/` の同名 package |
| `mizchi/kagura_core/inpututil` | 入力状態は `mizchi/kagura_core/inputstate`、ゲーム操作は `mizchi/kagura_game/inpututil` |
| `mizchi/kagura_core.Game` / `RunOptions` 等 | `mizchi/kagura_engine/application` の同名契約 |
| `mizchi/kagura_game/ik3d` | `mizchi/anim3d/ik3d` |
| `mizchi/kagura_game/terrain3d` | `mizchi/kagura_core/terrain3d` |
| `mizchi/kagura_engine/procedural3d` | `mizchi/kagura_core/procedural3d` |
| `mizchi/kagura_game/{scene,scene2d,hud,tilemap2d,sprite_packer,inspection}` | `mizchi/kagura_engine/` の同名 package |
| `mizchi/kagura_engine/gfx_wgpu_native` | `mizchi/native_runtime_hooks/gfx_wgpu_native` |
| `mizchi/kagura_engine/capture/native` | `mizchi/native_runtime_hooks/capture` |
| `mizchi/kagura_platform_js` | `mizchi/kagura_platform_web` |

骨格・経路探索の独立 module 名は維持する。物理は `mizchi/kagura_core` に統合する。互換のため core から engine へ
再 export するような逆依存は作らず、利用側の import を更新する。

## パッケージ内部の責務分割

| 型・処理 | 所有者 |
| --- | --- |
| 時計・ファイル I/O・フレーム予約の契約 | `platform/services` |
| BytesFetcher / FetchProgress / FetchHandle | `platform/fetch`（旧 atlas） |
| 実時計・ファイルアクセス | `platform_native/services`、`platform_web/services` |
| ブラウザ通信・キャンセル | `platform_web/fetch` |
| ロード待ち行列・画像デコード・アトラス | `engine/asset_loader`、`engine/atlas` |
| GridFootprint / ItemGrid・配置プレビュー・比較 | `game/inventory`（旧 gameplay2d / inventory_web） |
| JS オブジェクトとの変換 | `game/inventory_web` |
| Timeline・再生時間の進行 | `core/anim3d/playback` |
| 矩形パッキング・粒子の運動・統計 | `core/packing2d`、`core/particle3d`、`core/statistics` |
| 粒子の描画・sprite と atlas の対応付け | `engine/particle3d`、`engine/sprite_packer`、`engine/animation2d` |

再生時間は独立 anim3d module 内に置き、core root → anim3d の既存依存を逆転させない。
`Timeline` の完了時停止と端点保持は用途別に選べる。2D の繰り返し減算による丸めも保持する。

`engine.particle3d.build_billboard_vertices(emitter, ...)` は描画側の関数。
以前の `emitter.build_billboard_vertices(...)` の利用側はこの関数へ移行する。
`ParticleEmitter` の状態と更新メソッドは core の型を engine が再公開する。

`assets/web` は配布先。手書き JS と Node テストは `platform_web/host`、型宣言の原本は
各 ESM entry package の `exports.d.ts`。ビルドはローカルの推移的な依存を hash と監視に含む。
`benchmarks/landscape` と `experiments/webgpu` は非公開の利用側であり、ライブラリから参照しない。
