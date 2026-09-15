# kagura

[MoonBit](https://www.moonbitlang.com/) 向け 2D（将来 3D）ゲームエンジン。[Ebiten](https://github.com/hajimehoshi/ebiten) の設計に着想を得ています。

[English](README.md)

## 特徴

- **宣言的 Scene API** -- `@scene.run` + VNode ベースの view 関数で 2D ゲームを記述
- **Signal による状態管理** -- `mizchi/signals` でリアクティブな状態更新
- **契約先行アーキテクチャ** -- API の契約を先に定義し、実装を差し替え可能に保つ
- **クロスプラットフォーム** -- デスクトップは wgpu-native、ブラウザは WebGPU
- **Pure MoonBit** -- グラフィクスバックエンド境界以外の FFI なし

## 統合オーサリングエディタ

[Kagura Studio](editor/studio/README.md) は Luna / MoonBit 製のエディタです。
シーン・プリミティブ・演出を編集し、UIとAIが同じ検証・Undo/Redoを使います。
`just studio-install` → `just studio-dev` で起動します。
[設計と移植方針](docs/design/studio-authoring.md)。

## AC風ロボットTPS

[IRON YARD](examples/games/iron_yard/README.md) は modeling-playground のゲームをMoonBitへ移植したものです。
STRIX / BASTIONの実モデルを、kaguraのPBR・影・音声基盤で動かします。`just iron-yard-dev` で起動、`just iron-yard-ci` で検証できます。

## アーキテクチャ

```
moon.work
|-- core/                    純粋な計算: 幾何、物理、地形、入力状態
|-- platform/                ウィンドウ・入力・surface の共通コントラクト
|-- platform_web/            ブラウザ実装と runtime_hooks/
|-- platform_native/         native 実装、gfx_wgpu_native/、capture/
|-- engine/                  描画・アセット・実行基盤・表示ツリー・HUD
|-- game/                    ルール・進行・ECS・インベントリ・操作割り当て
`-- editor/                  オーサリングと検査ツール
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
cd examples/games/action_rpg && \
  CPATH="$(brew --prefix glfw)/include:${CPATH:-}" \
  LIBRARY_PATH="$(brew --prefix)/lib:${LIBRARY_PATH:-}" \
  moon run . --target native
```

## Web で動かす

任意の example をブラウザで実行:

```bash
just dev flappy_bird
```

ビルド → ローカルサーバー起動 → `http://localhost:8080` で開けます。ブラウザ版は現在 WebGPU 専用です。WebGPU 対応ブラウザ（Chrome 113+, Edge 113+）を使ってください。

## 開発 CLI

このチェックアウトから CLI をインストールして、Web ゲームを作成できます。

```sh
moon install ./cmd/kagura
kagura new my-game --web
cd my-game
pnpm install
kagura dev
kagura build
```

`kagura new --web` は空の現在地に生成します。雛形は公開済みの Kagura パッケージを使い、
ローカルパス依存を使いません。共通ブラウザランタイムと Vite 設定を含みます。

CLI はルートの `mizchi/kagura` モジュールとバージョンを共有します。次回リリースから
`moon install mizchi/kagura/cmd/kagura` でインストールできます。
公開済みの 0.5.0 は引き続き `mizchi/kagura_cli/kagura@0.5.0` です。

チェックアウト内のサンプルと Studio は次のように起動します。

```sh
pnpm kagura dev hacknslash_3d --port 8080
pnpm kagura build hacknslash_3d --out-dir output/game
just studio-install  # Studio の初回準備
pnpm kagura studio
```

`just kagura ...` からも実行できます。ゲームのディレクトリ内ではプロジェクト名を省略できます。
`build` は HTML・JS・素材を揃えた静的サイトを出力します。
詳細は [Kagura CLI](cmd/kagura/README.md) を参照してください。

`kagura capture [url] --output game.png` でプレイ画面の PNG、
`kagura profile [url] --out-dir output/profile` でフレーム統計と CPU プロファイルを保存できます。
外部プロジェクトでも使えます。実行するプロジェクトに `@playwright/test` をインストールしてください。

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
