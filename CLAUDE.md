# kagura - MoonBit 2D Game Engine

## プロジェクト構成

- `src/` - エンジンコア
- `examples/<category>/<name>/` - サンプルプロジェクト（各ディレクトリが独立した moon プロジェクト）
  - カテゴリ: `games-2d`, `games-3d`, `rendering`, `physics`, `ui`, `ecs`, `smoke`, `experimental`
- `scripts/` - ビルド・開発スクリプト
- `justfile` - タスクランナー

## 依存パッケージ開発

外部パッケージ（`mizchi/glfw` など）に問題が出た場合、`moon.mod.json` の deps でローカルパスを指定して開発できる:

```json
"mizchi/glfw": { "path": "../glfw-mbt" }
```

修正が完了したら、パッケージ側で `moon publish` してバージョン番号に戻す。

**リリース前には `just check-release` でローカルパス依存がないことを確認すること。**

### バージョンの天井

`moon.mod` の `@x.y.z` は**範囲ではなく完全一致**で、解決されるのは
依存グラフ全体で要求された中の最大値。だから一箇所の bump が推移的に
別のパッケージを引き上げ、そこで壊れることがある。

| 止めている pin | 理由 |
|---|---|
| `mizchi/font@0.7.3`（0.7.4 が最新） | 0.7.4 が `moonbitlang/x@0.4.50` を引く。0.4.50 で `@x/fs.IOError::to_string` が消えたが、`mizchi/parquet` が native 経路でまだ呼んでいる（`examples/games-3d/hacknslash_3d`）|

parquet 側が x 0.4.50 に追従したら font の天井を外せる。上げるときは
`moon check --deny-warn` を **js と native の両方**で回すこと。js だけだと
`@x/fs` を使う経路がそもそもコンパイルされず素通りする。

## ビルド・テスト

```bash
just check          # moon check (js)
just test           # moon test (js)
just check target=native  # native ビルド確認
just check-release  # リリース前チェック（ローカルパス依存の検出）
```

## ゲーム UI の検証

canvas 上の UI は DOM を持たないので、`@ui.publish_ui_snapshot` で UI ツリー
（矩形・クリップ・実測テキスト幅・hit 矩形・フォーカス順）を外に出し、Node 側の
決定的ゲートにかける。browser も API キーも不要。

```bash
just ui-check output/ui-snapshot.json      # 文字あふれ/クリップ/画面外/重なり/hit box ずれ
just ui-elements output/ui-snapshot.json   # vlmkit diff png --elements-json 用に変換
just ui-asset-check <png>                  # スプライト/アイコンの入庫ゲート
```

手順とルールの詳細は `docs/tools/ui-verification-runbook.md`。

- `text_measured` は描画側と**同じ算術**で測る（dot text は `@renderer2d.dot_text_size`）
- `path` は実ツリーの階層を反映させる（ツーリングが祖先関係を読む）
- `extern "js"` を含むファイルは `moon.pkg` の `targets` で js に限定し、native は no-op スタブ

## スナップショットテスト (VRT)

Playwright + SwiftShader による Visual Regression Testing。

**現状 CI では非 gating**（`ci.yml` が `--update-snapshots` で実行）。Linux では canvas
screenshot が透明かつ Dawn readback が完了しないため。移植可能なキャプチャの整備は #9、
gating 化は #8。

```bash
just e2e-vrt          # VRT 実行
just e2e-vrt-update   # ベースライン更新
```

### スナップショットモード

URL パラメータでゲームステートを制御し、目視確認と VRT の両方に使える:

```
?snapshot=playing&frames=60&tick=5
```

| パラメータ | 説明 | デフォルト |
|---|---|---|
| `snapshot` | ゲームモード (`playing`, `gameover`) | なし（通常起動） |
| `frames` | update を空入力で進めるフレーム数 | 60 |
| `tick` | 描画フレームを N 回待ってからキャプチャ | 0 |

**目視確認:** `just dev hacknslash_3d` → ブラウザで `http://localhost:8080/?snapshot=playing&frames=60` を開く。実ブラウザの WebGPU で PostFX 込みの描画を確認できる。

**自動テスト:** `just e2e-vrt` で SwiftShader ヘッドレス環境でリグレッション検知。SwiftShader では WebGPU の高度な機能が制限されるため、描画結果は実ブラウザと異なるが、変更による差分検知として機能する。

- `tick` は PostFX パイプライン（Bloom, Tonemap, FXAA）が確実に適用された状態をキャプチャするために使う
- ゲーム側で `globalThis.__kaguraSnapshotTick` に描画済みフレーム数を公開し、Playwright が `waitForFunction` で待機
- 実装: `examples/*/*/src/snapshot.mbt` + `main.mbt` の draw コールバック内

### 新しい example に VRT を追加する手順

1. `scripts/serve-wasm-smoke.mjs` の `VRT_EXAMPLES` に追加
2. `e2e/vrt.spec.ts` の `VRT_EXAMPLES` に追加（タイトル画面）
3. スナップショットモードが必要なら `SNAPSHOT_TESTS` にも追加
4. `just e2e-vrt-update` でベースライン生成

## wasm ターゲットと moonbitlang/async

`moonbitlang/async` は **wasm1 (`--target wasm`) のみ**対応。wasm-gc では
`run_async_main` が無く、リンクできない。

wasm1 の async は「WASI 相当の POSIX ホスト」を前提にしており、ゲストは 48 個の
import（epoll 風 event bus / thread pool / fd / errno / signal / os string）を
要求する。ただしタイマだけを動かすなら実装が要るのは 7 個だけで、残りは型の合った
ゼロを返せばよい。実装は `lib/web/kagura-wasm-host.js`、動く例は
`examples/smoke/wasm_async_smoke/`。

```bash
just wasm-host-smoke   # ビルド + 最小 JS ホストで実行
```

**ホスト実装で踏みやすい落とし穴:**

- `thread_pool/cancel_worker` が `0` を返すと「RetryLater」の意味になり、終了時に
  sigwait ワーカーの後始末で無限ループする。`2`（NoWait）を返すこと
- `event_bus/wait` は `0`（I/O イベント無し）を返せばよく、ループがその後に期限の
  来たタイマを自分で処理する。`Atomics.wait` で実際にブロックしないとビジーループになる
- `time/get_ms_since_epoch` は i64 なので JS 側は `BigInt` を返す

**設計上の制約:**

`_start` はゲストの async main が終わるまで返らず、その間イベントループが
スレッドを占有する。ブラウザのメインスレッドでは固まるので Web Worker に置く。

### Worker 分離とフレーム駆動

`event_bus/wait` は**ゲストがホストに制御を返す唯一の場所**なので、ここを
共有フレームカウンタ待ちにすると、メインスレッドの `requestAnimationFrame` が
そのままゲストの起床源になる。どちらもポーリングしない。

```
main thread              shared Int32Array        worker
-----------              -----------------        ------
rAF 発火
  Atomics.add(FRAME,1) ----> [FRAME] ----> Atomics.wait が返る
  Atomics.notify                            ゲストのタイマが進む
```

API は他の `lib/web/kagura-*.js` と同じ規約（`create*` / `install*` / 動詞始まり、
名前付き export）:

| ファイル | export |
|---|---|
| `kagura-wasm-host.js` | `createWasmHost(bytes, opts)` → `{imports, bind, stats}` / `runWasm(bytes, opts)` |
| `kagura-wasm-worker.js` | `createFrameWait(control, opts)` / `runWasmWithFrameClock(bytes, control, opts)` / `FRAME_SLOT` `STOP_SLOT` `CONTROL_LENGTH` |
| `kagura-wasm-driver.js` | `createFrameControl()` / `tickFrame(control)` / `stopFrames(control)` / `installBrowserFrameClock(control)` / `runWasmInWorker(bytes, opts)` |
| `kagura-frame-stats.js` | `percentile(values, p)` / `summarizeIntervals(timestampsMs)` |

ブラウザから import されるので、**`node:` 名前空間は Node と判定できたときだけ触る**こと。
ブラウザは `node:worker_threads` を URL として fetch しに行き、module worker が
まるごと死ぬ（try/catch では防げない。fetch 自体が起きる）。
- ゲストは `kagura_web.frame_number` でカウンタを読む。フレーム源が無いときは
  0 のままなので、**同じバイナリが worker あり／なしの両方で終了する**

```bash
just wasm-host-smoke   # 単体ホストと worker + フレームクロックの両方を実行
```

実測（`examples/smoke/wasm_async_smoke`）:

| | frames observed | waits | wall |
|---|---|---|---|
| 単体ホスト（フレーム源なし） | 0 | 127 | 536ms |
| worker + 8ms フレームクロック | 5 | 25 | 147ms |

node の `worker_threads` 経路は `lib/web/kagura-wasm-driver.test.mjs` が、
ブラウザ側の前提は `e2e/offscreen_worker.spec.ts` が固定している。

### ブラウザでの実測（Chromium, OffscreenCanvas）

```bash
pnpm e2e:offscreen   # 既定の CI には入っていない。手動 or 追加する場合は各自で
```

| 確認したこと | 結果 |
|---|---|
| Worker に `requestAnimationFrame` はあるか | **ある**（AnimationFrameProvider） |
| ブロック中に Worker の rAF は発火するか | **612ms で 0 回**（await 中は発火する: 1 回） |
| ブロック中の Worker をメイン rAF + `Atomics.notify` で駆動できるか | **できる**（main 40 → worker 37 draw） |
| OffscreenCanvas への 2D 描画は届くか | **届く**（worker 自身の readback で全面一致） |
| ブロック中の Worker から WebGPU を submit できるか | **37 回成功、エラーなし** |

### フレームレート（headless Chromium, 5 回 x 1500ms の中央値）

| | fps | p50 | p95 |
|---|---|---|---|
| メインスレッド（worker なし） | 60.0 | 16.66ms | 16.67ms |
| メインスレッド（worker 駆動中） | 60.0 | 16.66ms | 16.67ms |
| ゲスト（worker 内の描画） | 60.0 | 16.66ms | 16.8-16.9ms |

**メインスレッドは劣化しない**（比 1.000、パーセンタイルも一致）。ゲストも 60fps を
維持し、駆動されたフレームの **96.8-97.8% を処理**する。取りこぼす数フレームは
WebGPU の await 中に進んだ分で、ゲストがまだパークしていない起動窓のもの。
ゲストの p95 がわずかに高い（+0.1〜0.2ms）のが Atomics の起床レイテンシ。

### ハンドシェイクのベンチ

```bash
just bench-frame-clock          # 60/120/240/480Hz、同期処理あり/なし
just bench-frame-clock --json   # 機械可読
```

駆動レートを直接指定して、実際に出荷している `createFrameWait` を叩く（コピーではない）。
レポート専用でゲートにしていないのは、起床レイテンシにスケジューラ由来の外れ値が出るため。

| 駆動 | budget | 処理率 | 起床レイテンシ p50/p95 |
|---|---|---|---|
| 60Hz | 16.67ms | 97-99% | 100/160 us |
| **120Hz** | **8.33ms** | **99%** | **91/149 us** |
| 240Hz | 4.17ms | 99% | 77/131 us |
| 480Hz | 2.08ms | 99% | 68/129 us |

**起床レイテンシは駆動レートによらずほぼ一定**（60-120us）。120Hz の 8.33ms budget に
対して **1.1%**。8.33ms のうち 6ms を同期処理で埋めても処理率 99% を維持する。
120fps は余裕で、天井はもっと上（480Hz でも追従）。

計測上の注意: **wake はフレームと同じではない**。`Atomics.wait` は自前のタイムアウトでも
返るので、共有カウンタの前進を見ないとタイムアウトをフレーム処理と誤カウントし、
レイテンシに 50ms の外れ値が出る（初版のベンチがこれで嘘をついた）。

**順序の制約:** `requestAdapter` / `requestDevice` は Promise なので**ブロック開始前に
完了させる**こと。パーク後はマイクロタスクが回らない。フレーム内の描画
（`createCommandEncoder` → `beginRenderPass` → `submit`）は全部同期なので、
ブロック中のスレッドからでも到達できる。`kagura_web` の `gfx_*` host import が
すべて同期なのはこの形に合っている。

つまり **async 駆動のまま描画できる**ので、`kagura_frame` エクスポートを別途
叩く必要はなく、ゲストは起床ウィンドウで描けばよい。

`SharedArrayBuffer` には COOP/COEP が要る。`scripts/serve-wasm-smoke.mjs` は
`/e2e/fixtures/offscreen-worker` 配下にだけこのヘッダを付ける（VRT や smoke の
ページの挙動を変えないため）。

headless Linux では canvas screenshot が透明になるので、ピクセル確認は
**worker 自身の `getImageData` readback** で行っている（VRT が in-page readback を
使っているのと同じ理由）。

### `kagura_web` の per-element ABI を bulk 転送にする案（実測の結果、見送り）

`gfx_draw_vertex(offset, x, y, u, v)` は頂点ごと、`gfx_upload_texture_pixel` は
ピクセルごとの import 呼び出しになっている。呼び出しコストは実測 **~27ns**：

| | 呼び出し数 | コスト | 120fps budget 比 |
|---|---|---|---|
| 5,000 頂点 + 7,500 index | 12,500 | 0.34 ms | 4% |
| 20,000 頂点 + 30,000 index | 50,000 | 1.35 ms | 16% |
| 256x256 テクスチャ | 65,536 | 1.77 ms | 21% |

一括転送に置き換えて実装・e2e 通過まで確認したが、**A/B で速くならなかったので
差し戻した**。リリースビルドで 5,000 頂点 180us → 289us、20,000 頂点 758us → 1143us と
むしろ遅い。理由は**ゲスト側の repack**：`@gfx.DrawTrianglesCommand` は
`Array[Double]` を持つので、ホストに渡すには `FixedArray` へ 4N 要素コピーする必要が
あり、そのコストが削減した呼び出しコストと相殺する（20,000 頂点で 80,000 回の
境界チェック付きコピー）。

やるなら repack を消すしかないが、道は 2 つとも塞がっている:

- `Array[Double]` を直接渡すと、ホストは **offset +32** にデータを見つける。未文書の
  内部レイアウトで、アロケーション順の偶然である可能性がある。依存すべきでない
- `@gfx.DrawTrianglesCommand` が `FixedArray` を持つよう変える必要があるが、
  `mizchi/gfx` は外部パッケージ

**wasm-gc では原理的に不可能**なことも分かった。wasm-gc の `FixedArray` は GC 参照で
リニアメモリ上に住所を持たないので、ホストが `memory.buffer` から読む方法が無い。
一括転送はリニアメモリを持つ wasm1 専用の話になる。

FFI で `FixedArray` を渡す方法自体は動く（`#unsafe_skip_stub_check` +
`#borrow(a, b)`）。ホストはデータ先頭への直接ポインタを受け取り（ヘッダなし）、
`memory` は既定でエクスポートされる。別の用途では使える。

## 注意事項

- `cc-link-flags` は依存パッケージから伝播しない。native ビルドする example では個別に `-lglfw` 等を指定する必要がある
- `extern "C"` を含む `.mbt` ファイルは `moon.pkg` の `targets` で native のみに制限する（`supported-targets` だけでは不十分）
