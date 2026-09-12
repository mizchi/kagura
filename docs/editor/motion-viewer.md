# 汎用モーションビューア

Studio 本体の **Motions** ペーンで、モデルとアニメーションを単体で確認する。
ゲーム固有の拡張や Play を起動する必要はない。

## 開く

`just studio-dev` で起動し、`http://127.0.0.1:5190` を開く。

1. **Examples → Hack & Slash 3D** を選ぶ。
2. **Project → motions/enemies.kgrmotion** をクリックする。
3. モデルとモーションを選ぶ。モデル選択時はそのモデルの既定クリップになる。

ASHEN HUNT のゴブリン、コボルト、射手、術師、重装ゴブリン、ボスと、パンチ・刺突・詠唱・弓射撃を同梱する。
別プロジェクトでは `.kgrprj` の `resources` に `.kgrmotion` を登録すれば同じ操作で開ける。
プロジェクトを開かずに **Motions → ファイルを選択** から読み込むこともできる。

## 確認操作

- 再生・一時停止、先頭へ戻る、前後1コマ、タイムスライダー。
- 0.25 / 0.5 / 1 / 2倍速、ループ切替。ループなしでは最終姿勢で停止する。
- Impact / Release ボタンでゲームの命中・発射時刻へ移動する。
- 骨格の重ね表示、グリッド、斜め・正面・横・俯瞰カメラ。
- キャンバス上では物理キーの Space で再生、左右矢印でコマ送り、F でフレーム。

ドラッグで回転、右ドラッグでパン、ホイールでズームする。シークとコマ送りは一時停止する。
モデル・クリップを変更してもシーンドキュメント、revision、Undo 履歴は変えない。
ペーンを閉じる・プロジェクトを切り替える・Play を開始する場合は描画ループと GPU リソースを破棄する。

## ファイルと実装

`.kgrmotion` は `format: "kagura.motion"`, `version: 1` の JSON。
[型定義](../../editor/studio/public/motions.d.ts) と [実行時検証](../../editor/studio/motions/contract.mjs) を共通契約とする。

| データ | 内容 |
| --- | --- |
| skeleton | 親を先に並べた骨格。ローカルの位置・XYZW回転・スケール |
| models | バインド姿勢のPNU頂点、三角形、頂点ごとの4関節・ウェイト、RGBA材質 |
| clips | 秒単位の時間、表示FPS、命中イベント、関節のTranslation / Rotation / Scaleチャンネル |

単位はメートル。Linear / Step 補間に対応する。Step の発射時刻が丸めでずれないよう、
時刻は Float64 で保持する。負の時間、参照切れ、循環骨格、正規化されていない回転・ウェイト、
未知フィールド、64 MiB を超えるファイルは読み込み時に拒否する。

状態と時計は `motions/player.mjs`、Threeアダプターは `motions/scene.mjs`、
描画とカメラは `motions/viewer.mjs`、UIとプロジェクトの寿命管理は `motions/pane.mjs`。
Studio の Three.js / WebGL で描くため、モデルと動作はゲームと共有するが、ゲームの照明・ポストエフェクトは適用しない。
FBXやGLBを直接アニメーション再生する画面ではなく、変換済みの共通データを確認する。

## ゲームからの出力

```sh
just hunter-motion-assets        # ゲームの実モデル・クリップから再出力
just hunter-motions-build        # HY元データからクリップとビューア用データを再構築
just studio-examples-build hacknslash_3d
just studio-motion-test          # 契約・時計・骨格・発射タイミング・API型
```

`hacknslash_3d/motion_api` はブラウザを起動しないビルド用エントリ。
ゲームと同じ素体、材質、モーションから `motions/enemies.kgrmotion` を生成する。
ゲームの予備動作・硬直の長さに合わせてキーフレーム時刻を変換し、命中イベントも出力する。
別ゲームも同じ形式へ書き出せば、ビューアへの専用コード追加は不要。

## API

```js
await kagura.motions.preview('motions/enemies.kgrmotion');
kagura.motions.selectModel('archer');
kagura.motions.seek(0.6);
kagura.motions.step(-1);
kagura.motions.showSkeleton(true);
kagura.motions.setSpeed(0.5);
kagura.motions.play();
console.log(kagura.motions.snapshot());
kagura.motions.close();
```

E2Eでは実際の描画差分、操作、シーンの保持、プロジェクトなしでの読み込み、
非同期読み込みの競合、閉じた後のキャンバス破棄を検証する。
