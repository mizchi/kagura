# 3D の座標・回転の規約

3D の位置・回転・当たりを扱うコードを書く前に読む。どの項目も
`core/geom/math3d/conventions_wbtest.mbt` が数値例で固定しているので、
ここと実装がずれるとテストが落ちる。

| 項目 | 規約 | 数値例 |
|---|---|---|
| 手系 | 右手系。正の角度は、軸の先端から見て反時計回り | +Z 軸まわり 90° で +X → +Y。+Y 軸まわり 90° で +X → **-Z** |
| 上方向 | +Y が上（重力は `(0, -9.81, 0)`）。glTF も Y-up なので、読み込み時に軸を変換しない | — |
| 単位 | 長さはメートル、時間は秒、角度はラジアン | `from_axis_angle(axis, pi / 2.0)` が 90° |
| カメラ | `Mat4::look_at` はビュー空間でカメラを原点に置き、**-Z を向く**（+X が右、+Y が上） | 目 (0,0,5)、注視点が原点なら、原点はビュー空間の (0,0,-5) |
| 投影 | `Mat4::perspective` / `orthographic` は WebGPU の深度範囲 [0, 1] | ビュー空間の z = -near が深度 0、z = -far が深度 1 |
| 行列の並び | `Mat4` は column-major（`elements[col * 4 + row]`）。列ベクトルを右から掛ける（`m.mul_vec4(v)` が `M * v`） | — |
| 四元数の成分 | `Quaternion` は `(x, y, z, w)` で **w が最後**（glTF と同じ）。論文や一部のライブラリは `(w, x, y, z)` と書くので、値を写すときは並べ替える | `Quaternion::new(0, 0, 0, 1)` が恒等回転 |

## 合成の順序

回転も変換も可換ではないので、**どちらを先に適用するか**を名前で読めるようにしてある。

| 書き方 | 先に適用されるもの |
|---|---|
| `a.multiply(b)`（`Quaternion` / `Mat4`） | **b**（数式どおり `a * b`） |
| `a.then(b)` | **a**（書いた順に適用される） |

```moonbit
// +Y を、まず Z 軸まわり 90°、次に X 軸まわり 90° 回す
let q = turn_z.then(turn_x) // == turn_x.multiply(turn_z)
```

手順を言葉で書いた順に組み立てるときは `then` を使う。`multiply` で書くと、読み手は
右から読み直す必要があり、ここで順序を取り違えやすい。

## Euler 角

`Quaternion::from_euler(pitch~, yaw~, roll~)` は、`pitch` が X 軸、`yaw` が Y 軸、
`roll` が Z 軸まわりの角度。結果は `qx * qy * qz` なので、ベクトルには
**roll → yaw → pitch の順**（固定されたワールド軸まわり）で回転がかかる。
3 つとも `Double` なので、取り違えても型エラーにならない。そのため引数はラベル付きにしてある。

## 当たり判定の形状（`@physics3d.ColliderShape`）

コンストラクタも pattern もラベル付きでしか書けない。位置付き引数で書くとコンパイルエラーになる。
以前は variant によって引数の順番が逆だった（球は offset が先、箱は offset が後）。

| variant | 意味 |
|---|---|
| `SphereShape(offset~, radius~)` | `position + offset` を中心とする半径 `radius` の球 |
| `AABBShape(half_extents~, offset~)` | `position + offset` を中心とする箱。**`RigidBody.rotation` で回らない**（常にワールド軸に沿う） |
| `BoxShape(half_extents~, offset~)` | 同じ箱を `RigidBody.rotation` で回したもの |

`half_extents` は辺の長さの**半分**。1 辺 1 m の立方体は `Vec3::new(0.5, 0.5, 0.5)`。
`@collision3d.AABB::new(min, max)` は最小・最大の角で指定する別の型なので、混同しないこと。

## 規約を足すとき

数値例を 1 つ決め、`conventions_wbtest.mbt` にテストを足してから、この表と
doc コメントに書く。言葉だけの規約は読み手ごとに解釈が分かれるが、数値例は分かれない。
