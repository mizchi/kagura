# チュートリアル

[English](tutorials.md)

## 推奨学習順

1. `scene_demo` -- 宣言的 API の最小構成
2. `flappy_bird` -- 2D ゲームループ
3. `survivor` -- エンティティ管理・カメラ
4. `arena3d` -- 一人称・三人称の操作と剛体物理

## 1. scene_demo で宣言的 API を理解する

- 参照: `examples/demos-2d/scene_demo/game.mbt`
- 目的: `@scene.run` + Signal + view 関数の基本パターンを把握する

### 基本構造

```moonbit
struct Game {
  score : @signals.Signal[Int]
  player_x : @signals.Signal[Double]
  input : @inpututil.InputHelper
}
```

Signal で view に影響する状態を管理し、`update` で `@signals.batch` 内で更新します。

### view 関数

`view()` は毎フレーム呼ばれ、`SceneNode` ツリーを返します。

```moonbit
fn Game::view(self : Game) -> @scene.SceneNode {
  @scene.fragment([
    @scene.rect(w=320.0, h=240.0, fill=0x1a1a2e),
    @scene.rect(x=self.player_x.get(), y=120.0, w=16.0, h=16.0, fill=0x00FF88),
    @scene.label(x=160.0, y=12.0, content="SCORE:" + self.score.get().to_string()),
  ])
}
```

### エントリポイント（JS）

```moonbit
fn main {
  @web_hooks.install("#app")
  let game = Game::new()
  @scene.run(
    view=fn() { game.view() },
    update=fn(input) { game.update(input) },
    width=320, height=240,
    title="scene_demo", canvas="#app",
  )
}
```

## 2. flappy_bird で 2D ゲームループを作る

- 参照: `examples/games/flappy_bird/game.mbt`
- 目的: 入力処理、物理（重力）、衝突判定、ゲームモード遷移を学ぶ

### ポイント

- view に影響する状態は Signal（`bird_y`, `score`, `pipes`）、内部状態は `mut`（`velocity`）
- `@scene.for_each` で動的なパイプ配列を描画
- `@scene.show` でタイトル/ゲームオーバー画面を条件表示

## 3. survivor で拡張可能な構造を学ぶ

- 参照: `examples/games/survivor/game.mbt`
- 目的: 多数のエンティティ、カメラ追従、レベルアップ UI の構造を学ぶ

### ポイント

- `@camera2d.Camera2D` でワールド座標→スクリーン座標変換
- view 内で `camera.world_to_screen_x/y` を使って描画位置を計算
- `@scene.for_each` で敵・アイテム・弾を動的描画
- `@scene.group` で HP バーなどの相対配置

## 4. arena3d で 3D 操作と物理を学ぶ

- 参照: `examples/games/arena3d/{controls,physics,view}.mbt`
- V で視点切替、WASD で移動、Space でジャンプ、クリックまたは F で射撃する。
- 一人称・三人称でプレイヤー、照準、物理ワールドを共有する。
- `PhysicsWorld` が重力・衝突・力積を処理し、表示側は剛体の位置を参照する。
- Studio では `crate`・`ball` を配置できる。R でシーンを初期状態に戻す。

## 実行メモ

各 example は個別 module です。実行時は対象ディレクトリで:

```bash
just dev arena3d
```
