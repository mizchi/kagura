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

## 距離・交差のクエリ（`@convex`）

凸形状どうしの最短距離と最近接点は `mizchi/kagura_core/collision3d/convex` で求める。
手計算や、サンプル点での近似はしない。

```moonbit
let d = @convex.distance(
  Sphere(center=Vec3::zero(), radius=1.0),
  @convex.Shape::aabb(min=Vec3::new(2.0, -1.0, -1.0), max=Vec3::new(3.0, 1.0, 1.0)),
)
// d.distance == 1.0、d.point_a == (1, 0, 0)、d.point_b == (2, 0, 0)
```

- 形状は `Point` / `Sphere` / `Box`（中心・半辺長・回転）/ `Segment` / `Capsule` /
  `Cylinder` / `Cone` / `Hull`（頂点の凸包。三角形や四面体もこれ）。どれも中身の詰まった立体
- 重なっているときは `distance == 0`、`intersecting == true`。めり込み深さは返さない
- L 字や穴あき枠のような非凸形状は、凸形状の配列にして `distance_between_unions` に渡す
- 距離の精度は相対 1e-12。曲面（球・カプセル・円柱・円錐）では、最近接点は約 1e-6 の
  ずれを含む
- `Box` の `rotation` は単位四元数を渡す。外部データの四元数が丸められているなら
  `normalize()` してから渡す
- 正しさは 2 段で確かめている。パッケージ内のテストは閉じた式と、分離平面による証明
  （上界と下界が一致すること）。`benchmarks/spatial3d/convex_check` は spatial3d ベンチの
  証明付き正解と照合する（v3 の距離 232 問、v2 の交差判定 276 問）

## 3D シーンの snapshot（`kagura.scene3d-snapshot`）

`SceneRoot::snapshot(camera~)` は、最後に描いたシーンをワールド座標のデータにする。
画像ではなくこれを読めば、親子の変換を自分で合成せずに配置を確かめられる。

- ノードごとに `path`、`kind`（`mesh` / `group`）、`subject`、ワールドの `position` /
  `rotation`（`[x, y, z, w]`）/ `scale`、メッシュなら `box`（ローカルの境界を
  ワールドへ移した向き付きの箱。`center` / `half_extents` / `rotation`）と `sphere`
  （箱の中心から全頂点を含む球。`center` / `radius`）。数値は小数 5 桁
- 箱も球もメッシュを必ず含む。判定はその両方で行い、重なり・距離・レイは
  **両方が当たったときだけ**当たりとする（平たいメッシュは箱、丸いメッシュは球が効く）。
  球を持たない古い snapshot は箱だけで判定する
- 親の回転の下に不均一な scale があるとワールド行列が歪むので、`rotation` / `scale` は
  近似になる。スキニングするメッシュの `box` はバインドポーズの境界
- `just render <example>` が `<example>.scene3d.json` を書く（example が
  `@scene3d.publish_scene3d_snapshot_lazy` で公開している場合。今は arena3d）

```bash
kagura scene3d check <file> [--allow kind[@path]]... [--tolerance 0.01]  # 決定的な検査。残れば exit 1
kagura scene3d distance <file> world/player world/enemy     # 2 ノード間の最短距離（下のメッシュ全部を含む）
kagura scene3d overlaps <file>                              # 交わるメッシュの組
kagura scene3d raycast <file> --from 0,10,0 --direction 0,-1,0  # 当たるメッシュを近い順に
```

`check` が見るのは次の 5 種類。重なりは `subject` を持つノード（ゲームの物体）どうしだけを見る。
床と壁のような背景どうしの重なりは普通なので数えない。

| kind | 条件 |
|---|---|
| `non_finite` | 変換か箱に NaN / 無限大がある |
| `unnormalized_rotation` | 回転の長さが 1 から 1e-3 以上ずれている |
| `zero_scale` | scale の成分が 1e-6 未満 |
| `outside_view` | メッシュの箱全体がカメラの視錐台の外（同じ面の外側に 8 頂点すべてがある） |
| `overlap` | 異なる subject を持つメッシュが `--tolerance`（既定 0.01）より深く重なる（祖先と子孫の組は除く） |

重なりに許容値があるのは、物理で積んだ箱や接している球が数 mm 沈み込んで止まるため。
arena3d の 240 フレーム後では、積んだ木箱が 0.006、接した球が 0.005 沈んでいた。
`--tolerance 0` にすると、こうした接触もすべて報告する。

意図した例外は `--allow kind` か `--allow kind@path`（path 以下を含む）で外す。
**何にも当たらなかった allow も失敗にする**。古い除外が残ると、本物の不具合を黙って隠すため。

## 規約を足すとき

数値例を 1 つ決め、`conventions_wbtest.mbt` にテストを足してから、この表と
doc コメントに書く。言葉だけの規約は読み手ごとに解釈が分かれるが、数値例は分かれない。
