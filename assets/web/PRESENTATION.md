# Webゲームの表示とキャプチャ

共通の `initWebGPU()` は `kagura-presentation.js` を使い、ウィンドウごとに
1つのゲームcanvasとキャプチャ契約を登録する。初期化にWebGPUが使えない場合も
表示サイズは先に適用される。

```html
<canvas id="app" width="640" height="480"
  data-kagura-presentation="fullscreen"></canvas>
<nav data-kagura-overlay>操作ガイドなど</nav>
```

`fullscreen` は縦横比を保つ最大の矩形でブラウザの表示領域を埋める。
リサイズに追従し、ゲームの論理解像度・投影・入力座標を変更しない。
縦横比が異なる画面には余白が残る。ページは `body` の余白・スクロールを無効にする。
指定を省略した `embedded` では既存のページレイアウトを維持する。

可変の縦横比に対応するゲームは `data-kagura-fit="viewport"` を指定する。
この場合は余白なしで画面全体へ広がる。ゲーム側でカメラの投影と描画解像度を更新する必要がある。
固定のゲームには既定の `contain` を使い、引き伸ばしを避ける。

DOMのHUDや仮想コントローラーもゲームの一部として撮影する場合は、canvasを
`data-kagura-surface` の要素で包み、その中にHUDを置く。

```html
<main data-kagura-surface>
  <canvas data-kagura-presentation="fullscreen" data-kagura-fit="viewport"></canvas>
  <div id="game-hud">体力・スキル・仮想スティック</div>
</main>
```

この要素の表示領域はゲームのページが管理し、エンジンはこのまとまりを撮影対象として登録する。
ラッパーがなければ従来どおりcanvasだけが対象になる。

ブラウザUIも消すFullscreen APIはユーザー操作が必要なため、自動では実行しない。
ボタンのクリックから `await globalThis.__kaguraPresentation.requestFullscreen()` を呼べる。
非対応では `false`、拒否された場合はPromiseがrejectする。

`globalThis.__kaguraPresentation.captureTarget()` はバージョン1の観測契約を返す。

| フィールド | 意味 |
| --- | --- |
| `version` | `1` |
| `selector` | ゲームの表示領域、またはcanvasのセレクタ |
| `hideSelector` | 撮影時に隠すDOM。`[data-kagura-overlay]` |
| `rect` | 現在の表示領域。CSS px、viewport基準の x/y/width/height |
| `pixels` | canvasの現在のバッファ解像度。width/height |
| `renderedFrames` | このsurfaceからGPUへ送信済みのフレーム数 |

`captureTarget()` は呼び出し時の値を返す。`dispose()` はリサイズ監視、
capture属性、inline style、グローバルの登録を解除する。
再インストール時には前のsurfaceをdisposeし、所有者を1つに保つ。

```sh
# 起動済みの任意のKagura Webゲームを撮影
just capture-web --url http://localhost:8080/ --output output/game.png
# プレイ中の狩人サンプルを撮影
just hunter-capture
```

Playwrightでは `scripts/capture-web.mjs` の `captureGameFrame(page, {path})` を使う。
共通ランタイムの描画開始とGPUの処理完了を待ち、登録されたゲームの表示領域をCSS pxで保存する。
`data-kagura-overlay` の操作ガイドを除外し、ゲームの表示領域に含まれるHUD・操作ボタンは残す。
初期化に失敗した場合はタイムアウトし、ページ全体の撮影にはフォールバックしない。
CLIは別のブラウザを開くため、現在操作中のタブを撮影したい場合はそのPageをヘルパーに渡す。

配布時には `kagura-init.js` と同じディレクトリへ `kagura-presentation.js` もコピーする。
