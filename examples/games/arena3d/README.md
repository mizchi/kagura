# Arena 3D

収集・射撃・ジャンプと剛体物理を試すサンプル。FPS Demo の操作を統合し、一人称と三人称で同じプレイヤー・照準・ワールドを共有する。

起動はリポジトリ直下で `just dev arena3d`。Pages のビルドでは `/arena3d/`、Studio では Examples の Arena 3D を開く。

| 入力 | 操作 |
|---|---|
| WASD / 矢印 | 視線に対して移動 |
| Space | ジャンプ |
| 左クリック / F | 射撃 |
| 右ドラッグ | 視線を動かす |
| Q / E、I / K | 左右、上下に視線を動かす |
| V | 一人称・三人称の切り替え |
| R | 現在のステージをリセット |

黄色いアイテムは10点、赤い敵を撃つと25点。敵に触れると終了し、Rで再開できる。水色の床を踏むと次のシーンに移動する。

初期シーンには箱6個と球3個を配置する。射撃は最も手前の物体にだけ作用し、箱や球には力積を与える。壁や床は射撃を遮る。Studio の `crate` と `ball` 部品で配置できる。

- `scenes/training.mbt`: 床・壁・箱・球などの配置
- `controls.mbt`: 視点、移動、ジャンプ、カメラの障害物回避
- `physics.mbt`: `core/physics3d` への接続、射撃照会、表示用の剛体参照
- `view.mbt` / `hud.mbt`: シーンと操作表示

箱の衝突形状はAABB、球はSphereを使用する。60Hzの固定ステップで更新し、描画メッシュは再利用する。射撃で剛体を追加せず、弾道表示も最大12個に限定する。

```sh
moon -C examples/games/arena3d test . --target js
moon -C examples/games/arena3d test . --target native
moon -C examples/games/arena3d bench . --target js --release
```

ローカルJS releaseベンチでは更新が約14µs、活動中の剛体9個の物理ステップが約18µs、シーングラフと描画コマンドの構築が約31µs。これはCPU処理の参考値で、GPU描画やブラウザへの転送時間を含まない。実入力の回帰確認は `e2e/pages-arena.spec.ts` と Studio の `e2e/scene-patterns.spec.mjs` にある。
