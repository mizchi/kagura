# API Guide

`kagura` は low-level 契約を中心に構成されています。  
最初は以下の API から入るのを推奨します。

## 実行ループ

- `@runtime.run_loop`: ゲームループ実行
- `@core.Game`: `layout` / `update` / `draw` の契約
- `@core.default_run_options`, `@runtime.default_runtime_config`

## プラットフォーム

- `@platform.create_web_canvas_platform`
- `@platform.create_desktop_glfw_platform`
- `@platform.new_window_options`

## グラフィクス

- `@gfx.create_webgpu_graphics`
- `@gfx.create_wgpu_native_graphics`
- `@gfx.default_graphics_backend_options`
- `@gfx.DrawTrianglesCommand`（描画の基本単位）

## ユーティリティ

- `@inpututil`: キー/マウスの just pressed 判定
- `@debugutil`: 矩形/数字などの簡易描画コマンド生成
- `@sprite2d`, `@draw2d`: atlas ベース 2D 描画の補助

## 実コード参照

- 最小構成: `examples/runtime_smoke/src/main_js.mbt`
- 2D ゲーム: `examples/flappy_bird/src/game.mbt`
- 複合ゲーム: `examples/survivor/src/game.mbt`
