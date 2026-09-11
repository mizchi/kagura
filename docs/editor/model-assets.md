# 汎用モデルプレビュー

モデルの閲覧は Studio 本体の機能として提供する。ゲームごとの editor 拡張や Play ランタイムは不要。

1. `.kgrprj` を含むフォルダ、または Examples のプロジェクトを開く。
2. Project の `.glb` / `.gltf` / `.obj` をクリックする。Models タブのセレクタからも選択できる。
3. 中央のプレビューで左ドラッグで回転、右ドラッグで平行移動、ホイールで拡大縮小する。Frame model で全体表示に戻る。
4. Close model または別のペーンを開くと、プレビューの GPU デバイスと iframe を解放して編集ビューに戻る。

モデルは読み取り専用で閲覧する。シーンへの追加、モデル自身の編集、Undo 履歴、シーン保存とは独立している。リソース一覧のダウンロードボタンも引き続き使える。glTF Viewer / OBJ Viewer の Studio プロジェクトは汎用エディタを使用する。各 example の MoonBit コードは単独起動・SDK のサンプルとして残している。

## 実装と API

- `editor/model-viewer/`: フラットな MoonBit モジュール。Kagura の glTF / OBJ ローダー、SceneGraph、renderer3d、WGSL を使用。親子のワールド変換を含むモデル全体の bounds からカメラを決める。
- `editor/studio/assets/model.mjs`: DOM / GPU に依存しない入力準備。`prepareModel({ read(path): Promise<Blob> }, path)`。戻り値の型は `model.d.mts`。
- `editor/studio/assets/pane.mjs`: 本体に常設する Models ペーンとプレビューの寿命管理。読込中にモデル・プロジェクト・ペーンが変わった場合、古い結果は反映しない。
- `editor/studio/assets/runtime.mjs`: 同一オリジンの独立した WebGPU ランタイム。ゲームスクリプトを起動しない。プレビュー中は背後の汎用 Three.js ビューポートを休止する。ゲームのライブ状態は書き換えない。

```js
await kagura.assets.list();
await kagura.assets.preview('assets/robot.glb');
kagura.assets.snapshot(); // path, state, warnings, stats: { nodes, triangles }
kagura.assets.close();
```

WebMCP: `kagura.asset_list`, `kagura.asset_preview`, `kagura.asset_snapshot`, `kagura.asset_close`。表示操作はシーンの revision を変更しない。公開ブラウザ API は `public/contract.d.ts` に定義する。

## リソース解決と対応範囲

`ProjectResources.read/list` を通すため、フォルダ・IndexedDB・HTTP / Worker / R2 などのストアを共通に扱える。`.gltf` の外部バッファはモデルからの相対パスで解決し、同じプロジェクト内の `../shared/mesh.bin` も使用できる。ルート外や外部 URL への参照は拒否する。base64 の埋込バッファと GLB の BIN チャンクも扱う。入力合計は 64 MiB、階層は 128 段まで。

今回共有化したのは既存ローダーの静的表示機能。次は制限として UI に表示する。

- glTF の画像テクスチャは未読込。既存ローダーが復元する base color を表示する。
- スキニング・アニメーション再生は未接続。
- glTF の matrix 変換は既存ローダーが未対応。TRS 形式を使う。
- 複数 primitive のマテリアルは先頭のものになる。
- OBJ はジオメトリのみ。MTL は未読込。

必須拡張が指定された glTF（Draco など）は、対応しているように表示せず読込エラーにする。このプレビューの追加で、汎用シーン編集用の Three.js レンダラーを全面的に置き換えてはいない。

## 検証

```sh
just studio-model-test
just studio-model-build
just studio-build
# editor/studio 内でバックグラウンド実行
STUDIO_PREVIEW=1 STUDIO_GPU=metal pnpm exec playwright test e2e/model-assets.spec.mjs --workers=2 > /tmp/model-assets-e2e.log 2>&1 &
```

`studio-build` / `studio-dev` は共通モデルランタイムもビルドする。ゲーム examples の生成物を使わずに `studio-model-build` 単独でも生成できる。
