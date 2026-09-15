# Mesh Modeling

Studio の **Modeling** ボタンで開く、ローポリモデルの編集環境。
[chibivue-land/art の kawaiko](https://github.com/chibivue-land/art/blob/main/kawaiko.png) を参考に、
緑の頭・眉・黄色いくちばし・羽毛・水かき・V 字のバッグを 28 個の独立したメッシュとして制作しています。
原画は編集画面から参照し、モデルは MoonBit の [kawaiko.mbt](core/kawaiko.mbt) が正本です。

```sh
just studio-dev
# http://127.0.0.1:5190/ → Modeling
```

初期画面を共有する場合は `?mode=modeling&model=kawaiko` を付けます。

公開版: [kawaiko を開く](https://mizchi.github.io/kagura/studio/?mode=modeling&model=kawaiko)

```text
http://127.0.0.1:5190/?mode=modeling&model=kawaiko
```

ページの起動時に Modeling を開き、保存済みデータよりも kawaiko の初期モデルを優先します。
URL は初期モデルへのリンクで、編集中の形状は含みません。既存の下書きは明示的に Save するまで変更しません。
`?mode=modeling` だけなら保存済みの下書きを復元し、パラメーターなしなら通常の Studio を開きます。
公開先でも、Studio の URL に同じクエリーを付けられます。現在の組込みモデル名は `kawaiko` です。
旧綴りの `model=kawaiiko` も互換用の別名として受け付け、同じ `kawaiko` モデルを開きます。

既存ゲームのシーン・保存先・Undo 履歴から独立しています。モデリングを閉じると元のペーンを復元します。
プロジェクトやシーンの切替、Play 開始時にも閉じ、編集中のモデルはメモリ内に保持します。

## 操作

[Blender の基本変形](https://docs.blender.org/manual/en/4.2/modeling/meshes/editing/mesh/transform/basic.html) を参考にしています。
ショートカットは `KeyboardEvent.code` に従い、Dvorak でも物理キー位置が変わりません。
Kagura と同じ **Y up / +Z forward / metres** です。

| 操作 | 動作 |
| --- | --- |
| 左クリック / アウトライナー | オブジェクトを選択 |
| 中ドラッグ | 周回。Shift を押すとパン。右ドラッグでもパン |
| ホイール | ズーム |
| G / R / S | 移動 / 回転 / 拡縮を開始。マウス移動でプレビュー |
| 変形中に X / Y / Z | ワールド軸で制限。もう一度で解除 |
| 数値 → Enter / 左クリック | 変形を確定。回転の数値は度、API はラジアン |
| Esc / 右クリック / ウィンドウから離れる | 変形開始前へ完全に復元 |
| Tab | Object / Edit の切替 |
| 1 / 3 | Edit の頂点 / 面選択。オブジェクトは一度に 1 個 |
| 頂点を Shift + クリック | 選択を追加・解除。A で全頂点を選択 |
| E | 選択した 1 面を法線方向に押し出す。軸制限・数値入力も可能 |
| Shift D / X | オブジェクトを複製 / 選択オブジェクトまたは面を削除 |
| F / Num . | 選択対象をフレーム |
| Num 1 / 3 / 7 / 5 | 正面 / 右 / 上 / 透視と平行投影の切替 |
| Ctrl/Cmd Z / Shift Ctrl/Cmd Z | モデルの Undo / Redo |
| Ctrl/Cmd S | ブラウザの IndexedDB に保存 |

移動の軸未指定で数値を入力した場合は X、回転は Y を使います。拡縮は未指定なら全軸。
Inspector では名前・色を編集でき、Cube / Sphere の追加、X 反転、ワイヤーフレーム表示にも対応します。
押し出しは単一ポリゴンが対象で、複数面の一括押し出し・辺編集・スカルプト・リギングはこのツールの対象外です。

## 保存・受け渡し

- **Save model**: IndexedDB `kagura.studio.modeling.v1` の `draft.kgrmodel`。明示保存で、リロード時に復元します。
- **JSON ↓**: `.kgrmodel` の編集ドキュメント。Import model JSON で再編集でき、読込は Undo できます。
- **GLB ↓**: ゲームや他のエディタで使えるメッシュ・材質・位置。グリッド、カメラ、選択表示を含めません。

GLB は三角化し、頂点を三角形のコーナーごとに分離して面法線を焼き込みます。表情は名前付きの POSITION / NORMAL モーフとして含めます。
GLB から編集ポリゴンを復元するインポートは提供していないため、再編集には JSON を保存してください。
保存前に変形を確定します。同時に別タブから上書きされた保存データは etag で競合として検出します。

## 表情の差分

下部の **表情 / Expressions** パネルで、通常の顔・喜び・怒り・悲しみ・驚き・まばたきを確認できます。
**顔を拡大** で表情が作用する部品を正面から表示します。各スライダーは 0–100% で、怒りとまばたきなど複数の差分を加算できます。
プレビューでは通常の形状や Undo 履歴を変更せず、**通常の顔** で正確に戻ります。

1. 名前を入力して **新規差分** を押すか、既存の表情を選んで **差分を編集** を押します。
2. アウトライナーで眉・目・口などの部品を選び、G / R / S で変形します。
3. 顔が一枚のメッシュなら Tab → 頂点選択で、口角など必要な頂点だけを動かします。
4. **差分を確定** で登録します。**取り消す** は編集中の表情を破棄します。登録全体を一回の Undo で戻せます。
5. **Save model** で通常の形状と全表情を保存します。プレビューの強さは保存せず、次回は通常の顔から開きます。

表情は `expressions[]` の安定した ID・表示名・対象メッシュ ID・位置と頂点の差分で保存します。
鳥や人間の部品名、顔の分割方法には依存しません。人間モデルでも同じ UI と API を使い、そのモデルの通常の顔から差分を作ります。
頂点構造の異なるキャラクターへの差分の自動転送は行いません。ゲーム側では共通の `happy` / `blink` などの ID を使って各モデルの表情を呼べます。

```js
import { evaluateModel } from './model.mjs';
// 純粋な MoonBit の評価器。DOM・Three.js・編集セッションは不要。
const posed = evaluateModel(document, { happy: 0.7, blink: 0.4 });
// editor.request({op: 'expression.begin', id: 'happy', name: '笑顔'});
// …部品や頂点の変形…
// editor.request({op: 'expression.save'});
```

元メッシュとの対応が壊れないよう、表情編集中の追加・削除・押し出し、表情が参照する部品の削除・押し出しは拒否します。
通常の頂点移動は可能です。差分は最大 32 個・合計 200,000 頂点オフセットまでで、未知の部品や不正な頂点番号はインポート時に検出します。
旧 `.kgrmodel` は表情なしとして読み込めます。新しい kawaiko の眉とプリセットは **kawaiko を読み直す** または共有 URL で開けます。

JSON は編集用の全差分を保持し、GLB は通常の顔を基準に名前付きモーフを出力します。
部品の移動も頂点の差分に含めるため、ゲームや他のツールではモーフの強さで眉や口を動かせます。

## 構成

- `core/document.mbt`: メッシュ型とバージョン、入力検証。200 オブジェクト / 50,000 頂点まで。
- `core/geometry.mbt`: 楕円体・角柱・ボックスの生成。
- `core/kawaiko.mbt`: 原画を参考にしたサンプルモデル。
- `core/edit.mbt`: 頂点変形とポリゴン押し出し。元データを変更しません。
- `core/session.mbt`: 選択・編集中の変形・確定と取消・最大 40 回の Undo。
- `core/expressions.mbt`: 汎用の差分型、検証、キャプチャ、加算ブレンド。
- `core/expression_session.mbt`: 表情プレビューと編集トランザクション。
- `core/kawaiko_expressions.mbt`: kawaiko 固有の表情制作と眉の曲面への投影。
- `expressions-pane.mjs`: 表情一覧・強さ・差分作成の UI。
- `bridge/`: MoonBit JS backend の JSON API。`model.mjs` から DOM なしで利用可能。
- `geometry.mjs` / `viewer.mjs`: Three.js への変換、ピック、カメラ、GPU リソース解放。
- `pane.mjs`: Studio の workspace slot、操作、既存 IndexedDB ストアへの接続。
- [public/modeling.d.ts](../public/modeling.d.ts): `window.kagura.modeling` の型付きコントラクト。

ビューポートは変更時だけ描画し、元のシーンの描画を中断します。変更がない部品のジオメトリは再利用し、
編集用オーバーレイは更新・終了時に破棄します。初期モデルは 2,120 頂点 / 2,338 ポリゴンです。
通常の全身表示は背景込みで 4,208 三角形 / 32 draw calls（Chrome / Metal で確認）。
表情によってメッシュ数・三角形数は増えず、プレビュー時も変わった部品だけジオメトリを更新します。

```sh
just studio-modeling-test  # JS/native の純粋ロジック、無効入力、GLB 用の面法線
just studio-modeling-e2e   # 実ブラウザの選択・変形・押し出し・保存・書出・解放
just studio-check         # Studio 全体の型と MoonBit テスト
```
