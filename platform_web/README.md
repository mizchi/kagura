# mizchi/kagura_platform_web

`platform_web` は ブラウザ向けランタイムを MoonBit で記述する module です。

- module: `moon.mod`
- package prefix: `mizchi/kagura_platform_web/*`

## Platform contract

共通 contract は `platform/`（`mizchi/kagura_platform`）が所有します。
この module のルートは `install(WebCanvasHooks)` / `uninstall()` /
`create_platform(selector)` を公開し、既存の WebCanvasPlatform shell を使用します。
返り値は `PlatformDriver` と `mizchi/gfx.SurfaceProvider` を実装します。
ウィンドウ・入力の型やライフサイクルを JS 側に複製しません。

実ブラウザでは `platform_web/runtime_hooks` が DOM・描画・音声を結線し、
この module の `install` に型付き hook を渡します。ルートの adapter は
host に触れないため他ターゲットでも検証でき、ブラウザ専用パッケージ の
実装は JS のみに限定します。`platform` から実装への逆依存、実装から
engine / game への依存は `just check-release` の境界検査が拒否します。

## 配布されるランタイム

`web_core/exports.mbt` は安定した ESM の公開窓口です。実装は責務で分けます。

| 配置 | 内容 |
| --- | --- |
| `input/` | コントロール状態・ゲームパッドの正規化 |
| `render/` | WGSL と geometry のキャッシュ |
| `diagnostics/` | 計測結果の取得・JS 形式への変換（統計計算は core） |
| `playback/` | 型付き Timeline と JS アセットの接続 |
| `ui_sync/` | UI 差分・依存値の変更判定 |
| `interop/` | JS 組み込みへの小さな FFI |
| `services/`, `fetch/` | 時計・フレームスケジューラ・通信のホスト実装 |
| `host/` | WebGPU、音声、DOM、Worker 等の手書き JS と Node テスト |

`mizchi/js/builtins` の Object、Math、RegExp、Map、WeakMap を使用します。
依存バージョンは既存の `mizchi/js@0.12.2` を維持しています。
DOM、イベントの登録・解除、WebGPU のリソース確保・送信、Web Audio、Worker、
Node のビルド処理は JS のホスト層です。大きな JS 関数を `extern "js"` に
埋め込んで移行扱いにせず、状態遷移・ループ・判定を MoonBit に書きます。

旧 WebGPU 実装は `../experiments/webgpu/` へ隔離しました。現行の配信経路では使いません。
機能が異なるため、配信中の WebGPU ホストをこれに切り替えないでください。

## JS ABI と所有権

MoonBit の公開シグネチャは `web_core/pkg.generated.mbti`、JS の構造化された
契約の原本は `web_core/exports.d.ts` にあります。配布時に `assets/web/kagura-runtime.generated.d.ts` へコピーします。これは手書きの
型宣言で、実装ではありません。export の一致を Node テストで検証します。
境界の `@core.Any` は JS のオブジェクトを JSON 化せず渡すために使用します。
内部の入力・パッド・再生状態はそれぞれ独立した MoonBit struct が所有します。

- コマンド payload と変更されていない HUD フィールドの JS 参照を保つ。
- 入力 ID は 32 bit に縮めず、安全な整数を扱う。
- モーションクリップの非空配列、正の duration/fps は既存アセットローダーが検証する。
- 明示登録した geometry は revision 更新まで不変。暗黙登録は WeakMap だけで保持する。
- 可変 geometry はコピーを所有し、後続の変更が以前の draw に混ざらない。
- typed array はホットループで直接比較し、JSON 変換や要素ごとの callback を挟まない。

## ビルドと検証

リポジトリルートで実行します。

```sh
just web-runtime-build  # .mbt -> release ESM
just web-runtime-test   # MoonBit の性質検証 + 既存 JS ABI / GPU モックテスト
just web-runtime-check  # 同じコンパイラで生成物が完全一致することを確認
```

生成 ESM は git に含めます。静的配信、Node、Worker で MoonBit コンパイラを
実行せずに読み込めるためです。`.mbt` を変えたら生成物も更新してください。
Node だけの CI でもソースハッシュにより更新漏れを検出します。完全一致の確認は
コンパイラ出力にも依存するため、ツールチェーン更新時には再生成が必要です。

ゲームの dev server と Studio の Vite は起動時と各生成元・module manifest の編集時に再生成します。
Pages、Studio examples/model-viewer のビルドもコピー前に再生成します。
`just test-workspace` の JS 実行は生成後にテストします。

共通 ESM の `#kagura-web/` は Node の package imports とブラウザの import map で
同じ API を指します。既存の `@kagura-web/` も互換のため維持しています。
直接 `copyWebRuntimeAssets()` を使う外部のビルド処理は、先に `buildWebRuntime()` を
呼んでください。コピー関数自体はコンパイラを起動しません。

`runtime_hooks/` は独立した `mizchi/web_runtime_hooks` module です。起動時の
結線に engine を使いますが、親 adapter の配布には含めません。
ゲーム固有の形状配置・装備比較は `game/inventory_web/` に分離し、別 ESM を生成します。

生成ハッシュと Vite の監視は、ローカルの推移的な依存 package まで含みます。
`core/anim3d/playback` や `game/inventory` の編集も再生成・再読込の対象です。
`host/*.js` と各 ESM の `exports.d.ts` も同じビルドで配布先へ同期します。
