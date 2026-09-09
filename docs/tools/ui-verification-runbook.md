# ゲーム UI 検証ランブック

canvas / WebGPU 上に描くゲーム UI を、DOM なしで決定的に検証するための手順。

背景と全体像は [`vlmkit-game-ui-verification.md`](./vlmkit-game-ui-verification.md)、
作業一覧は [#19](https://github.com/mizchi/kagura/issues/19) を参照。

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
| `lib/web/kagura-headless-frame.js` | Node 側ホスト。viewport スタブと module 再実行 |
| `scripts/render-frame.mjs` | build → render → PNG / snapshot / elements を書く |

**限界（黙って嘘をつかないための約束）:**

- CPU ラスタライザが描くのは **2D コマンドだけ**。3D（`vertex_stride_hint` 8 / 16）は
  深度もプロジェクションも持たないので描かず、`skipped_commands` に数える。
  `just render` はその数を warning で出す。3D の目視は `just capture`（native）か実ブラウザ側
- テクスチャは `register_texture` で登録されたものだけ。未登録の id は 1x1 白として
  サンプルする（WebGPU バックエンドが未バインドスロットに入れているものと同じ）。
  つまり**アトラス経由のスプライトは uniform 色のベタ塗りになる**。矩形と dot text で
  描かれた UI（`examples/demos-2d/ui_demo` など）はピクセル一致で出る
- `document.querySelector("canvas")` などに答える viewport スタブは
  「engine が解決した実サイズ」を返す。CSS サイズでカーソルをスケールする example が
  ずれないための約束で、スタブ側が勝手なサイズを名乗ってはいけない

---

## 2. snapshot を engine から出す

### JS ターゲット

`@ui.publish_ui_snapshot` を毎フレーム呼ぶと `globalThis.__kaguraUISnapshot` に
`{ json, parsed }` が入る（`__kaguraModelingContext` と同じ形）。

実装例: `examples/demos-2d/ui_demo/src/snapshot.mbt` + `snapshot_js.mbt`

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
just capture <example> [out_dir]
# → out_dir/<name>.png / <name>.context.json / <name>.summary.txt
```

`just capture` は `scripts/stage-capture-config.mjs` で
`kagura_native_capture_config.txt` を example 直下に置き、native backend で 1 回走らせる。
example 側は `@capture_native.read_capture_config()` で読み、
`@capture.encode_rgba8_png` で PNG にして `@capture_native.write_capture_artifacts` で書く。

| API | 用途 |
|---|---|
| `@capture.parse_capture_config(text)` | 設定のパース（全 target、pure） |
| `@capture.encode_rgba8_png(w, h, pixels)` | readback バッファ → PNG |
| `@capture.binarize_rgba8(pixels)` | シルエット確認用の白黒化 |
| `@capture_native.read_capture_config()` | 設定ファイルの読み込み（native） |
| `@capture_native.write_capture_artifacts(...)` | 3 つの artifact 書き出し（native） |

**まだ 2D UI example に native capture の配線は入っていません。** 現在の利用者は
3D authoring example と `examples/smoke/native_vrt`（baseline を PNG 化済み）。
`snapshot_native.mbt` は現状 no-op。

2D の UI については native を待つ必要はもう無く、**1.5 の CPU レンダリングのほうが速くて
移植性も高い**（GPU も wgpu-native も要らない）。native capture が要るのは、CPU
ラスタライザが描かない 3D と、実 GPU パイプラインそのものを見たいときだけ。

---

## 3. 決定的ゲートを回す

```sh
just ui-check output/ui-snapshot.json
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

その他: `--tolerance <px>`（既定 0.5、サブピクセル誤差の遊び）、`--json`、`--advisory`。

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

## 5. 素材の入庫ゲート

スプライト / アイコンを UI スロットに入れる**前**に通す。browser 不要の純 PNG 演算。

```sh
just ui-asset-check assets/icons/potion.png "--slot 32x32 --expect-transparent --against-bg '#141822'"
```

スロット aspect 適合 / 透過 vs マット背景 / 占有率 / 図地コントラスト / パレット調和を判定。

---

## 6. VLM に主観品質を聞く

決定的ゲートで測れるものは**モデルに探させない**。overflow も hit box のズレも
`ui-integrity-gate` が証明できるので、それを VLM にやらせると再現しないレビューになる。
モデルに残すのは「測って決まらないもの」— 可読性・コントラスト・視覚的階層・バランス。

```sh
just vlm-ui-review ui_demo "--frames 3 --dry-run"          # リクエストを組むだけ
OPENROUTER_API_KEY=... just vlm-ui-review ui_demo "--frames 3"
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

## 7. 現状できていないこと

| やりたいこと | 状況 |
|---|---|
| 2D フレームの自動キャプチャ | **できる**（1.5）。native 経路 `just capture` は 3D と実 GPU 用 |
| 3D フレームの browser 抜きキャプチャ | CPU ラスタライザは 2D のみ。native か実ブラウザが要る |
| VRT の gating 化 | CPU レンダリングは決定的なので土台はできた。置き換えは [#8](https://github.com/mizchi/kagura/issues/8) |
| 状態 × 解像度マトリクス | `--state` / `--cursor` / `--keys` / `--width` で 1 状態ずつは撮れる。全走査の自動化が [#13](https://github.com/mizchi/kagura/issues/13) |
| i18n ストレス | [#14](https://github.com/mizchi/kagura/issues/14) |
| 操作性ゲート（フォーカス到達性） | snapshot に `focus_order` は入っているので実装は軽い。[#15](https://github.com/mizchi/kagura/issues/15) |
