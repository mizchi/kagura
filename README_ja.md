# kagura

[MoonBit](https://www.moonbitlang.com/) 向け 2D（将来 3D）ゲームエンジン。[Ebiten](https://github.com/hajimehoshi/ebiten) の設計に着想を得ています。

[English](README.md)

## 特徴

- **宣言的 Scene API** -- `@scene.run` + VNode ベースの view 関数で 2D ゲームを記述
- **Signal による状態管理** -- `mizchi/signals` でリアクティブな状態更新
- **契約先行アーキテクチャ** -- API の契約を先に定義し、実装を差し替え可能に保つ
- **クロスプラットフォーム** -- デスクトップは wgpu-native、ブラウザは WebGPU
- **Pure MoonBit** -- グラフィクスバックエンド境界以外の FFI なし

## アーキテクチャ

```
moon.work
|-- mizchi/kagura             core/engine 契約を束ねる薄い public facade
|-- mizchi/kagura_core        core 契約、数学、カメラ、メッシュ、入力 utilities
|-- mizchi/kagura_engine      描画・ランタイム基盤
|   |-- platform/, gfx/        platform/gfx/native/web backend
|   |-- runtime/, asset/       runtime loop、asset、audio、text、UI
|   `-- gltf/, renderer*/      glTF 変換と 2D/3D renderer facade
|-- mizchi/kagura_physics     再利用可能な physics / collision / pathfinding
|-- mizchi/kagura_game        ゲーム寄りの package 群
|   |-- scene/                 宣言的 2D Scene API
|   `-- ai/, ecs/, tilemap2d/  ゲームシステムと補助機能
`-- mizchi/kagura_js_runtime  JS 専用 WebGPU runtime helper
```

### プラットフォーム対応

| ターゲット | バックエンド | 対応状況 |
|-----------|-------------|---------|
| Web (全 OS) | WebGPU | 対応済み |
| Native macOS | wgpu-native + Metal + GLFW | 対応済み |
| Native Linux | wgpu-native + Vulkan + GLFW | 対応済み（CI: check + test + build） |
| Native Windows | wgpu-native + D3D12/Vulkan + GLFW | 部分対応（CI: check + build、runtime 実機確認は限定的） |

> JS ビルド（ブラウザ）は OS を問わず動作します。Native ビルドは macOS / Linux をサポートし、Windows は `-lm` 問題への repo 側 workaround を入れた段階です。

## クイックスタート

### 前提条件

- [MoonBit](https://www.moonbitlang.com/)
- Node.js 24+
- pnpm
- [just](https://github.com/casey/just)

### インストールと実行

```bash
pnpm install

# JS smoke テスト
(cd examples/smoke/runtime_smoke && moon run src --target js)

# Native smoke テスト（wgpu-native のセットアップが必要）
bash scripts/setup-wgpu-native.sh
just run-native runtime_smoke_native

# 可視確認（native の三角形デモ）
just run-native native_triangle
```

`runtime_smoke_native` は内部検証向けのため、ウィンドウが黒く見えても `ok (real)` が出れば成功です。

### Native 実行

`just run-native <name>` は Homebrew の GLFW ヘッダ・ライブラリパスを自動設定します:

```bash
# action_rpg を native で実行
just run-native action_rpg

# 手動で実行する場合は CPATH / LIBRARY_PATH の指定が必要
cd examples/games-2d/action_rpg && \
  CPATH="$(brew --prefix glfw)/include:${CPATH:-}" \
  LIBRARY_PATH="$(brew --prefix)/lib:${LIBRARY_PATH:-}" \
  moon run src/ --target native
```

## Web で動かす

任意の example をブラウザで実行:

```bash
just dev flappy_bird
```

ビルド → ローカルサーバー起動 → `http://localhost:8080` で開けます。ブラウザ版は現在 WebGPU 専用です。WebGPU 対応ブラウザ（Chrome 113+, Edge 113+）を使ってください。

## Scene API で始める

最小の宣言的ゲーム:

```moonbit
fn main {
  @web_hooks.install("#app")
  let score = @signals.signal(0)
  let player_x = @signals.signal(160.0)

  @scene.run(
    view=fn() {
      @scene.fragment([
        @scene.rect(w=320.0, h=240.0, fill=0x1a1a2e),
        @scene.rect(x=player_x.get(), y=120.0, w=16.0, h=16.0, fill=0x00FF88),
        @scene.label(content="SCORE:" + score.get().to_string()),
        @scene.show(fn() { score.get() >= 100 }, fn() {
          @scene.label(x=160.0, y=120.0, content="YOU WIN", scale=3.0)
        }),
      ])
    },
    update=fn(input) {
      @signals.batch(fn() {
        // input で状態を更新
      })
    },
    width=320, height=240,
    title="my_game", canvas="#app",
  )
}
```

## サンプル

| サンプル              | API | 説明                              |
|----------------------|-----|-----------------------------------|
| `scene_demo`         | Scene | 宣言的 API の最小デモ              |
| `flappy_bird`        | Scene | 入力処理付き 2D ゲームループ        |
| `survivor`           | Scene | エンティティ・武器・カメラの複合ゲーム |
| `action_rpg`         | Scene | タイルマップ・AI・UI のアクション RPG |
| `arena3d`            | Low-level | 3D アリーナプロトタイプ (experimental) |
| `runtime_smoke`      | Low-level | 最小 JS smoke テスト             |
| `runtime_smoke_native` | Low-level | 最小 native smoke（非可視）テスト |
| `native_triangle`    | Low-level | native 可視確認用の三角形デモ      |

各サンプルは独立した MoonBit モジュールです。以下で実行:

```bash
(cd examples/<name> && moon run src --target <js|native>)
```

## ドキュメント

### ユーザー向け

- [入門](docs/user/getting_started_ja.md)
- [チュートリアル](docs/user/tutorials_ja.md)
- [API ガイド](docs/user/api_guide_ja.md)

### 開発参加者向け

- [コントリビューティングガイド](CONTRIBUTING_ja.md)
- [アーキテクチャ](docs/architecture/architecture.md)
- [モジュール境界](docs/architecture/module_boundaries.md)
- [ロードマップ](docs/roadmap/roadmap.md)

## 検証

```bash
just fmt
just check target=js
just test target=js
just check target=native
just test target=native
just check-release
pnpm e2e:smoke
```

## 依存ライブラリ

- [mizchi/signals](https://mooncakes.io/docs/#/mizchi/signals/) -- リアクティブ状態管理
- [mizchi/image](https://mooncakes.io/docs/#/mizchi/image/) -- 画像コーデック（PNG/BMP/JPEG）
- [mizchi/font](https://mooncakes.io/docs/#/mizchi/font/) -- フォントレンダリング・シェイピング
- [mizchi/layout](https://mooncakes.io/docs/#/mizchi/layout/) -- レイアウトエンジン
- [mizchi/audio](https://mooncakes.io/docs/#/mizchi/audio/) -- オーディオシステム
- [mizchi/svg](https://mooncakes.io/docs/#/mizchi/svg/) -- SVG レンダリング

## ライセンス

Apache-2.0
