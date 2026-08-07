# ゲーム UI 検証ランブック

canvas / WebGPU 上に描くゲーム UI を、DOM なしで決定的に検証するための手順。

背景と全体像は [`vlmkit-game-ui-verification.md`](./vlmkit-game-ui-verification.md)、
作業一覧は [#19](https://github.com/mizchi/kagura/issues/19) を参照。

---

## 1. 全体の流れ

```
engine (MoonBit)                    Node (browser 不要)
─────────────────                   ─────────────────────
@ui.UISnapshot
  └ publish_ui_snapshot ──> globalThis.__kaguraUISnapshot
                              │
                              ├─> scripts/ui-integrity-gate.mjs         → 決定的な欠陥リスト
                              └─> scripts/ui-snapshot-to-vlmkit-elements.mjs
                                     └─> vlmkit diff png --elements-json → pixel diff を UI ノードに帰属
```

UI snapshot は「DOM の代わり」。ノード矩形・クリップ矩形・**実測したテキスト幅**・hit 矩形・
フォーカス順を持つので、`vlmkit check integrity` が DOM でやっている判定を engine の値で行える。

---

## 2. snapshot を engine から出す

### JS ターゲット

`@ui.publish_ui_snapshot` を毎フレーム呼ぶと `globalThis.__kaguraUISnapshot` に
`{ json, parsed }` が入る（`__kaguraModelingContext` と同じ形）。

実装例: `examples/ui/ui_demo/src/snapshot.mbt` + `snapshot_js.mbt`

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

native は browser global が無い。フレーム PNG と snapshot JSON をファイルに書く経路
（`kagura_native_capture_config.txt` の `screenshot_path` / `context_path`）を
`tools/modeling3d/` から engine 共通機能へ引き上げる作業は
[#9](https://github.com/mizchi/kagura/issues/9) で別途。現状 `snapshot_native.mbt` は no-op。

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

## 6. 現状できていないこと

| やりたいこと | 状況 |
|---|---|
| フレーム PNG の自動キャプチャ | web の canvas capture と Linux Dawn readback が壊れている。native 経路の一般化が [#9](https://github.com/mizchi/kagura/issues/9) |
| VRT の gating 化 | キャプチャが直るまで保留。[#8](https://github.com/mizchi/kagura/issues/8) |
| 状態 × 解像度マトリクス | スナップショットモードの一般化が [#13](https://github.com/mizchi/kagura/issues/13) |
| i18n ストレス | [#14](https://github.com/mizchi/kagura/issues/14) |
| 操作性ゲート（フォーカス到達性） | snapshot に `focus_order` は入っているので実装は軽い。[#15](https://github.com/mizchi/kagura/issues/15) |
| VLM による主観品質レビュー | [#16](https://github.com/mizchi/kagura/issues/16)。決定的ゲートが通った**後**に回す |
