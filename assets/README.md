# 共通 assets

リポジトリ全体で共有・配布するファイルをこのディレクトリに集約する。

| 配置 | 内容 | 更新・検証 |
|---|---|---|
| `web/` | WebGPU・音声・Wasm host などの配布用ランタイム | MoonBit の生成物と platform_web/host のコピー。just web-runtime-build で更新する |
| `vendor/glfw/` | GLFW 由来のバインディング・ネイティブヘッダ | 外部由来であることと元のライセンス表記を保つ。描画バックエンドから include する |
| `kenney_1bit/` | 共有の画像素材 | 同梱 LICENSE.txt を保持する |

旧 `lib/web` は `assets/web`、旧 `vendor/glfw` は `assets/vendor/glfw` に移動した。配布後の `lib/` は生成先ごとの URL であり、手書き JS の編集元は platform_web/host になる。

各ゲーム固有の画像・音声・モデルはゲームの `assets/` に置く。エディタ用のモデル素材集は `examples/assets/model_assets/` にあり、ゲームの代わりに共通モデルビューアで開く。

MoonBit のエンジン実装は引き続き `core/`・`platform/`・`engine/`・`game/` に置く。ルートの公開ファサードは `lib.mbt` と `moon.pkg`。共通 assets と各 workspace モジュールは公開ファサードのパッケージへ混入させない。
