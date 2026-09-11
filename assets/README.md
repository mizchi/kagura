# 共通 assets

リポジトリ全体で共有・配布するファイルをこのディレクトリに集約する。

| 配置 | 内容 | 更新・検証 |
|---|---|---|
| `web/` | WebGPU・音声・Wasm host などのブラウザ用ランタイムとテスト | ここを正とし、Studio / Pages / ゲームのビルドで必要なファイルをコピーする |
| `vendor/glfw/` | GLFW 由来のバインディング・ネイティブヘッダ | 外部由来であることと元のライセンス表記を保つ。描画バックエンドから include する |
| `kenney_1bit/` | 共有の画像素材 | 同梱 LICENSE.txt を保持する |

旧 `lib/web` は `assets/web`、旧 `vendor/glfw` は `assets/vendor/glfw` に移動した。配布後の `lib/` は生成先ごとの URL であり、編集対象のソースディレクトリはここだけになる。

各ゲーム固有の画像・音声・モデルはゲームの `assets/` に置く。エディタ用のモデル素材集は `examples/assets/model_assets/` にあり、ゲームの代わりに共通モデルビューアで開く。

MoonBit のエンジン実装は引き続き `core/`・`platform/`・`engine/`・`game/` に置く。ルートの公開ファサードは `lib.mbt` と `moon.pkg`。共通 assets と各 workspace モジュールは公開ファサードのパッケージへ混入させない。
