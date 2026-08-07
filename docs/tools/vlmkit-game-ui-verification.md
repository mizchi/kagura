# vlmkit によるゲーム UI の目視確認・検証・自動化：現状調査と提案

`@mizchi/vlmkit@0.9.1` を kagura のゲーム UI 開発（HTML/CSS ではなく canvas / WebGPU 上に描く UI）に
適用できるかを実測ベースで調査した結果と、不足部分の提案。

調査日: 2026-08-07 / 対象: kagura `f6b899b`, vlmkit `0.9.1`

起票済み issue: [#19 (tracking)](https://github.com/mizchi/kagura/issues/19)
— 個別: #8 #9 #10 #11 #12 #13 #14 #15 #16 #17 #18
/ vlmkit 側: mizchi/vlmkit#116 #117 #118

---

## 1. 結論

**不足しているのは vlmkit の機能ではなく、kagura 側が「UI の意味情報」と「まともなフレーム画像」を
外部に出していないこと。**

- vlmkit の gate は 2 系統に分かれる。
  - **pixel 系**（browser 不要、PNG だけで動く）→ kagura で**今すぐ使える**
  - **DOM 系**（`getBoundingClientRect` / selector / a11y tree 前提）→ canvas UI では**常に空振り**
- 価値の大きい gate（`check integrity` の text collision / clipping / overflow、`check copy`、
  `check layout --contract`、`check interactions`、`stress i18n`、`verify markup`、`heal markup`）は
  すべて DOM 系。canvas に描いた UI では `<canvas>` 1 要素しか見えないので何も検出しない。
- ただし vlmkit には **DOM 非依存の抜け道が既にある**（`diff png --elements-json`、後述 3.）。
  kagura が UI ツリーの矩形を JSON で出せば、pixel diff を UI ノードに帰属させられる。実際に動くことを検証した。
- さらに前提として、**kagura の VRT は現在 CI で 1 バイトも検証していない**（実測、後述 2.）。
  vlmkit を載せる前に、まず「移植可能なフレームキャプチャ」を直す必要がある。

---

## 2. kagura 側の現状（実測）

### 2.1 CI の VRT は非 gating

`.github/workflows/ci.yml:151`

```yaml
- name: VRT E2E (visual regression)
  run: pnpm exec playwright test e2e/vrt.spec.ts --update-snapshots
```

同ファイルのコメントにある通り、Linux CI では

- canvas screenshot が透明（生成した `-linux` baseline は完全に空）
- `copyTextureToBuffer` + `mapAsync` が Dawn Linux backend で完了せず readback summary も来ない

ため、screenshot / readback のどちらでも gate できず `--update-snapshots` で常時グリーンにしている。
**つまり CI におけるゲーム UI の視覚検証は現状ゼロ。**

### 2.2 コミット済み baseline 19 枚のうち 18 枚が真っ黒

`e2e/vrt.spec.ts-snapshots/*.png` を全走査した実測値（`maxCh` = 全ピクセル全チャンネルの最大値）:

| baseline | size | maxCh | nonDark | 色数 |
|---|---|---|---|---|
| `obj-viewer-darwin.png` | 320x240 | 178 | 10.42% | 7 |
| 上記以外の 18 枚 | 320x240 | **0** | **0.00%** | **1** |

`ui-demo-darwin.png` と `survivor-darwin.png` は `vlmkit diff png` で **diff 0.00% / 0 px**、
つまりピクセル単位で同一（どちらも純黒）。macOS Metal の canvas 透明化（issue #4）の結果で、
**リポジトリに入っている「見た目の正解」は実質存在しない。**

### 2.3 実際の gate は readback ヒューリスティックのみ

`e2e/vrt.spec.ts:151-166` が本命の判定:

```ts
expect(readback.nonTransparentPixelRatio).toBeGreaterThan(0.99);
expect(readback.maxChannel).toBeGreaterThanOrEqual(64);
expect(readback.nonDarkPixelRatio).toBeGreaterThanOrEqual(expectedNonDark * floorRatio);
```

これは「真っ黒 / 描画消滅 / 極端な崩れ」しか検出しない。UI 開発で実際に起きる

- HUD が画面外にはみ出す / セーフエリアを侵す
- 長い文字列・大きな数値でテキストがパネルからあふれる、クリップされる
- ラベルとアイコンが重なる
- 色・コントラストが崩れて読めない
- ボタンの hit box が見た目とずれる

は **すべて通過する。**

### 2.4 スナップショットモードは 1 example のみ

`?snapshot=&frames=&tick=` の実装は `examples/games-3d/hacknslash_3d/src/snapshot.mbt` だけ
（`examples/*/*/src/snapshot.mbt` の全検索結果が 1 件）。`e2e/vrt.spec.ts` の `SNAPSHOT_TESTS` も
`hacknslash_3d` の 1 行のみ。UI が実際に問題を起こす状態（メニュー、ポーズ、インベントリ、
レベルアップ、ゲームオーバー、ダイアログ）はどの example でもキャプチャされていない。

### 2.5 `modules/ui` は必要な意味情報を持っているが公開していない

| 持っているもの | 場所 |
|---|---|
| ノードごとの矩形 `LayoutRect{x,y,width,height}` + `UINodeId` | `modules/ui/contracts.mbt:31,44` |
| 座標→ノードの hit test（`hit_test` / `hit_test_all`） | `modules/ui/contracts.mbt:109,125` |
| フォーカス順（`UIFocusManager::focus_next/prev`, `set_focusable`） | `modules/ui/contracts.mbt:151-249` |
| テキスト実測（`TextRenderer::measure`） | `modules/text/contracts.mbt:166` |
| クリップ矩形とその交差（`ScissorRect::intersect` / `ScissorStack`） | `modules/widget2d/scissor.mbt:27,54` |
| PNG エンコード（engine 内） | `@atlas.encode_png_image_spec` |

`modules/ui` 由来の情報を JS 側へ publish している箇所は**ゼロ**
（`examples/ui/ui_demo/src/*.mbt` の `extern "js"` は canvas サイズ取得の 2 本だけ）。
つまり「検証に必要なデータは engine 内に全部あるが、外に出ていない」状態。

### 2.6 3D modeling には完成した VLM ループがある（UI 版が無いだけ）

`tools/modeling3d/scripts/` に screenshot + context JSON + prompt → 構造化 review →
patch → apply → PR コメントまでの一式（`model-authoring-vlm-*.mjs`、`justfile:125-181` の
`vlm-*` ターゲット群、`docs/tools/vlm-modeling-runbook.md`）が既にある。
native 側は `kagura_native_capture_config.txt` を stage して
`screenshot_path` / `context_path` / `summary_path` に **PNG + JSON + サマリを直接書き出す**
（`tools/modeling3d/examples/frog_authoring/src/main_native.mbt:300-308`）。

**この native capture 経路は Dawn / headless canvas の問題を完全に回避している。**
UI にそのまま流用できる最短ルートがここにある。

### 2.7 環境面の前提

| 項目 | vlmkit の要求 | kagura の現状 | 対応 |
|---|---|---|---|
| Node | `>=24` | CI は `node-version: "24"` | OK |
| playwright peer | `>=1.61 <2` | `pnpm-lock.yaml` は `1.60.0` 固定 | bump 必要 |
| Chromium | `playwright install chromium` | 既に CI で導入済み | OK |
| API key | `[key]` 付き機能のみ | modeling で `OPENROUTER_API_KEY` 運用済み | 流用可 |

---

## 3. vlmkit 機能マップ：canvas UI で使える / 使えない

### 3.1 今すぐ使える（browser 不要 / PNG だけで動く）

`e2e/vrt.spec.ts-snapshots/*.png` に対して実行して動作確認済み。

| コマンド | 用途 | 実測 |
|---|---|---|
| `diff png <base> <cur>` | フレーム間 pixel diff + 領域抽出 + heatmap + `--crop-regions` | 動作。`--elements-json` で UI ノード帰属も可（3.3） |
| `check palette <png> [<png>]` | 支配色抽出 / 2 枚のパレット差分 | 動作（黒 baseline に対して `#040404 100%` を返した） |
| `check asset <png>` | スロット aspect、透過 vs マット、占有率、背景コントラスト、パレット調和 | 動作。**スプライト / アイコン / UI 素材の事前ゲートとして即使える** |
| `check equivalence <png> --target --region` | 指定領域の平均チャンネル差分 + VLM の SAME/DIFFERENT を差分値で反証 | HUD の特定領域の判定に使える |
| `scan component <png>` | スクリーンショットからコンポーネント検出 + 個別 PNG 切り出し | HUD 要素の自動切り出しに使える |
| `scan mock <png>` | @2x/@3x のデザイン入力を @1x に正規化 | デザイン指定との突き合わせ前処理 |
| `batch` / `gates run` | 上記を並列 + 1 つの設定にまとめて CI ゲート化、suppression 監査付き | example 全走査に使える |

### 3.2 canvas UI では空振りする（DOM 前提）

| コマンド | canvas での挙動 |
|---|---|
| `check integrity` | text collision / clipping / protrusion / collapsed container / overflow をすべて DOM ノードから判定。`<canvas>` 1 個しか無いので何も出ない。**一番欲しいのにここ** |
| `check copy --manifest` | レンダリング済みテキストノードを DOM から取る。canvas の文字は 1 文字も見えない |
| `check layout --contract` | 幅・行あたり個数・積み順を DOM math で検証 |
| `check breakpoints --sweep` | CSS breakpoint 前提 |
| `check a11y contrast/touch/focus` | a11y tree 前提 |
| `check tokens` / `theme` / `design` / `drift` | CSS / selector 前提 |
| `check motion` | CSS animation/transition 前提（`check animation` はフレームサンプルなので一部有効） |
| `stress i18n` / `stress media` | DOM テキスト膨張 / forced-colors 等 |
| `check interactions` | keyboard probe → ARIA 遷移 |
| `verify markup` / `build component` / `build page` / `heal selector` / `heal markup` | HTML/CSS 生成・修復が出力なので対象外 |
| `contract introspect/scaffold` | HTML/CSS IR |
| `snapshot` / `baseline` / `diff-pr` / `watch` | URL は開けるので**動く**が、掴む絵が 2.1 の理由で空。**キャプチャを直せば有効** |

### 3.3 検証済みの抜け道：`diff png --elements-json`

`--elements-json` が要求するスキーマは完全に DOM 非依存だった
（`dist/region-selector-match-CYFk1Ckj.mjs` の `parseRegionElementRect`）:

```json
{ "elements": [
  { "path": "hud[0]>bar[0]", "tag": "bar", "id": "hp_bar",
    "classes": "hp-bar", "top": 16, "left": 16, "width": 200, "height": 20 }
]}
```

必須は `path` `tag` `top` `left` `width` `height`（`id` / `classes` は任意、
selector 名は `.classes` → `#id` → `tag` の順で決まる）。配列直置きも `{elements:[...]}` も可。

これは `modules/ui` の `LayoutResult{node_id, rect}` とほぼ 1:1 で写せる。
合成 HUD（640x360、HP バーだけ 180px→90px に変えた 2 枚）で実験した結果:

```
$ vlmkit diff png frame-base.png frame-cur.png --elements-json ui-elements.json
  diff:     0.78% (1800 / 230400 px)
  regions:  1
    (96,0) 128x64 [content] #dc3c3c -> #3c3c3c
  selectors:
    (96,0) 128x64 -> .hud-root (medium, coverage 1)
```

**帰属機構は動く。** ただし 2 点の実用上の限界を確認した:

1. **diff 領域が粗いブロックに丸められる。** 実際の変化は `(106,16) 90x20` だが、報告は
   `(96,0) 128x64`。320x240 や 640x360 のゲーム画面では HUD 要素より領域のほうが大きくなる。
2. **スコアが「領域を含む最大の box」を優先しがち。** スコア計算は
   `regionCoverage*0.7 + elementCoverage*0.3`（巨大要素には `*0.55` のペナルティあり）。
   今回 `hud-root` が 0.39、本当の原因である `hp_bar` が 0.385 で、**根本原因が負けた。**

→ ネストした HUD では帰属が当たらない。vlmkit 側への要望として 5. に挙げる。

---

## 4. 提案：不足している機能

優先度は「これが無いと後段が全部無意味」順。

### P0-1. UI introspection hook（`__kaguraUISnapshot`）

`modules/ui` の情報を 1 本の JSON として JS / native の両方に publish する。
2.6 の `js_publish_model_context` / `context_path` と同じ形にすれば、既存の VLM ループに乗る。

```jsonc
{
  "screen": { "width": 640, "height": 480, "dpr": 2, "safe_area": {"top":0,"right":0,"bottom":0,"left":0} },
  "frame": 120,
  "state": "playing",            // スナップショットモードの状態名
  "nodes": [
    {
      "path": "root[0]>hud[0]>bar[0]",
      "id": "hp_bar",            // 開発者が付けた安定 ID
      "role": "gauge",           // Panel/Button/Label/Gauge/Icon/Dialog...
      "classes": "hud gauge",    // 任意タグ（vlmkit の selector 名になる）
      "left": 16, "top": 16, "width": 200, "height": 20,
      "z": 3,
      "visible": true,
      "clip": { "left":0, "top":0, "width":640, "height":480 },  // ScissorStack から
      "text": "HP 90/180",
      "text_measured": { "width": 214, "height": 18 },           // TextRenderer::measure
      "focusable": true, "focus_index": 2, "focused": false,
      "hit_rect": { "left":16, "top":16, "width":200, "height":20 }
    }
  ],
  "focus_order": ["start_button", "options_button", "quit_button"]
}
```

- JS: `extern "js"` で `globalThis.__kaguraUISnapshot` に置く（`__kaguraModelingContext` と同型）
- native: `kagura_native_capture_config.txt` の `context_path` にそのまま書く
- 変換 script: `scripts/ui-snapshot-to-vlmkit-elements.mjs` で 3.3 のスキーマへ写す
  （`path`/`tag`=`role`/`id`/`classes`/`top`/`left`/`width`/`height`）

これ 1 つで `diff png --elements-json` が使えるようになり、以下の P1 系ゲートの入力にもなる。

### P0-2. 移植可能なフレームキャプチャ（native PNG capture の一般化）

web の canvas capture と Linux Dawn readback は両方壊れている（2.1）。
一方 native は PNG を直接書けている（2.6）。**ゲーム UI のキャプチャを native 経路に寄せる。**

- `kagura_native_capture_config.txt`（`screenshot_path` / `context_path` / `summary_path` / `binarize`）
  の仕組みを `tools/modeling3d/` から engine 側の共通機能へ引き上げる
- `examples/ui/*`, `examples/games-2d/*` に `main_native.mbt` のキャプチャ経路を追加
- `just ui-capture <example> [state] [viewport]` → PNG + UI snapshot JSON を出す
- `examples/smoke/native_vrt` は BMP 保存（`main_native.mbt:26,37`）なので PNG に揃える
  （`@atlas.encode_png_image_spec` が既にある）。vlmkit の pixel gate は PNG 前提
- 真っ黒な 18 枚の baseline は削除する（誤った安心を与えている）

これで 3.1 の pixel 系ゲート**全部**が実データで回り始める。

### P0-3. VRT を再び gating にする

P0-2 のキャプチャを入力に、`--update-snapshots` を廃止して

```sh
vlmkit baseline pin      # 初回 / 意図した更新
vlmkit baseline verify   # CI（route ごとに閾値、breach で非ゼロ終了）
vlmkit baseline approve --region "..." --reason "..." --expires 2026-12-31
```

に置き換える。`baseline approve` の region 単位承認 + expiry + owner + `gates suppressions` は、
パーティクル等の非決定的領域を「無期限に無視」せず**期限付きで**逃がせるので、
現状の `vrt-readback-baselines.json` の floor 比運用より監査可能。

### P1-1. ゲーム UI 版 `check integrity`（最重要の欠落）

vlmkit の `check integrity` が DOM でやっていることを、**engine 内の primitives で**やる。
必要な部品は 2.5 の通り全部そろっている。

| 検出項目 | 実装 |
|---|---|
| テキストのはみ出し / クリップ | `TextRenderer::measure` の結果 vs ノード矩形 vs `ScissorRect::intersect` |
| 画面外・セーフエリア侵犯 | ノード矩形 vs screen / safe_area |
| 要素の重なり（意図しない被り） | 同 z 帯の矩形交差、`hit_test_all` |
| 0 サイズ / 潰れたコンテナ | `width<=0 || height<=0`、子の合計が親を超える |
| hit box と描画矩形の不一致 | `hit_test` の結果 vs `hit_rect` |
| コントラスト不足 | フレーム PNG からノード矩形を切って前景/背景輝度比（`check asset --against-bg` の考え方） |

出力は vlmkit と同じ「機械可読な修正リスト」形式（`[text-overflow] hp_label: measured 214px > rect 200px`）
にしておくと、そのままエージェントのループに入る。`just ui-check <example>` で提供。

### P1-2. スナップショットモードの一般化（状態マトリクス）

`?snapshot=&frames=&tick=` を hacknslash_3d 固有実装（2.4）から engine 共通機能へ。

- 状態名を example が宣言（`title` / `playing` / `pause` / `inventory` / `levelup` / `dialog` / `gameover`）
- `just ui-matrix <example>` で 状態 × viewport（16:9 / 4:3 / 縦持ち / ウルトラワイド）を全キャプチャ
- 各セルで P1-1 のゲート + `diff png --elements-json` を回す
- これが `check breakpoints --sweep` のゲーム版に相当する（CSS breakpoint ではなく解像度スイープ）

### P1-3. テキスト / i18n ストレス

`stress i18n` のゲーム版。ゲーム UI で最も多い壊れ方がここ。

- 文字列テーブルを膨張（DE 風 +35%、日本語→全角、アラビア語 RTL、絵文字、9,999,999 のような桁溢れ）
- 各状態で P1-1 の text-overflow / clip / collision を回す
- フォントアトラスに無いグリフ（tofu）の検出も engine 側で可能

### P2-1. 操作性ゲート（`check interactions` のゲーム版）

`UIFocusManager` と `hit_test` が既にあるので実装は軽い。

- 全 focusable が `focus_next` の反復で到達可能（フォーカストラップ / 孤立の検出）
- フォーカス順が視覚順（左上→右下）と矛盾しない
- 各ボタンの `hit_test` が描画矩形と一致（見た目とクリック範囲のズレ）
- キーボード / ゲームパッドのみで全ボタンに到達可能
- フォーカスリングが実際にピクセル上で変化する（フレーム diff で確認）

### P2-2. UI 版 VLM review ループ

2.6 の modeling ループをほぼそのまま再利用する。差分は入力バンドルと評価軸だけ。

- bundle = P0-1 の UI snapshot JSON + P0-2 のフレーム PNG（+ 状態マトリクスの複数枚）
- `visual_findings.area` の enum を UI 用に定義:
  `hud_readability` / `layout_balance` / `text_legibility` / `contrast` / `visual_hierarchy` /
  `safe_area` / `state_consistency` / `iconography` / `theme_coherence`
- 既存の構造化 review スキーマ（`target_file` / `overall_summary` / `confidence` /
  `recommended_actions` / `manual_followups` / `visual_findings`）と daemon / dry-run /
  `--execute` の運用をそのまま流用
- `just vlm-ui-review <example>` / `just vlm-ui-daemon-start <example>`
- **重要**: VLM は「決定的ゲートが通った後の主観品質」だけを見る。P1-1 で機械的に取れる欠陥を
  VLM に探させると不安定になる。vlmkit の設計思想（deterministic gate が先、VLM は反証付き）に従う。

### P2-3. アニメーション / トランジションの評価

`check animation` はフレームサンプル方式なので考え方が流用できる。

- 状態遷移（メニュー→プレイ、ダメージフラッシュ、レベルアップ演出）のフレーム列を PNG で連続キャプチャ
- 「実際にピクセルが動いているか」「N ms で settle するか」「途中フレームで要素が画面外に飛ばないか」
- `just ui-flipbook <example> <transition>` で連番 PNG + `diff png` の連鎖

### P2-4. テーマ / パレットゲート

`check palette` の 2 枚モードがそのまま使える。UI テーマのトークン表と
実フレームの支配色を突き合わせ、「トークンに無い色が混ざった」「使われていないトークンがある」を検出。
`check asset` は生成スプライト・アイコンの入庫ゲートとして即導入できる（3.1）。

---

## 5. vlmkit 側への機能要望

kagura に限らず canvas / native / Flutter などの非 DOM UI で共通に効くもの。

起票: mizchi/vlmkit#116（下記 2）/ #117（下記 1）/ #118（下記 3・5・6・7 をまとめた adoption feedback）

1. **`--elements-json` の帰属精度**（3.3 で実測した問題）
   - diff 領域のブロック粒度を指定できる（`--region-grid 16` 等）。ゲーム画面は 320x240〜640x360 が普通で、
     64px ブロックでは HUD 要素より領域が大きい
   - 同点近辺では**より小さい box を優先**するオプション（`--elements-prefer-smallest`）。
     今回 `hud-root` 0.39 vs `hp_bar` 0.385 で根本原因が負けた
   - 帰属候補を上位 N 件返す（`--elements-top 3`）。1 位だけだと外したときに手掛かりが消える

2. **`check integrity` の image-only モード（最も要望が強い）**
   `PNG + elements-json` だけで text collision / clipping / protrusion / overflow / collapsed /
   near-misalignment を判定するモード。テキストは bbox と実測サイズを elements-json 側で渡す。
   これがあると **canvas UI / native アプリ / ゲームエンジンが一切の追加実装なしに vlmkit の主力ゲートに乗る。**

3. **`check copy --target` の image-only 経路**
   テキストブロックの bbox を DOM ではなく elements-json から取れるようにする。
   canvas に描いた文字列のコピー検証（誤字・未翻訳・プレースホルダ残り）が可能になる。

4. **非 DOM ソースの一級市民化**
   `--source-adapter <cmd>` のような口で「フレーム PNG + 要素ツリー JSON を返す外部プロセス」を
   ソースとして扱えるようにする。DOM 実装はそのアダプタの 1 つになる。

5. **非決定的領域のマスク**
   パーティクル・ノイズ・時刻表示などを region mask で除外（`--ignore-region "x,y,WxH"`）。
   `baseline approve --region` は承認扱いだが、最初から「見ない」指定も欲しい。

6. **PNG 直投げの baseline 入口**
   `baseline pin --from-png <png>` / `--from-dir`。URL を開けない環境（native キャプチャ、
   headless で canvas が壊れる環境）でも `baseline verify` / `diff-pr` のワークフローに乗れる。

7. **`scan component` の小画面チューニング**
   320x240 のドット絵 HUD だと `--min-area` のデフォルトでは検出しづらい。ゲーム UI 向けプリセット。

---

## 6. 実施順序

| 段 | issue | 内容 | 得られるもの |
|---|---|---|---|
| 1 | #11 | playwright を `>=1.61` に bump、`@mizchi/vlmkit` を devDependency 追加、`.mcp.json` に vlmkit MCP を登録 | エージェントから gate を直接叩ける |
| 2 | #9 | **P0-2** native PNG capture の一般化 + `just ui-capture` | 実データのフレームが手に入る |
| 3 | #10 | **P0-1** `__kaguraUISnapshot` + `scripts/ui-snapshot-to-vlmkit-elements.mjs` | `diff png --elements-json` が UI ノードで語れる |
| 4 | #8 | **P0-3** `vlmkit baseline` ベースの gating VRT に置換（`--update-snapshots` 撤去、真っ黒 baseline の削除） | 視覚リグレッションが初めて CI で止まる |
| 5 | #12 | **P1-1** `just ui-check`（text overflow / clip / offscreen / overlap / hit box） | UI の壊れ方の大半を決定的に検出 |
| 6 | #13 #14 | **P1-2** 状態マトリクス + **P1-3** i18n ストレス | 状態・解像度・言語の網羅 |
| 7 | #15 #16 #17 #18 | **P2-1** 操作性ゲート、**P2-2** UI 版 VLM review、**P2-3/4** アニメ・テーマ | 主観品質と演出まで |

段 1〜4 までで「ゲーム UI の目視確認・検証・自動化」の土台が成立する。
段 5 以降は既存の primitives（`TextRenderer::measure` / `ScissorStack` / `UIFocusManager` / `hit_test`）を
束ねるだけなので、engine への新規実装はほとんど不要。

---

## 7. 再現コマンド

```sh
# vlmkit の全コマンド surface
npx @mizchi/vlmkit --help
npx @mizchi/vlmkit check --help

# 今すぐ使える pixel 系ゲート（PNG だけ、browser 不要）
npx @mizchi/vlmkit check palette e2e/vrt.spec.ts-snapshots/ui-demo-darwin.png
npx @mizchi/vlmkit check asset  e2e/vrt.spec.ts-snapshots/ui-demo-darwin.png --advisory
npx @mizchi/vlmkit diff png <base>.png <cur>.png --elements-json ui-elements.json --crop-regions out/

# baseline が黒であることの確認（maxCh=0 なら全ピクセル純黒）
node -e '
const {PNG}=require("pngjs"),fs=require("fs"),d="e2e/vrt.spec.ts-snapshots";
for(const f of fs.readdirSync(d).filter(f=>f.endsWith(".png"))){
  const p=PNG.sync.read(fs.readFileSync(d+"/"+f));let m=0;
  for(let i=0;i<p.data.length;i+=4)m=Math.max(m,p.data[i],p.data[i+1],p.data[i+2]);
  console.log(f,p.width+"x"+p.height,"maxCh="+m);
}'
```
