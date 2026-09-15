# Mesh Modeling

Studio の **Modeling** ボタンで開く、ローポリモデルの編集環境。
[chibivue-land/art の kawaiko](https://github.com/chibivue-land/art/blob/main/kawaiko.png) を参考に、
緑の頭・黄色いくちばし・羽毛・水かき・V 字のバッグを 25 個の独立したメッシュとして制作しています。
原画は編集画面から参照し、モデルは MoonBit の [kawaiiko.mbt](core/kawaiiko.mbt) が正本です。

```sh
just studio-dev
# http://127.0.0.1:5190/ → Modeling
```

初期画面を共有する場合は `?mode=modeling&model=kawaiiko` を付けます。

公開版: [kawaiiko を開く](https://mizchi.github.io/kagura/studio/?mode=modeling&model=kawaiiko)

```text
http://127.0.0.1:5190/?mode=modeling&model=kawaiiko
```

ページの起動時に Modeling を開き、保存済みデータよりも kawaiiko の初期モデルを優先します。
URL は初期モデルへのリンクで、編集中の形状は含みません。既存の下書きは明示的に Save するまで変更しません。
`?mode=modeling` だけなら保存済みの下書きを復元し、パラメーターなしなら通常の Studio を開きます。
公開先でも、Studio の URL に同じクエリーを付けられます。現在の組込みモデル名は `kawaiiko` です。

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

GLB は三角化し、頂点を三角形のコーナーごとに分離して面法線を焼き込みます。
GLB から編集ポリゴンを復元するインポートは提供していないため、再編集には JSON を保存してください。
保存前に変形を確定します。同時に別タブから上書きされた保存データは etag で競合として検出します。

## 構成

- `core/document.mbt`: メッシュ型とバージョン、入力検証。200 オブジェクト / 50,000 頂点まで。
- `core/geometry.mbt`: 楕円体・角柱・ボックスの生成。
- `core/kawaiiko.mbt`: 原画を参考にしたサンプルモデル。
- `core/edit.mbt`: 頂点変形とポリゴン押し出し。元データを変更しません。
- `core/session.mbt`: 選択・編集中の変形・確定と取消・最大 40 回の Undo。
- `bridge/`: MoonBit JS backend の JSON API。`model.mjs` から DOM なしで利用可能。
- `geometry.mjs` / `viewer.mjs`: Three.js への変換、ピック、カメラ、GPU リソース解放。
- `pane.mjs`: Studio の workspace slot、操作、既存 IndexedDB ストアへの接続。
- [public/modeling.d.ts](../public/modeling.d.ts): `window.kagura.modeling` の型付きコントラクト。

ビューポートは変更時だけ描画し、元のシーンの描画を中断します。変更がない部品のジオメトリは再利用し、
編集用オーバーレイは更新・終了時に破棄します。初期モデルは 2,034 頂点 / 2,250 ポリゴン、
背景込みで 4,048 三角形 / 29 draw calls（通常の Object Mode、実ブラウザで確認）。

```sh
just studio-modeling-test  # JS/native の純粋ロジック、無効入力、GLB 用の面法線
just studio-modeling-e2e   # 実ブラウザの選択・変形・押し出し・保存・書出・解放
just studio-check         # Studio 全体の型と MoonBit テスト
```
