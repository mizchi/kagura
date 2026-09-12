# ゲーム UI 検証ランブック

canvas / WebGPU 上に描くゲーム UI を、DOM なしで決定的に検証するための手順。

背景と全体像は [`vlmkit-game-ui-verification.md`](./vlmkit-game-ui-verification.md)、
作業一覧は [#19](https://github.com/mizchi/kagura/issues/19) を参照。
現時点の完了範囲と残作業は [Issue照合表](./ui-verification-issue-status.md) に整理した。

**更新:** インストール済みvlmkit 0.11.1は `check integrity --elements ... --image ...` を
サポートする。以下の「DOM版」はHTML/URL入力の経路を指す。`just ui-vlmkit-check` は
画像版に必要な文字実測・clip・zを保持した専用データを渡す。従来の `ui-elements` は
PNG差分用のまま。vlmkit の画像版は computed color が無いので `low-contrast-text` を
skip する。その判定は `just ui-check --image` がフレーム PNG からノードを切って行う。

---

## 1. 全体の流れ

```
engine (MoonBit)                         Node (browser 不要)
─────────────────                        ─────────────────────
example の update/draw
  └ @gfx.DrawTrianglesCommand
      └ @raster.RasterTarget (CPU) ──> globalThis.__kaguraHeadlessFrame (PNG)
                                          │
@ui.UISnapshot                            ├─> vlmkit diff png / check palette / check asset
  └ publish_ui_snapshot ──> __kaguraUISnapshot
                              │           │
                              ├─> scripts/ui-integrity-gate.mjs         → 決定的な欠陥リスト
                              ├─> scripts/ui-snapshot-to-vlmkit-elements.mjs
                              │      └─> vlmkit diff png --elements-json → diff を UI ノードに帰属
                              └─> scripts/vlm-ui-review.mjs             → 決定的ゲートの後だけ VLM
```

2 本の入力がある。**フレーム PNG**（何が見えているか）と **UI snapshot**（それが何なのか）。
どちらも browser 抜きで取れる。

UI snapshot は「DOM の代わり」。ノード矩形・クリップ矩形・**実測したテキスト幅**・hit 矩形・
フォーカス順を持つので、`vlmkit check integrity` が DOM でやっている判定を engine の値で行える。

---

## 1.5 フレームを直接レンダリングする（browser も GPU も Playwright も無し）

```sh
just render ui_demo "--frames 3"
just render ui_demo "--state hover --cursor 100,74"
```

```
ui_demo [default]: 640x480 after 3 tick(s), 980 triangles
  png: output/frames/ui_demo/ui_demo.png
  snapshot: output/frames/ui_demo/ui_demo.snapshot.json
  elements: output/frames/ui_demo/ui_demo.elements.json
```

`@engine.run` / `run_game` は canvas に触る前に `globalThis.__kaguraHeadless` を見る。
セットされていればアニメーションループには入らず、example 自身の `update` を N tick 回して
`draw` を 1 回だけ CPU ラスタライザに流し、PNG を `__kaguraHeadlessFrame` に置いて戻る。
**example 側の変更はゼロ**で、`@engine.run` を使っている example はすべて対象になる。

| 部品 | 役割 |
|---|---|
| `engine/kagura_engine/raster/` | `@gfx.GraphicsDriver` の CPU 実装。NDC 三角形・scissor・uniform 色・テクスチャ・blend equation |
| `engine/kagura_engine/headless.mbt` | N tick 進めて 1 フレーム描く（全ターゲット） |
| `engine/kagura_engine/headless_js.mbt` | `__kaguraHeadless` の読み取りと PNG の publish（js のみ） |
| `assets/web/kagura-headless-frame.js` | Node 側ホスト。viewport スタブと module 再実行 |
| `scripts/render-frame.mjs` | build → render → PNG / snapshot / elements を書く |

**限界（黙って嘘をつかないための約束）:**

- CPU ラスタライザが描くのは **2D コマンドだけ**。3D（`vertex_stride_hint` 8 / 16）は
  深度もプロジェクションも持たないので描かず、`skipped_commands` に数える。
  `just render` はその数を warning で出す。3D の目視は `just capture`（native）か実ブラウザ側
- **アトラスのテクスチャは載る。** `@gfx.GraphicsDriver` に upload が無く、実バックエンドは
  `web_runtime_hooks` から直接 GPU に送っているので、headless の間だけ hooks が
  source image を `globalThis.__kaguraSourceImages` に出し、engine が拾って
  `register_texture` する（`platform/` は `engine/` の下なので直接呼べない）。
  `just render` の `N texture(s)` が実際に載った枚数。**0 なのにアトラスを使う
  example は絵が欠けている**
- 未登録の texture id は 1x1 白としてサンプルする（WebGPU の未バインドスロットと同じ）
- `document.querySelector("canvas")` などに答える viewport スタブは
  「engine が解決した実サイズ」を返す。CSS サイズでカーソルをスケールする example が
  ずれないための約束で、スタブ側が勝手なサイズを名乗ってはいけない

---

## 2. snapshot を engine から出す

### SceneGame（example 側の変更は不要）

`@scene.run` / `@scene.run_game` は draw のたびに view tree からラベルを集めて
snapshot を publish する。測り方は `append_dot_text` と同じ `dot_text_size`。
キー付き `group` は path の祖先になる。keyed `rect` / `rect_outline` は描画矩形を
hit box として出す（HP バー、End Turn）。ラベルのない world rect（パイプ、タイル）
は出さない。`just render flappy_bird` が `.snapshot.json` を書くのはこの経路。

`@ui` レイアウトや `@hud.HudContext` で描く画面は自動では出ない。ui_demo は前者、
hacknslash_3d は後者で、どちらも example 側の adapter が `UISnapshot` を組む。

### JS ターゲット

`@ui.publish_ui_snapshot` を毎フレーム呼ぶと `globalThis.__kaguraUISnapshot` に
`{ json, parsed }` が入る（`__kaguraModelingContext` と同じ形）。

実装例: `examples/demos-2d/ui_demo/snapshot.mbt` + `snapshot_js.mbt`

```moonbit
// snapshot.mbt — 全ターゲット共通。DemoState から UISnapshot を組む
fn DemoState::ui_snapshot(self : DemoState) -> @ui.UISnapshot { ... }

// snapshot_js.mbt — js のみ (moon.pkg の targets で制限)
fn publish_snapshot(state : DemoState) -> Unit {
  @ui.publish_ui_snapshot(state.ui_snapshot())
}
```

`extern "js"` を含むファイルは `moon.pkg` の `targets` で js に限定し、native 側は
no-op のスタブを置く（`supported-targets` だけでは不十分）。

### 押さえるべき点

| 項目 | なぜ |
|---|---|
| `path` は**実ツリーの階層**を反映させる | ツーリングは path から祖先関係を読む。パネル内のラベルは衝突ではない、親からはみ出した子は欠陥 — flat な path だとどちらも判定できない |
| `text_measured` は**実測値**を入れる | 描画側と同じ算術で測らないと overflow 判定が嘘になる。dot text は `@renderer2d.dot_text_size` を使う（`append_dot_text` と共有） |
| `clip` は実際の scissor 矩形 | スクロールコンテナの子は親からはみ出して当然。クリップ後も見えている分だけが欠陥 |
| `z` は描画順 | 同 z の重なりだけを衝突として扱う。z が違うのは意図的なレイヤリング |
| `dpr` を正しく入れる | キャプチャした PNG は dpr 倍。変換時に矩形をスケールしないと画像と全部ズレる |

### native ターゲット

native は browser global が無いので、フレーム PNG と context JSON をファイルに書く。
この経路は `engine/kagura_engine/capture` にあり（以前は 3D authoring example に
private だった）、web の canvas capture と Linux Dawn readback が両方使えない現状では
**これが移植可能な唯一のキャプチャ経路**。

```sh
just capture ui_demo
just capture pbr_demo output/capture "--backend gpu"
just ui-capture ui_demo idle standard
just ui-capture ui_demo idle standard "--backend gpu"
# → PNG + context JSON + summary.txt
```

`just capture` は `scripts/stage-capture-config.mjs` で config を置き、native で 1 回走らせる。
`@engine.run` がこれを読む。`backend=cpu`（既定）は CPU ラスタライザ、`backend=gpu` は
実 wgpu。3D は CPU では `skipped_commands` で abort するので gpu を使う。
example は `mizchi/native_runtime_hooks` を import している必要がある（gpu の readback）。

| API | 用途 |
|---|---|
| `@capture.parse_capture_config(text)` | 設定のパース（全 target、pure） |
| `@capture.encode_rgba8_png(w, h, pixels)` | readback バッファ → PNG |
| `@capture.binarize_rgba8(pixels)` | シルエット確認用の白黒化 |
| `@capture_native.read_capture_config()` | 設定ファイルの読み込み（native） |
| `@capture_native.write_capture_artifacts(...)` | 3 つの artifact 書き出し（native） |

2D UI は `just ui-capture`（CPU、JS headless と snapshot 一致を検査済み）。3D と実 GPU
パイプラインは `just capture <example> output/capture "--backend gpu"`。CPU ラスタライザが
描かない 3D コマンドは gpu 側で描いて PNG にする。

---

## 3. 決定的ゲートを回す

```sh
just ui-check output/ui-snapshot.json
just ui-check output/ui-snapshot.json "--image output/frames/ui_demo/ui_demo.png"
```

```
source: output/ui-snapshot.json
screen: 640x480 dpr=1 state=demo nodes=12
verdict: CLEAN
```

欠陥があると vlmkit と同じ「機械可読な修正リスト」形式で出て、exit 1 になる:

```
verdict: DEFECTS
[text-overflow] button_1: measured text 57x15 exceeds rect 40x36 (width by 17px)
[protrusion] button_1: extends past the screen edge (right 20px)
[hit-box-mismatch] button_1: hit rect (16,56) 184x36 differs from drawn rect (620,56) 40x36 by 604px
[child-escape] button_1: escapes parent panel_7 unclipped (right 108px)
[low-contrast-text] hp_label: contrast 1.82:1 < 4.5:1 floor (fg #777777 on bg #ffffff, 12px)
```

### 検出する欠陥

| kind | 内容 |
|---|---|
| `zero-size` | visible なのに面積ゼロ（潰れたコンテナ） |
| `text-overflow` | 実測テキストがノード矩形を超える |
| `text-clipped` | テキスト矩形が scissor 矩形に切られている |
| `protrusion` | 画面端からはみ出している |
| `offscreen` | 完全に画面外 |
| `safe-area-violation` | 宣言された safe area に侵入 |
| `text-collision` | 同 z のテキストノード同士が重なる |
| `hit-box-mismatch` | hit 矩形が描画矩形とずれている |
| `child-escape` | クリップされずに親からはみ出している |
| `low-contrast-text` | フレーム PNG から切ったテキストの前景/背景が WCAG AA 未満（通常 4.5:1、24px 以上は 3:1） |

### 誤検知を避けている箇所

ゲーム UI では「一見欠陥だが正当」なパターンが多いので、以下は意図的に除外している:

- **全画面の背景レイヤ**は `safe-area-violation` の対象外 — 画面を覆うノードが inset を守るのは不可能
- **全画面の親からの `child-escape`** は報告しない — 画面に対する `protrusion` と同じ事実の二重計上
- **クリップ後に親の中に収まる子**は `child-escape` にしない — スクロールコンテナの正常動作
- **z が違う重なり**は `text-collision` にしない — 意図的なレイヤリング
- **祖先・子孫関係にあるノード同士**の重なりは衝突としない
- **面積ゼロのノード**は `zero-size` だけ報告して他の幾何判定を打ち切る — 原因を 1 行で示す

### 意図的なパターンを許可する

```sh
just ui-check output/ui-snapshot.json "--allow 'protrusion@minimap;意図的に画面外へ滲ませている'"
```

- 理由は**必須**、未知の kind は**エラー**（タイポでの黙殺を防ぐ）
- 許可された finding も `exempted:` として**必ず一覧に出る**
- **何にもマッチしなかったルールは警告 + exit 1** — 古い suppression 自体が欠陥

その他: `--tolerance <px>`（既定 0.5、サブピクセル誤差の遊び）、`--json`、`--advisory`、`--image <png>`（`low-contrast-text`）。

### テキスト / i18n ストレス

DOM の `vlmkit stress i18n` は canvas では空振りするので、スナップショットの文字列を
膨張してから同じ integrity を回す。

```sh
just ui-i18n-stress output/ui-snapshot.json
just ui-i18n-stress output/ui-snapshot.json "--profiles all"
just ui-i18n-stress output/ui-snapshot.json "--profiles de,digits"
```

| profile | 何をするか |
|---|---|
| `de`（既定） | vlmkit と同じ単語パディング、係数 1.35 |
| `fullwidth` | ASCII → 全角。セル幅は 2 倍、グリフは HUD アトラスに無い |
| `rtl` | 同じ長さのアラビア文字 |
| `emoji` | 末尾に ⚠️ |
| `digits` | 数値を `9,999,999` / `-99999` に置換 |

再計測は `@renderer2d.dot_text_size` と同じ式。`glyph_pattern` が空白セルを返す
文字は `[missing-glyph]`。ASCII HUD で `--profiles all` を回すと必ず tofu が出るので、
CI の既定は `de` だけ。

---

## 4. pixel diff を UI ノードに帰属させる

```sh
just ui-elements output/ui-snapshot.json output/vlmkit-elements.json
pnpm exec vlmkit diff png base.png current.png --elements-json output/vlmkit-elements.json
```

```
diff:     0.91% (11200 / 1228800 px)
regions:  1
  (512,640) 256x64 [content] #508cdc -> #dc8c50
selectors:
  (512,640) 256x64 -> #pause_button (medium, coverage 0.6836)
```

`--scale` は既定で snapshot の `dpr` を読む。PNG を 1 倍で撮っているなら `--scale 1` を渡す。

**帰属精度の注意**: vlmkit は diff 領域を粗いブロックに丸め、スコアが「領域を含む最大の box」を
優先しがちなので、小さい画面ではネストした HUD の根本原因を外すことがある
（[mizchi/vlmkit#117](https://github.com/mizchi/vlmkit/issues/117)）。
**dpr を上げてキャプチャすると領域が相対的に細かくなり、当たりやすくなる**（1280x960 で検証済み）。

---

## 5. テーマと素材の入庫ゲート

フレームの支配色を `editor/theme.json` のトークン表と突き合わせる。トークンから
`maxDistance` 以上離れた色はハードコードされたリテラル。使っていないトークンは
一覧に出すだけで落とさない（hover 色を idle フレームが塗らないのは正常）。

```sh
just ui-theme-check output/frames/ui_demo/ui_demo.png
just ui-theme-check output/frames/ui_demo/ui_demo.png examples/demos-2d/ui_demo/editor/theme.json
just ui-matrix-gates --theme   # 各 example の editor/theme.json を *.standard セルに当てる
```

スプライト / アイコンを UI スロットに入れる**前**に通す。browser 不要の純 PNG 演算。

```sh
just ui-asset-check assets/icons/potion.png "--slot 32x32 --expect-transparent --against-bg '#141822'"
just ui-assets ui_demo
```

`editor/assets.json` の各エントリが 1 回の `check asset`。空リストは成功（スプライトを
持たない example を落とさない）。スロット aspect 適合 / 透過 vs マット背景 / 占有率 /
図地コントラスト / パレット調和を判定。

---

## 5.5 フレームのリグレッションを gate する（browser 不要）

```sh
just frame-vrt              # 全エントリを baseline と比較
just frame-vrt ui_demo      # 1 example の全 state だけ
just frame-vrt-update       # 意図した変更のあとに貼り直す
```

```
ok       ui_demo
ok       ui_demo.hover
ok       ui_demo.focus
ok       machinations_demo
...
frame VRT: 13 checked, all clean
```

CPU ラスタライザは同じコマンド列から**同じバイト列**を出す（別プロセス間で検証済み）。
GPU もブラウザもドライバもコンポジタも噛まないので揺れる要素が無く、**閾値ゼロで
gate できる**。`e2e/vrt.spec.ts` が `--update-snapshots` でしか回せないのとはここが違う。

- 対象の宣言: `scripts/frame-vrt-manifest.mjs`
- baseline: `e2e/frame-vrt-snapshots/`（`.moonignore` で publish 対象外）
- 比較: `vlmkit diff png`。UI snapshot がある example では `--elements-json` を渡すので、
  落ちたときに**どの UI ノードが動いたか**が出る
- CI: `ci.yml` の js job（Playwright のインストール前 — ブラウザを待たずに失敗を出す）

### 落ちたときの読み方

```
FAILED   ui_demo: 19.92% of pixels changed at (16,48) 192x144 -> .panel (high, coverage 1)
```

`output/frame-vrt/` に今のフレーム、`test-results/png-diff/` に heatmap が出る。
baseline と並べて見て、意図した変更なら `just frame-vrt-update`。

### baseline に貼らせないもの

落ちない baseline は**カバレッジではない**。純黒 18 枚を抱えて「視覚ゲートがある」と
思い込んでいた過去がその証拠なので、2 つを機械的に拒否する:

| 拒否 | 理由 |
|---|---|
| `skipped_commands > 0`（3D を含む） | シーンの欠落を焼き付けて永久に通る |
| ほぼ単色のフレーム | 落ちない baseline はカバレッジではない。意図的なら entry に `allowUniform` で理由を書く |

`allowUniform` の唯一の使用例が `sprite_anim` の 4 エントリ。アトラスの 1 セルを
全画面に描く example なので単色が正しく、**どの色になるか**でテクスチャ経路・
`split_sprite_sheet` の UV・アニメーションの進み（15 tick ごとにセルが変わる）を
まとめて固定している。ブリッジを壊すと 4 本とも `#ff0000 -> #ffffff` のように落ちる。

### `vlmkit diff png --threshold` の既定値を使ってはいけない

既定は **0.1**。pixelmatch の知覚（YIQ）距離で、ブラウザのアンチエイリアスや
サブピクセルの揺れを許すための値。**決定的なラスタライザには過剰**で、実害が出る。

実測（`ui_demo` の全ボタンを `#4a4a6a` → `#4a6a4a` にした場合）:

| `--threshold` | 報告される diff |
|---|---|
| 0 / 0.01 / 0.05 | 19.92% (61194 px) |
| **0.1（既定）** | **0.00% "no changes"** |

画面いっぱいの緑のボタンが「変更なし」で通る。`scripts/frame-vrt.mjs` は
`--threshold 0` を渡している。**許すべき揺れが無いなら 0 を渡すこと。**

また `diff:` 行がそもそも出なかった場合、`parseVlmkitDiff` は `changedRatio: null` を
返し、gate は**失敗**扱いにする。測れなかったことを「差分ゼロ」と読むと全部通る。

---

## 6. VLM に主観品質を聞く

決定的ゲートで測れるものは**モデルに探させない**。overflow も hit box のズレも
WCAG コントラストも `ui-integrity-gate` が証明できるので、それを VLM にやらせると
再現しないレビューになる。モデルに残すのは「測って決まらないもの」— 可読性・視覚的階層・
バランス・crop では見えない知覚的コントラスト。

```sh
just vlm-ui-review ui_demo "--frames 3 --dry-run"          # リクエストを組むだけ
just vlm-ui-review ui_demo "--matrix --dry-run"            # verification.json の全セル
OPENROUTER_API_KEY=... just vlm-ui-review ui_demo "--frames 3"
just vlm-ui-daemon-start ui_demo                           # bundle を保持、POST /review
```

1 回のコマンドで render → 決定的ゲート → （通れば）VLM → レポートまで進む。

```
# UI review: ui_demo [hover]

frame: 640x480, 3 tick(s), 980 triangles, 0 skipped command(s)

## Deterministic gate

CLEAN -- no measurable defect in the frame or the UI snapshot.

## Change since the baseline frame

2.07% of pixels changed.

Attributed to:
- (16,48) 192x48 -> .button (medium, coverage 0.7188)
```

| フラグ | 意味 |
|---|---|
| `--dry-run` | リクエスト JSON を書き出して API は叩かない。プロンプトの確認用 |
| `--compare <png>` | 直前のフレームとの diff を取り、変化を UI ノードに帰属させる。**修正が狙った所に届いたかの確認**はここ |
| `--force-vlm` | 決定的ゲートが落ちても VLM を回す（既定は止める） |
| `--state` `--cursor` `--keys` `--frames` | 見たい状態の作り方。`just render` と同じ |
| `--note <text>` | 「このフォントはわざと 1px」のような前提をレビュアに渡す |
| `--provider` `--model` | 既定は OpenRouter。環境変数は 3D 側と同じ `OPENROUTER_API_KEY` |

exit code は**決定的ゲートだけ**が決める。VLM の主観で CI を落とさない。

出力は `recommended_actions[]`（`node_id` / `priority` / `suggested_change`）という
機械可読な修正リストなので、そのままエージェントの編集ループに入る。修正したら
`--compare` で撮り直して、変化が狙ったノードに出たかを確認する — ここで閉じる。

---

## 7. 操作性ゲート

```sh
just ui-interactions ui_demo
just ui-interactions ui_demo "--no-build --profile inputs.json"
```

初期フォーカスがない状態から、実際の update/draw に入力列を渡す。宣言された
`focus_order` を眺めるだけでなく、キーボードとゲームパッドそれぞれで全ノードへの
到達・逆順・一周を確認する。ポインタでも各描画矩形の中心をクリックする。
各フレームの integrity gate が hit 矩形と描画矩形の一致を検査する。

フォーカス表示は同じtickまで進めた「操作あり／なし」のPNGを比較する。
対象矩形の外を `vlmkit diff png --ignore-region` で除外するため、別の場所の
アニメーションをフォーカス表示の変化と誤認しない。対象内の他の演出とは区別できない
ので、fixture の対象は決定的であること。表示順の基準は上から下、同じ行では左から右。

既定の入力はTab／Shift-Tabと標準ゲームパッドのD-pad下／上。違う操作体系は
`--profile` で完全な入力ステップを渡す。

```json
{
  "keyboard": {"next": {"keys": [9]}, "previous": {"keys": [9, 16]}},
  "gamepad": {
    "next": {"gamepads": [{"id": 0, "buttons": [13]}]},
    "previous": {"gamepads": [{"id": 0, "buttons": [12]}]}
  }
}
```

入力ステップは `keys`、`cursorX/Y`、`mouseButtons`、`gamepads` を受け取る。
各ステップは完全な入力状態で、省略したチャンネルは解放される。列が終わった後も
neutral input。押下の間には空のステップ `{}` を入れて解放する。
共通MoonBit APIの `render_headless_frame(input_at=...)` は任意の `InputSnapshot` を
返すcallbackを受け取るため、同じ再生をnativeのテストでも使える。

PNG・snapshot・機械可読な `report.json` は `output/ui-interactions/<example>/`。
未対応デバイス、未到達ノード、移動順の不一致、ピクセル変化なしは欠陥としてexit 1。
snapshot欠落・3Dコマンドの描画欠落・座標系不一致は検証不能としてexit 2にする。
CIではUIデモを実行する。これは合成入力の検証で、物理デバイスの接続検査ではない。

## 8. 状態遷移のflipbook

```sh
just ui-flipbook ui_demo focus
just ui-flipbook ui_demo hover
```

ゲーム側の `editor/verification.json` に、遷移名、入力列、観測tick数、停止期限を書く。
UIデモのfocusは次の定義。

```json
{"version": 1, "transitions": {
  "focus": {"frames": 5, "settleFrame": 3, "inputs": [{}, {"keys": [9]}]}
}}
```

1tick目を遷移前の観測にし、以降に操作を入れる。毎tickを同じ初期状態から再生して
キャプチャするため、乱数などもゲーム側で決定的にする。各フレームにintegrity gateを
適用し、隣接する全PNGをvlmkitで比較する。停止期限まで変化がなければ `no-motion`、
期限後の比較で差があれば `not-settled`。ゲーム時間の単位はtickであり、壁時計のmsではない。
停止確認は指定した最終tickまでで、それ以降の振る舞いは保証しない。

出力は `output/ui-flipbook/<example>/<transition>/` の連番PNG、snapshot、elements、
各比較のdiff JSON、全体の `report.json`。状態遷移中に飛び出すUIもフレーム番号付きで
報告する。欠陥はexit 1、検証不能はexit 2。現在のCLIは2D CPUキャプチャを使う。
3Dや実GPUのマトリクス統合は別途必要。native CPUマトリクスは9.1を参照。

## 9. 画像版integrityと状態×解像度マトリクス

```sh
just ui-vlmkit-check output/frames/ui_demo/ui_demo.snapshot.json output/frames/ui_demo/ui_demo.png
just ui-matrix ui_demo
just ui-matrix ui_demo "--update" # 意図した変更を画像で確認してからbaselineを更新
```

`ui-vlmkit-check` は文字実測・clip・zを含む要素データを生成し、vlmkitの画像版integrityと
kaguraの幾何・hit矩形ゲートを両方実行する。ゼロサイズは欠陥の証拠なので変換で消さない。
矩形・文字実測・clipは同じDPRでスケールする。画像の寸法とsnapshotの座標系が一致しない
場合は検証不能として終了する。元のvlmkitレポートの `skippedRules` も保存し、
実行されなかったコントラスト検査などを成功と扱わない。

マトリクスは同じ `editor/verification.json` の `states` を読む。

```json
{"version": 1, "states": {
  "idle": {"frames": 1, "expectedState": "demo", "expectedFocus": null},
  "focus": {"frames": 2, "inputs": [{}, {"keys": [9]}], "expectedFocus": "button_1"}
}}
```

`states` のキーは検証ケースのID。`initialState` が無ければ通常の初期状態から入力を再生する。
`expectedState` で実際のsnapshot状態名、`expectedFocus` で実際の選択対象を検証できる。
ゲーム固有のメニュー・ポーズ等も入力列で到達させられる。
`initialState` を指定すると、MoonBitのファクトリで初期状態を直接作ってから入力を再生する（9.2）。

既定のviewportは640×360、640×480、360×640、840×360。`viewports` 配列に
`{"name":"small","width":320,"height":240}` の形式で指定すれば置き換えられる。
HUD は `apply_viewport` で `capture_viewport` のサイズを受け取る。2D ゲームは
既定の 4 viewport を使う。ワールドカメラは `Camera2D::set_screen` で追従する。

CI の JS マトリクスは `just ui-matrix --all`（`scripts/ui-matrix-manifest.mjs`）。
standard セルのあと `just ui-matrix-gates` が各 example の `editor/theme.json` と
i18n ストレスを回す。i18n が gating なのは ui_demo だけ。scene の label は
矩形が文字幅ぴったりなので DE 膨張は必ず溢れる。ゲーム側は advisory。
各セルは独立したゲームインスタンスで再生する。UIデモは指定サイズで初期レイアウトを
計算するため、同じ640×480の画像を引き伸ばしたものではない。

各セルで画像版integrity、kaguraの幾何ゲート、単色フレーム拒否、baselineとの
`vlmkit diff png --threshold 0 --elements-json ...` を実行する。通常実行でbaselineを
書き換えない。更新時も全セルのgateが通ってからコピーし、失敗したマトリクスを
部分的に貼り直さない。UIデモの入力レシピ3種と名前付き初期状態1種×4解像度、計16枚をCIで比較する。

出力は `output/ui-matrix/<example>/<state>.<viewport>/` のPNG、snapshot、elements、
integrityレポート、diff JSONと全体の `report.json`。
baselineは `e2e/ui-matrix-snapshots/<example>/`。3Dコマンドを含む描画、snapshot欠落、
要求した画像サイズとUI座標の不一致は失敗し、次のセルの検査は続ける。

### 9.1 native CPU capture

```sh
just ui-capture ui_demo focus portrait
just ui-matrix ui_demo "--backend native"
node scripts/ui-capture-native.integration.mjs
```

`ui-capture` は `editor/verification.json` の状態とviewportを選び、native実行ファイルから
PNGとUI snapshotを取得する。出力は `output/ui-capture/<example>/<state>.<viewport>/`。
`ui-matrix --backend native` は同じセルに同じintegrityゲートをかけ、**JSと共通のbaseline**
に差分ゼロを要求する。native専用の画像への貼り直しは許可しない。
`just ui-matrix --all --backend native` は `supported_targets` に native がある
example だけ回す（hacknslash は js-only なので除外）。
レポートは `output/ui-matrix-native/<example>/` に出る。macOS CIは `--all` で回す。

3D は CPU ラスタライザが描かないので `just ui-matrix hacknslash_3d --backend gpu`。
native wgpu の readback。ピクセル baseline は貼らない（機械で揺れる）。integrity と
blank 拒否と snapshot state で見る。JS CI には入れない。playing は HUD を `ctx.dst`
に載せる。3D ジオメトリは PostFX 用ハンドルがキャプチャデバイスに無いのでまだ黒。
GPU エントリは `examples/games/hacknslash_3d/native/` で、ゲーム本体は
`app/` library。`native_runtime_hooks` は js+native の main パッケージから import できない。

各キャプチャは独立した子プロセスで実行する。一時ディレクトリ内の設定ファイルを
`KAGURA_CAPTURE_CONFIG` で渡すので、ゲームのディレクトリにある既存の設定を書き換えない。
設定ファイルの3出力パスは従来の形式を維持し、`request_path` にJSONの入力列と画面サイズを
記述する。環境変数が無い場合は従来の `kagura_native_capture_config.txt` も読める。
明示した設定の欠落・不正はエラー終了し、ウィンドウの起動にフォールバックしない。

他ゲームの接続は次の契約を使う。

- `@scene.run` / `@scene.run_game` を使っている example はラベル snapshot が自動で出る。追加の adapter は不要。
- `@ui` レイアウトや `@hud.HudContext` で描く画面は example 側で `UISnapshot` を組む（ui_demo / hacknslash_3d）。
- 状態を構築する前に `@engine.capture_viewport(default_width, default_height)` を呼び、そのサイズでUIをレイアウトする。JS/native共通。
- JSのsnapshot adapterは従来の `@ui.publish_ui_snapshot(snapshot)`。
- nativeのsnapshot adapterは `@engine.publish_capture_context(snapshot.to_json())`。同じ更新・描画時点で呼ぶ。UIモジュールからengineへの依存は追加しない。
- `@engine.run` / `run_game` がcapture設定を検出すると、ウィンドウ・音声・GPUを初期化する前に既存の `update` / `draw` をCPUで実行して終了する。
- テクスチャはruntime adapterが `set_headless_texture_provider` でCPUコピーを渡す。`web_runtime_hooks` のnative adapterは対応済み。独自adapterで未登録の画像を使うとエラーになる。

UIデモのPNGだけでなくクリック後のsnapshot全体、sprite_animのテクスチャ描画、日本語パス、
設定エラー時の終了をintegration scriptで確認する。描画中に更新されたテクスチャも最終draw後に取得する。
これは**nativeコンパイルしたゲームをCPUラスタライズする経路**であり、Metal/WebGPUの反射・シェーダー・3D描画の一致を保証する検査ではない。
3Dコマンドや未登録テクスチャは欠けた画像を成功扱いせず失敗する。

### 9.2 MoonBitの名前付き初期状態

`InitialStates[T]` はゲーム状態のファクトリを管理する。`T` はゲーム自身の型なので
`EngineGame`、`SceneGame`、独自ループで共通に使える。実行中の遷移は既存の
`SceneManager` / scene flowが担当し、このAPIは起動時に新しい状態を作る。

UIデモは次の形で宣言する。

```moonbit
let states = @engine.InitialStates::new(
  default=(width, height) => DemoState::new(width~, height~),
  named=[("last_button_focused", last_button_focused_fixture)],
) catch { @engine.InitialStateError(message) => abort(message) }
let game = states.create_for_capture(width=640, height=480)
@engine.run_game(game, width=game.width, height=game.height)
```

ファクトリは `(Int, Int) -> T`。指定されたviewportで新しい状態を構築し、フォーカス・
所持品・HP・シーン等をMoonBitコードで設定する。通常起動と `initialState` 未指定時には
`default` だけが呼ばれる。純粋なテストでは `states.create(Some("name"), width~, height~)` を
呼び、フレームを一度も進めずに状態を確認できる。`states.names()` は登録名を返す。

```json
{"version": 1, "states": {
  "initial_focus": {
    "initialState": "last_button_focused",
    "frames": 1,
    "expectedFocus": "button_6",
    "expectedState": "demo"
  }
}}
```

`initial_focus` は成果物名、`last_button_focused` はファクトリ名、`expectedState` は実際の
UI snapshotの状態名。それぞれを混同しない。初期化後には従来の `inputs` を再生できる。

```sh
just render ui_demo "--initial-state last_button_focused"
just ui-capture ui_demo initial_focus portrait
just ui-matrix ui_demo
just ui-matrix ui_demo "--backend native"
just check-capture-release js
just check-capture-release native
```

名前は英数字・`_`・`-` の1〜128文字、最大32個。重複・不正な登録名や未定義の名前は
エラーになる。ファクトリを選んだ事実をフレームの `initialState` に記録するため、
古いゲームが初期化要求を無視して通常画面を返した場合もゲートは失敗する。

検証専用のファクトリは `verification_debug.mbt` に置き、`moon.pkg` の
`targets: { "verification_debug.mbt": ["debug"], "verification_release.mbt": ["release"] }`
で分ける。release側は同じ `initial_states()` 関数からdefaultだけを登録する。
`check-capture-release` はdebug成果物にファクトリと登録名があること、release JS/生成Cに
両方が無いことを検査する。JSでは通常起動のPNG・snapshotがdebug/releaseで一致し、
releaseへの検証用状態の指定が拒否されることも確認する。

## 10. 残る作業

| やりたいこと | 状況 |
|---|---|
| 2D フレームの自動キャプチャ | **できる**（1.5）。native 経路 `just capture` は 3D と実 GPU 用 |
| 3D フレームの browser 抜きキャプチャ | **できる**（`just capture <example> output/capture "--backend gpu"`）。`@engine.run` が wgpu readback する |
| VRT の gating 化 | **2D は完了**（5.5、CI が `just frame-vrt` を回している）。3D と実 GPU 経路は [#8](https://github.com/mizchi/kagura/issues/8) のまま |
| 状態 × 解像度マトリクス | **2D入力レシピの全走査を実装**（9）。JS は `just ui-matrix --all`。native は js-only を除いて `--all --backend native`。MoonBit初期状態APIも実装済み（9.2、[#13](https://github.com/mizchi/kagura/issues/13)） |
| i18n ストレス | **実装済み**（`just ui-i18n-stress` / `just ui-matrix-gates --i18n`）。既定は DE 風の単語膨張。scene label は矩形=文字幅なのでゲームは advisory。`--profiles all` で全角・RTL・絵文字・桁溢れと missing glyph |
| 操作性ゲート（フォーカス到達性） | **実装済み**（7）。UIデモの実入力とピクセル変化をCIで検査。他ゲームにはfixtureの追加が必要 |
| 状態遷移のflipbook | **実装済み**（8）。UIデモのfocus/hoverをCIで検査 |
