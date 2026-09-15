# Kagura CLI

Kagura のゲーム作成・開発・静的配布ビルド・Studio 起動・画面キャプチャ・負荷計測をまとめる CLI です。
MoonBit、Node.js 24+、pnpm を用意してください。ブラウザ版は WebGPU を使用します。

## インストールとゲーム作成

このチェックアウトからインストールします。

```sh
moon install ./cmd/kagura
```

MoonBit の bin ディレクトリ（通常 `~/.moon/bin`）を PATH に追加すると、別の場所からも使えます。

0.6.0 から CLI はルートの `mizchi/kagura` モジュールに含まれます。
`moon install mizchi/kagura/cmd/kagura@0.6.0` でインストールできます。

```sh
kagura new my-game --web
cd my-game
pnpm install
kagura dev                        # http://localhost:8080
kagura build                      # dist/ に静的サイトを出力
```

空のディレクトリでは `kagura new --web` で現在地に作成できます。
ファイルがあるディレクトリへの生成は拒否し、既存ファイルを上書きしません。

生成するプロジェクトは Mooncakes の Kagura パッケージにバージョン指定で依存します。
エンジンのソースやローカルパス依存を含めません。
対応する共通ブラウザランタイムは CLI に同梱し、生成先の `runtime/` に展開します。
生成先の `new` / `dev` / `build` は、元のチェックアウトなしで動作します。

雛形には `main.mbt`、MoonBit manifest、Vite 設定、HTML、`justfile`、`kagura.json` を含みます。
WASD / 矢印キーで四角を動かす小さなゲームを起点に開発できます。
`pnpm dev` / `pnpm build` や `just dev` / `just build` でも実行できます。

| コマンド | 動作 |
| --- | --- |
| `kagura new [directory] --web` | Web ゲームを生成。省略時は現在地 |
| `kagura dev [project]` | MoonBit の変更監視とブラウザの再読み込み。既定ポート 8080 |
| `kagura build [project]` | JS release と静的サイトを `<project>/dist/` に出力 |
| `kagura studio` | チェックアウトの Studio を起動。既定ポート 5190 |
| `kagura capture [url]` | HUD を含むプレイ画面だけを PNG に保存 |
| `kagura profile [url]` | CPU/GPU の指標と Chrome CPU プロファイルを保存 |

`dev` / `build` は省略時に現在地から親のプロジェクトを探します。
`dev` / `studio` は `--port` と `--host` に対応します。ポートの優先順位は
`--port`、`PORT` 環境変数、既定値です。使用中のポートではエラー終了します。
Ctrl+C はサーバーと監視プロセスを停止します。POSIX では孫プロセスにも終了シグナルを送ります。

`build --out-dir <path>` の相対パスはコマンドを実行したディレクトリ基準です。
生成プロジェクトのビルドは Vite を使用します。出力先はビルド用のディレクトリを指定してください。
出力を HTTP サーバーで配信すると起動でき、サブディレクトリへの配置にも対応します。

## チェックアウトのサンプルと Studio

既存のサンプル開発と Studio は Kagura のチェックアウトを使います。
インストール元を移動した場合は `KAGURA_ROOT` に新しい場所を指定してください。

```sh
pnpm install --frozen-lockfile
kagura dev hacknslash_3d
kagura build hacknslash_3d --out-dir output/game
just studio-install                       # Studio の初回準備
kagura studio
```

`pnpm kagura ...`、`just kagura ...`、`node cmd/kagura/main.mjs ...` でも実行できます。
`pnpm link --global` でも `kagura` をリンクできます。
`moon install` がインストールする実行ファイル名も `kagura` です。

サンプルの `project` は example 名または MoonBit プロジェクトのパスです。
リポジトリのルートではゲームを指定してください。実行パッケージは module のルートまたは `src` に置きます。
サンプル用ビルドは HTML・JS・素材・共通ランタイムを揃えて出力し、前回の出力を成功後に置き換えます。
無関係なファイルがある出力先は拒否します。

## 画面キャプチャと負荷計測

起動済みの Kagura ゲーム URL を指定します。別リポジトリで作成したゲームや公開サイトにも使えます。
実行するプロジェクトに Playwright をインストールしてください。Kagura のチェックアウトは不要です。

```sh
pnpm add -D @playwright/test
pnpm exec playwright install chromium
kagura capture http://localhost:8080/ --output output/game.png --width 390 --height 844
kagura profile http://localhost:8080/ --out-dir output/profile --samples 240 --profile-ms 4000
```

macOS はインストール済みの Google Chrome と Metal を使用し、その他では Chromium と SwiftShader を使用します。
`KAGURA_PLAYWRIGHT_CHROMIUM_PATH` で実行ファイル、`KAGURA_PLAYWRIGHT_CHROMIUM_ARGS` で追加引数を指定できます。
Playwright はこの 2 コマンドでのみ読み込み、`new` / `dev` / `build` / ヘルプでは不要です。

両コマンドは `--url` でも URL を受け取り、省略時は `http://localhost:8080/` を使います。
ブラウザの表示領域を指定する `--width` / `--height`、`--headed`、待機時間を指定する `--timeout`（既定 30000 ms）に対応します。
キャプチャは Kagura の presentation contract が示す描画済みの領域だけを取得し、
未起動や無関係なページではエラーになります。既定の出力先は `output/game.png`、表示領域は 1600×900 です。
PNG の大きさはその中の実際のゲーム領域に従い、ページの余白は含みません。

計測は既定 1280×900、`--samples` は 1〜3600、`--profile-ms` は 1〜60000 ms です。
`--warmup-ms`（既定 1000、0〜60000 ms）で描画開始後の待機を調整できます。
フレーム計測後に CPU サンプリングを開始し、その負荷がフレーム計測へ混入するのを避けます。

- `summary.json`：CPU 時間/フレーム、各指標の分位点と外れ値を除いた平均、時間のかかる関数、ページエラー
- `samples.json`：フレームごとの元データ。取得できない GPU 指標などは欠損のまま扱う
- `profile.cpuprofile`：Chrome DevTools で読み込める CPU プロファイル

計測の既定出力先は `output/cpu/<timestamp>/` です。ページエラーがあればレポート保存後に失敗を返します。
`just capture-web` / `just profile-web` と旧 `scripts/{capture-web,profile-web}.mjs` は同じ実装へ委譲します。

終了コードは成功 `0`、引数エラー `2`、起動失敗 `1`。子プロセスの失敗コードを引き継ぎます。

## 実装と検証

`cmd/kagura` はルートの `mizchi/kagura` module に属する実行パッケージです。
独立した `cmd/moon.mod` は持たず、ルートの manifest とリリースバージョンを共有します。
パッケージ名は `mizchi/kagura/cmd/kagura`、実行ファイル名は `kagura` です。

- `arguments.mbt` / `browser_arguments.mbt` / `scaffold.mbt`: 型付きコマンド、引数検証、雛形の展開、JSON 境界
- `../diagnostics/*.mbt`: フレーム統計、CDP 指標・トレース・CPU プロファイルの集計。JS backend で配布コードを生成
- `browser.mjs` / `performance.mjs`: Playwright の接続とファイル出力、MoonBit 集計への JSON 境界
- `templates/web/`: リリースパッケージを使う Web 雛形。`.template` を外して生成
- `main_native.mbt` / `launcher_native.c`: `moon install` 用エントリと Node 起動の小さな FFI
- `main.mjs` / `host.mjs` / `process.mjs`: Node のファイル・環境・プロセス操作
- `generate.mjs`: esbuild でホストと生成済みの集計コードを束ね、雛形・ランタイムとともに native 用 MoonBit ソースに圧縮して埋め込み
- `cli.generated.js` / `cli.generated.d.ts`: MoonBit JS backend の生成物と JSON 境界の型宣言
- `scripts/{dev-server,build-game,web-project,web-demo-package}.mjs`: 既存ツールと共有するホスト処理

```sh
just cli-build       # 埋め込みソースと配布 ESM を再生成
just cli-install     # 再生成して moon install
just cli-check       # JS/native の warning-free check と生成物の一致
just cli-test        # 引数・雛形・パス解決・静的配布・エラー処理
just cli-e2e         # Playwright: インストール、新規作成、dev、再読み込み、build、Studio
```

次回公開後は、そのバージョンを `KAGURA_CLI_RELEASE_VERSION` に設定すると、
レジストリの CLI と依存パッケージだけを使った動作を検証できます。

```sh
pnpm exec playwright test --config cmd/kagura/playwright.config.mjs scaffold
```

生成物も git に含めるため、利用者の `moon install` に事前の生成コマンドは不要です。
ホスト・テンプレート・ブラウザランタイムを変更したら `just cli-build` を実行してください。
E2E ではリリース前の検証用に限り、生成先へ一時的な `moon.work` を追加してローカル module を参照します。
この workspace は配布する雛形には含めません。

`cmd/` は利用側のパッケージ群で、ルート module の release staging に含めます。
core / engine / game / platform から CLI へ依存させません。
