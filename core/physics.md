# Physics and collision calculations

物理・衝突計算は `mizchi/kagura_core` の package です。

- `mizchi/kagura_core/physics2d`: 2D rigid bodies, contacts, joints, broadphase and queries.
- `mizchi/kagura_core/physics3d`: 3D rigid bodies, contacts, joints and solver.
- `mizchi/kagura_core/collision3d`: AABB, sphere, ray and broadphase queries.

world、状態、時間刻みを呼び出し元から受け取り、GPU やホストに依存しません。
経路探索は独立 module `core/pathfind`（`mizchi/pathfind`）にあります。

```sh
moon test core/physics2d core/physics3d core/collision3d --target js
just bench-gate
```
