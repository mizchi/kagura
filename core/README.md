# mizchi/kagura_core

ホストや描画から独立した計算・データの層です。入力スナップショット、固定 timestep、
階層、地形・メッシュ生成を持ちます。値・状態・seed を受け取り、結果を返すか
呼び出し元の状態を更新します。GPU リソースやブラウザ／OS FFI は持ちません。

`geom`、`mesh3d`、`anim3d`（骨格・IK）、`pathfind` は独立 module です。
`physics2d`、`physics3d`、`collision3d`、`terrain3d`、`procedural3d` はこの module の package です。
`packing2d` は矩形配置、`particle3d` は粒子の生成・運動・寿命、`statistics` は数値集計を担当します。
再生時間の `Timeline` は独立 module 内の `anim3d/playback` にあり、2D・3D・Web ビューアで共有します。

描画 callback と実行オプションは `mizchi/kagura_engine/application` を使用します。
共通入力型は `mizchi/kagura_core`、押下差分と押下時間は `core/inputstate`。
WASD の移動・決定などの割り当てと InputHelper は `game/inpututil` が所有します。

[層の責務と依存方向](../docs/architecture/module_boundaries.md)
