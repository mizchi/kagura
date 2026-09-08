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
ゼロを返せばよい。実装は `lib/web/wasm-async-host.mjs`、動く例は
`examples/smoke/wasm_async_smoke/`。

```bash
just wasm-async-smoke   # ビルド + 最小 JS ホストで実行
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

- worker 側: `lib/web/wasm-async-worker.mjs`（`makeFrameAwareWait`）
- main 側: `lib/web/wasm-async-driver.mjs`（node は `runInWorker`、
  ブラウザは `createBrowserFrameSource`）
- ゲストは `kagura_web.frame_number` でカウンタを読む。フレーム源が無いときは
  0 のままなので、**同じバイナリが worker あり／なしの両方で終了する**

```bash
just wasm-async-smoke   # 単体ホストと worker + フレームクロックの両方を実行
```

実測（`examples/smoke/wasm_async_smoke`）:

| | frames observed | waits | wall |
|---|---|---|---|
| 単体ホスト（フレーム源なし） | 0 | 127 | 536ms |
| worker + 8ms フレームクロック | 5 | 25 | 147ms |

テスト済みなのは node の `worker_threads` 経路のみ。ブラウザ Worker は同じ
プリミティブだが未検証（`SharedArrayBuffer` に COOP/COEP が要る）。

## 注意事項

- `cc-link-flags` は依存パッケージから伝播しない。native ビルドする example では個別に `-lglfw` 等を指定する必要がある
- `extern "C"` を含む `.mbt` ファイルは `moon.pkg` の `targets` で native のみに制限する（`supported-targets` だけでは不十分）
