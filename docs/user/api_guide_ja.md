# API ガイド

[English](api_guide.md)

`kagura` は low-level 契約と宣言的 scene API の 2 層で構成されています。

## 宣言的 Scene API（推奨）

`@scene` パッケージはプラットフォーム初期化・ゲームループ・描画を抽象化し、宣言的にゲームを記述できます。

### エントリポイント

```moonbit
@scene.run(
  view=fn() { game.view() },      // 毎フレーム呼ばれる View 関数
  update=fn(input) { game.update(input) },  // 状態更新
  width=320, height=240,
  title="my_game",
  canvas="#app",      // JS のみ: canvas セレクタ
)
```

### 描画要素

| 関数 | 説明 | 主なパラメータ |
|------|------|---------------|
| `@scene.rect` | 塗りつぶし矩形 | `x~`, `y~`, `w~`, `h~`, `fill~`, `alpha~` |
| `@scene.label` | テキスト表示 | `x~`, `y~`, `content~`, `color~`, `scale~` |
| `@scene.group` | 子要素のオフセット | `x~`, `y~`, `children~` |
| `@scene.line` | 直線 | `x0~`, `y0~`, `x1~`, `y1~`, `width~`, `color~` |
| `@scene.rect_outline` | 矩形枠線 | `x~`, `y~`, `w~`, `h~`, `line_width~`, `color~` |

### 制御フロー

| 関数 | 説明 |
|------|------|
| `@scene.fragment(children)` | 複数要素をまとめる |
| `@scene.show(when, child)` | 条件付き表示 |
| `@scene.for_each(items)` | 動的リスト描画 |
| `@scene.switch_(cases~, fallback?)` | 排他的条件分岐 |
| `@scene.match_case(when~, render~)` | switch_ 用の case |

### Signal による状態管理

`mizchi/signals` と組み合わせてリアクティブな状態管理ができます。

```moonbit
let score = @signals.signal(0)

fn view() -> @scene.SceneNode {
  @scene.label(content="SCORE:" + score.get().to_string())
}

fn update(input : @core.InputSnapshot) {
  @signals.batch(fn() {
    score.set(score.get() + 1)
  })
}
```

## Low-level API

### 実行ループ

- `@runtime.run_loop`: ゲームループ実行
- `@core.Game`: `layout` / `update` / `draw` の契約
- `@core.default_run_options`, `@runtime.default_runtime_config`

### プラットフォーム

- `@platform.create_web_canvas_platform`
- `@platform.create_desktop_glfw_platform`
- `@platform.new_window_options`

### グラフィクス

- `@gfx.create_webgpu_graphics`
- `@gfx.create_wgpu_native_graphics`
- `@gfx.default_graphics_backend_options`
- `@gfx.DrawTrianglesCommand`（描画の基本単位）

### ユーティリティ

- `@inpututil`: キー/マウスの just pressed 判定
- `@debugutil`: 矩形/数字などの簡易描画コマンド生成
- `@camera2d`: 2D カメラ（ワールド→スクリーン変換）
- `@tilemap2d`: タイルマップ描画

## 実コード参照

- 最小 scene API: `examples/scene_demo/src/game.mbt`
- 2D ゲーム: `examples/flappy_bird/src/game.mbt`
- 複合ゲーム: `examples/survivor/src/game.mbt`
- アクション RPG: `examples/action_rpg/src/game.mbt`
- Low-level 3D: `examples/arena3d/src/game.mbt`
