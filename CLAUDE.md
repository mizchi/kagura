# kagura - MoonBit 2D Game Engine

## プロジェクト構成

- `src/` - 公開ファサード（`mizchi/kagura`）
- `<layer>/<name>/` - ライブラリ本体。各ディレクトリが独立した moon module で、
  `moon.work` のメンバー。layer は下表の 5 つ
- `examples/<category>/<name>/` - サンプルプロジェクト（各ディレクトリが独立した moon プロジェクト）
  - カテゴリ: `games`（遊べるサンプル）, `demos-2d` / `demos-3d`（単機能デモ）, `smoke`（CI の最小確認）, `experimental`
- `scripts/` - ビルド・開発スクリプト
- `justfile` - タスクランナー

### レイヤ

| layer | 中身 | モジュール |
|---|---|---|
| `core/` | 外部依存ゼロ、または core 契約のみの基盤 | `kagura_core`, `geom`, `mesh3d` |
| `platform/` | ターゲット固有の host / 窓口層 | `kagura_platform`, `js_runtime`, `web_runtime_hooks`, `native_runtime_hooks` |
| `engine/` | 描画・アセット・ランタイム基盤 | `kagura_engine`, `renderer2d`, `text`, `widget2d`, `ui`, `atlas`, `asset_loader`, `audio`, `anim3d`, `physics` |
| `game/` | ゲーム側のロジック（描画基盤に依存してよい） | `kagura_game`, `machinations`, `pathfind` |
| `editor/` | オーサリング／確認用ツール | `effect-studio`, `modeling3d` |

`web_runtime_hooks` / `native_runtime_hooks` は host hook の実装（`kagura_platform` の
注入先）で、ほぼ全ての example と editor tool が import する。publish 対象ではないが
ルート `moon.work` のメンバーなので `moon check` の対象に入る。

依存の向きは `core <- platform <- engine <- game` の一方通行。`editor/` はどれに依存しても
よいが、**誰からも依存されない**（publish 対象外で、それぞれ自前の `moon.work` を持つ）。
実際の許可リストは `scripts/moon-boundary-utils.mjs` の `DEFAULT_IMPORT_BOUNDARY_POLICY`
にあり、`just check-release` が `moon.pkg` の import を突き合わせる。

ディレクトリ名は publish 名と一致しないことがある（`engine/ui` = `mizchi/kagura_ui`）。
**正はいつも `moon.mod` の `name`** で、ディレクトリはただの置き場所。

モジュールを移動したら、パスを持っている次の場所も一緒に直すこと。
素朴な grep では 3 種類を取りこぼす: **深さが変わる相対パス**、**セグメント分割された
literal**（`resolve(cwd, "editor", "modeling3d")`）、**正規表現リテラル内のエスケープ済み
パス**（``/`editor\/modeling3d\/…`/``）。

- `moon.work` — ルート、各 example、各 editor tool とその example
- `moon.mod` の `--moonbit-unstable-prebuild` — 階層が変わった分 `../` を増減する
- `scripts/moon-release-utils.mjs` の `DEFAULT_RELEASE_MODULE_DIRS`
- `scripts/publish.sh` の `MODULES`（publish 順。トポロジカル順を保つ）
- `justfile` の example ループ
- example の path 依存（`examples/experimental/crater_paint`, `examples/smoke/browser_headless`）
- `scripts/{dev-server,build-pages,serve-wasm-smoke}.mjs` の example ルート

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
| `mizchi/font@0.7.3`（0.7.4 が最新） | 0.7.4 が `moonbitlang/x@0.4.50` を引く。0.4.50 で `@x/fs.IOError::to_string` が消えたが、`mizchi/parquet` が native 経路でまだ呼んでいる（`examples/games/hacknslash_3d`）|

parquet 側が x 0.4.50 に追従したら font の天井を外せる。上げるときは
`moon check --deny-warn` を **js と native の両方**で回すこと。js だけだと
`@x/fs` を使う経路がそもそもコンパイルされず素通りする。

## ビルド・テスト

```bash
just check          # workspace + 全 example (js)
just test           # workspace + 全 example (js)
just check target=native  # native ビルド確認
just check-release  # リリース前チェック（ローカルパス依存の検出）
```

`check` / `test` は 2 段に分かれている。workspace だけ回したいときはこちら:

```bash
just check-workspace          # moon check --deny-warn だけ
just test-workspace           # root の moon test + lib/web/*.test.mjs だけ
just check-examples 2/4       # example の 2/4 shard だけ
just test-examples 2/4        # 同上
```

**example ループが CI の律速。** example はそれぞれ独立した moon module なので、
毎回依存クロージャをフルにビルドし直す。実測で、旧 `check-test-matrix` の native leg は
**22m46s のうち 19m56s（87%）が example ループ**だった。だから CI では shard に割って
並列化し、workspace の check/test は `js` / `native-macos` job に任せている（同じコマンドを
2 回走らせていた）。

どの example がどの shard に属するかは `scripts/example-projects.mjs` が決める。
justfile 側にスキップ規則を書かないこと — 全 runner が同じ commit から同じ分割を
導けないと、ビルドされない example や 2 回ビルドされる example が出る。規則は
`scripts/example-projects-utils.mjs` にあり、`scripts/*.test.mjs` が CI で
「shard の和集合が全体と一致し重複が無い」ことを固定している。

| | check | test |
|---|---|---|
| js | 33 | 33 |
| native | 45 | **11** |

native の test が極端に少ないのは、`wgpu_native` をリンクする example が native では
check のみになるから。だから native の shard 数を 4 より増やしても縮まない
（`ceil(11/4)` も `ceil(11/5)` も 3）。macOS runner は課金が 10 倍なので上げていない。

分割は round-robin。連続ブロックで割ると `examples/games/*` が 1 runner に固まる。
**プロジェクトごとのコスト表は作らないこと** — 保守されなくなる。

### shard 化後の実測

| | 変更前 | 変更後 |
|---|---|---|
| run 全体 | 16m05s（その前は 22m46s） | **7m54s** |
| 最遅 job | `check-test-matrix (native)` 16m05s | `js` 7m49s |
| example の最遅 shard | — | `examples (native 1/4)` 7m41s |
| macOS runner 時間（example 分） | 約 23m（1 job） | 約 23m（4 job 合計） |

**macOS の課金時間は増えなかった。** 4 分割で setup が 4 回に増えた分を、重複していた
root の `moon test --target native`（2m06s）を落とした分が相殺した。当初は 30m 程度に
増える見込みだったが、実測は横ばい。

shard の imbalance は実測 29%（native 7m41s 対 4m46s、js 3m34s 対 2m12s）で、
ローカル実測の 15〜24% より大きい。ただし **native を均し直しても run は縮まない** —
最遅 shard 7m41s は既に `js` job の 7m49s とほぼ同じで、critical path は example
ループから `js` job に移っている。次に削るならそこ（7m49s のうち 4.3m が Playwright VRT）。

## ゲーム UI の検証

入力は 2 本。**フレーム PNG**（何が見えているか）と **UI snapshot**（それが何なのか）。
どちらも browser 無しで取れる。

```bash
just render ui_demo "--frames 3"           # フレームを直接描く（browser も GPU も不要）
just ui-check output/ui-snapshot.json      # 文字あふれ/クリップ/画面外/重なり/hit box ずれ
just ui-elements output/ui-snapshot.json   # vlmkit diff png --elements-json 用に変換
just ui-asset-check <png>                  # スプライト/アイコンの入庫ゲート
just vlm-ui-review ui_demo "--dry-run"     # 決定的ゲート → その後だけ VLM
```

手順とルールの詳細は `docs/tools/ui-verification-runbook.md`。

### フレームを直接レンダリングする

`@engine.run` は canvas に触る前に `globalThis.__kaguraHeadless` を見る。あれば
アニメーションループに入らず、example 自身の update を N tick 回して draw 1 回を
**CPU ラスタライザ**（`engine/kagura_engine/raster`、`@gfx.GraphicsDriver` の実装）に
流し、PNG を `__kaguraHeadlessFrame` に置く。example 側の変更は要らない。

- Linux の canvas screenshot が透明で Dawn readback も返らない問題を丸ごと迂回する
- 描くのは **2D コマンドだけ**。3D は `skipped_commands` に数えて描かない（`just render` が警告する）
- **テクスチャは載る。** `web_runtime_hooks` が同期した source image を headless の間だけ
  `globalThis.__kaguraSourceImages` に出し、engine が拾って rasterizer に登録する
  （`@gfx.GraphicsDriver` に upload が無く、platform は engine の下なので global を挟む）。
  `just render` が `N texture(s)` を出す。**0 なのにアトラスを使う example は絵が欠けている**
- 未登録の texture id は 1x1 白のまま（WebGPU の未バインドスロットと同じ）
- Node 側ホストは `lib/web/kagura-headless-frame.js`。viewport スタブは
  **engine が解決した実サイズ**を返す（CSS サイズでカーソルをスケールする example がずれる）

### VLM を混ぜる順序

**決定的ゲートが先、VLM は残りだけ。** overflow や hit box のズレは
`ui-integrity-gate` が証明できるので、モデルに探させると再現しないレビューになる。
`just vlm-ui-review` はこの順序を強制し、exit code は決定的ゲートだけが決める。
修正後は `--compare <前のPNG>` で撮り直すと、変化が狙った UI ノードに出たか確認できる。

### snapshot 側の約束

- `text_measured` は描画側と**同じ算術**で測る（dot text は `@renderer2d.dot_text_size`）
- `path` は実ツリーの階層を反映させる（ツーリングが祖先関係を読む）
- `extern "js"` を含むファイルは `moon.pkg` の `targets` で js に限定し、native は no-op スタブ
- `@ui.compute_layout` は **post-order**（子が先、コンテナが後）。`@ui.hit_test` は
  その順で**最初に**当たったノードを返す。逆順を仮定すると常に最外周のルートが当たる

## スナップショットテスト (VRT)

2 本ある。**2D は frame VRT が gating**、3D と実 GPU 経路は Playwright VRT（非 gating）。

### frame VRT（browser 不要・gating）

```bash
just frame-vrt              # 全エントリを baseline と比較（CI が回している）
just frame-vrt ui_demo      # 1 example だけ
just frame-vrt-update       # 意図した変更のあとに貼り直す
```

CPU ラスタライザで描くので GPU もブラウザも要らず、**同じコマンド列から同じバイト列**が
出る（プロセスをまたいで検証済み）。だから閾値ゼロで gate できる。対象は
`scripts/frame-vrt-manifest.mjs`、baseline は `e2e/frame-vrt-snapshots/`。

貼る前に 2 つ拒否する:

- **3D を含むフレーム**（`skipped_commands > 0`）。シーンの欠落を baseline に焼き付けて
  永久に通るだけになる
- **ほぼ単色のフレーム**。落ちない baseline はカバレッジではない — 純黒 18 枚を
  抱えていた過去がその証拠。意図的なら エントリに `allowUniform` で理由を書く。
  現状これを使っているのは `sprite_anim` の 4 エントリだけで、アトラスの 1 セルを
  全画面に描く example なので単色が正しく、**どの色か**がテクスチャ経路と
  アニメーションの進みを固定している

**`vlmkit diff png --threshold` の既定値 0.1 は使わないこと。** pixelmatch の知覚距離で、
ブラウザのアンチエイリアス揺れを許すための値。実測: `ui_demo` の全ボタンを
`#4a4a6a` → `#4a6a4a` にすると **19.92% のピクセルが変わるのに 0.00%「no changes」と出る**。
CPU ラスタライザに許すべき揺れは無いので `--threshold 0` を渡す。

### Playwright VRT（3D と実 GPU、現状 CI では非 gating）

`ci.yml` が `--update-snapshots` で実行。Linux では canvas screenshot が透明かつ
Dawn readback が完了しないため。移植可能なキャプチャの整備は #9。

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
2. `e2e/vrt.spec.ts` の `VRT_EXAMPLES` に**名前だけ**追加（タイトル画面）。テスト名に
   出るカテゴリは `examples/<category>/` から導出されるので、書くところは無い
3. スナップショットモードが必要なら `SNAPSHOT_TESTS` にも追加
4. `just e2e-vrt-update` でベースライン生成

example のディレクトリ探索は `scripts/example-dirs.mjs` に一本化してある
（`findExampleDir` / `findExampleCategory` / `listExampleNames`）。dev server、
VRT server、spec がこれを共有するので、置き場所の規則はここだけ直せばよい。

## ベンチマーク

```bash
just bench          # 全 bench（moon bench）
just bench-gate     # baseline と比較。両側（1.5x 遅い / 3x 速い の両方で落ちる）
just bench-update   # 意図した変化のあとに貼り直す
```

`moon bench` は **closure 全体を計測し、iteration ごとの setup フックが無い**。
だから closure がやったことは全部その数字に入る。名前で boundary を宣言すること
（`step_` / `phase_` / `phase_reset_` / `build_`）。setup を closure から追い出せない
分は、setup だけの bench を並べて**床として引けるように**しておく。

**ゲートは速くなった側も見る。** 遅くなったことしか検知しないゲートは、ワークロードが
消滅した bench を永久に緑にする —— contact を生まなくなる、constraint 配列が空になる、
シーンが寝る。どれも bench は速くなる。純黒 18 枚の baseline と同じ失敗である。
閾値が 3x なのは baseline が機械依存で、別の機械では無関係な bench が両方向に 2x 動くため。

**速度ゲートだけでは足りないので、fixture が名前どおりの仕事を生んでいることを test で
assert する。** `engine/physics/*/bench_fixtures_wbtest.mbt` が例:
pair 数と constraint 数が body 数以上ある、size sweep で仕事が実際に増える、
`scatter` は contact 0、寝ている fixture は本当に寝ている、reset が測定対象フレームを
完全に復元する、solve を 2 周させても 2 周目が no-op になっていない。

**bench は出荷されている関数を呼ぶこと。** ループを bench 側にコピーすると、片方だけ
直したときに bench が出荷されていないコードを測り続ける。`physics2d` / `physics3d` は
`step()` を phase 関数（`phase_broadphase_pairs` 等）へ分解し、`step()` と bench が
同じ関数を呼ぶようにしてある。

**state を持つものは毎 iteration リセットする。** `step` は world を変えるので、
reset しないと pile は 30 iteration ほどで沈んで寝て、bench は solver ではなく
sleep fast path を測り始める（名前は変わらないまま）。solver の accumulator も戻す:
収束すると impulse 書き込みが near-zero 分岐に落ち、「もう何も解いていない solve」に化ける。

**ただし「リセットした状態」はパイプラインの途中の phase が見る状態ではない。**
substep loop の中の phase を reset 直後の body から測ると、速度が収束近くにあるので
impulse 書き込みがガードに落ちる。allocation-bound なループではそれが
「割り当てを飛ばす」ことを意味するので、**安い分岐だけを測る**。実測で
`phase_solve_velocities` は solve pass を 5x 過小評価していた。対策は
`physics3d/world_bench.mbt` の `substep_` prefix bench —— 1 substep の**累積 prefix** に
して隣同士の差を取る。iteration ごとの setup hook が無い以上、現実的な状態に到達する
処理は測定に含めるしかないので、累積にして差を引くのが唯一正直な形。

**isolated bench で phase を切り分けられないときは、設定を振って傾きを取る。**
`substeps` を 1/2/4/8、`velocity_iterations` を 1/2/4 に振れば、出荷している `step` を
そのまま回したまま「1 substep」「constraint 全体 1 パス」の値段が出る。ただし
`substeps` を変えると `sub_dt` も変わって solver の挙動が変わるので、**順位付けには
使えるが絶対値として引用してはいけない**（実測で `substep_` 連鎖の 2 倍出た）。

設計・実測・ここから出た作業項目は `docs/performance/physics-benchmarks.md`、
3D をこの bench で最適化した記録は `docs/performance/physics3d-optimization.md`。

### JS ターゲットの割り当てコスト

物理エンジンで 2.5x 取れた最適化はすべて同じ 1 つの事実に帰着する。**MoonBit の JS
出力では、`Int64` と immutable struct はどちらも heap object。**

- **`Int64` は `BigInt` になる。** 生成 JS では演算ごとに `BigInt.asUintN` 等が挟まる。
  broadphase の cell key を 1 個作るのに割り当て 6 回、`Int64::hash` にさらに 8 回だった。
  **hot path の `Map` key に `Int64` を使わないこと。** 3 軸の cell 座標のように
  32bit に収まらないキーは、32bit hash の open addressing + 座標を保存して比較、で置く
  （`collision3d/broadphase.mbt`）
- **`Vec3` も `RigidBody` も immutable struct なので、素直なベクトル演算は
  中間オブジェクトを撒く。** hot loop（solver の inner loop）は
  `Array[Double]` の平坦な列に移してスカラーで書く（`physics3d/velocity_state.mbt`）。
  Box2D v3 の `b2BodyState` と同じ形で、GC ターゲットでは cache locality よりも
  「割り当てが消える」ことが本体
- **手で展開するときグルーピングは load-bearing。** `n.scale(j).scale(m)` は
  `(n.x * j) * m`、`r.scale(j * i)` は `r.x * (j * i)`。各サイトの括弧を保存すれば
  結果は bit 一致する。「だいたい同じ」と bit 一致の差はここだけ
- native でも同じだけ速くなった（2.07x）。`Int64` が無料の native でも broadphase が
  1.86x になるのは Map と per-cell 配列割り当ても消えたから。**JS 固有の話ではない**
- 効いたかどうかは**ペア測定**で見ること。このコンテナの run 間分散は
  `phase_contact_constraints` で ±25% あり、単発では 1.2x が読めない。
  main と branch を交互に回して中央値を取る（`git worktree add /tmp/x origin/main`）

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
