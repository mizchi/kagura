# Kagura CLI

Kagura のゲーム作成・開発・静的配布ビルド・Studio 起動をまとめる CLI です。
MoonBit、Node.js 24+、pnpm を用意してください。ブラウザ版は WebGPU を使用します。

## インストールとゲーム作成

このリポジトリでインストールします。

```sh
moon install ./cmd/kagura
```

MoonBit の bin ディレクトリ（通常 `~/.moon/bin`）を PATH に追加すると、別の場所からも使えます。

```sh
kagura new my-game --web
cd my-game
pnpm install
kagura dev                        # http://localhost:8080
kagura build                      # dist/ に静的サイトを出力
```

空のディレクトリでは `kagura new --web` で現在地に作成できます。
ファイルがあるディレクトリへの生成は拒否し、既存ファイルを上書きしません。

生成するプロジェクトは **構成変更後の Kagura パッケージのリリースを前提**に、
Mooncakes のバージョン指定で依存します。エンジンのソースやローカルパス依存を含めません。
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

終了コードは成功 `0`、引数エラー `2`、起動失敗 `1`。子プロセスの失敗コードを引き継ぎます。

## 実装と検証

`cmd/moon.mod` は CLI 用の `mizchi/kagura_cli` module、`cmd/kagura` は実行パッケージです。
公開ライブラリの `mizchi/kagura` と衝突せず、実行ファイル名を `kagura` に保ちます。

- `arguments.mbt` / `scaffold.mbt`: 型付きコマンド、引数検証、雛形の展開、JSON 境界
- `templates/web/`: リリースパッケージを使う Web 雛形。`.template` を外して生成
- `main_native.mbt` / `launcher_native.c`: `moon install` 用エントリと Node 起動の小さな FFI
- `main.mjs` / `host.mjs` / `process.mjs`: Node のファイル・環境・プロセス操作
- `generate.mjs`: 雛形・共通ホスト・ブラウザランタイムを native 用 MoonBit ソースに埋め込み
- `cli.generated.js` / `cli.generated.d.ts`: MoonBit JS backend の生成物と JSON 境界の型宣言
- `scripts/{dev-server,build-game,web-project,web-demo-package}.mjs`: 既存ツールと共有するホスト処理

```sh
just cli-build       # 埋め込みソースと配布 ESM を再生成
just cli-install     # 再生成して moon install
just cli-check       # JS/native の warning-free check と生成物の一致
just cli-test        # 引数・雛形・パス解決・静的配布・エラー処理
just cli-e2e         # Playwright: インストール、新規作成、dev、再読み込み、build、Studio
```

生成物も git に含めるため、利用者の `moon install` に事前の生成コマンドは不要です。
ホスト・テンプレート・ブラウザランタイムを変更したら `just cli-build` を実行してください。
E2E ではリリース前の検証用に限り、生成先へ一時的な `moon.work` を追加してローカル module を参照します。
この workspace は配布する雛形には含めません。

`cmd/` は利用側レイヤで、ライブラリの release staging には含めません。
core / engine / game / platform から CLI へ依存させません。
