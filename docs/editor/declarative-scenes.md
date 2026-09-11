# コードをそのままシーンの構造にする

Kagura のゲームは、状態を更新するコードと、その状態からシーンを宣言する `view.mbt` を分けます。静的な親子関係は `children` の入れ子で表し、配列からの生成や条件分岐は `for_each` / `show` に現れます。ヒエラルキーをエディタ用 JSON に再定義しません。

2D は既存の `mizchi/kagura_game/scene` を継続使用します。3D は既存の `mizchi/kagura_engine/scene3d` に宣言 API を追加しました。[luna-three](https://github.com/mizchi/three-mbt/tree/main/luna-three) の入れ子の要素・コンポーネント・兄弟内のキー・借用リソースという構成を参考にしています。描画先は Kagura のままで、three.js や React の実行環境を追加していません。

## 2D

```moonbit
@scene.group(key="world", children=[
  @scene.rect(key="ground", y=220.0, w=320.0, h=20.0),
  @scene.rect(key="bird", x=60.0, y=state.bird_y.get(), w=12.0, h=12.0),
  @scene.group(key="hud", children=[
    @scene.label(key="score", content=state.score.get().to_string()),
  ]),
])
```

`resolve(view)` は動的属性・条件・生成処理を一度評価し、描画ノードと `hierarchy` を返します。その `node` を既存の `render_scene` に渡すと、描画時に生成処理を再実行しません。Flappy Bird の `resolved_view()` がこの入口です。`rect / group / label / line / rect_outline` に任意の `key` と `name` を追加し、既存コードも動きます。

`key` のない 2D 要素は兄弟内の位置 `@0` などで識別します。並べ替えや個体への参照が必要な要素には明示キーを付けます。Flappy Bird の `pipes` の子は現在この位置ベースで、パイプ自体の永続 ID を保証しません。

## 3D

```moonbit
@scene3d.scene(
  camera=self.camera.to_camera3d(),
  lighting=self.lighting,
  root=@scene3d.group(key="world", children=[
    @scene3d.group(key="environment", children=[
      @scene3d.mesh(key="ground", mesh=self.meshes.ground),
    ]),
    @scene3d.mesh(key="player", mesh=self.meshes.player, position=self.player.position),
  ]),
)
```

`SceneView` はルートのツリーと既存のカメラ・照明契約をまとめます。カメラと照明はシーンの設定で、オブジェクトヒエラルキーには含めません。Arena 3D の `scene()` / `scene_view()` に実装例があります。

ゲームごとに `SceneRoot::new()` を一つ保持し、各フレームで `root.render(view)` します。`root.graph()` は描画用に借用し、外から変更しません。これを既存の 3D レンダラーに渡し、エディタは `root.hierarchy()` を読みます。位置・回転・スケールは親から子へ合成されます。キー付きノードの並べ替えでは ID を維持し、削除したノードはグラフから除きます。重複キー・不正キー・過大なツリーの更新は、直前のグラフを残して拒否します。

```moonbit
@scene3d.group(key="enemies", children=[
  @scene3d.for_each(fn() {
    enemies.map(fn(enemy) {
      @scene3d.mesh(key=enemy.id, mesh=enemy_mesh, position=enemy.position)
    })
  }),
])
```

`fragment` と `component` は透明な構造で、グラフへ余分なグループを追加しません。通常の MoonBit 関数をコンポーネントとして分割できます。`show` / `for_each` の結果はヒエラルキー上で `generated: true` になり、静的な要素と区別できます。キーは兄弟内で一意にし、解決後の ID は `world/enemies/enemy-1` のようなパスになります。別の親に移動すると別 ID です。

Kagura は既存の更新・描画ループに合わせ、view とそのコンポーネントをフレームごとに評価します。Luna の mount 一回＋Signal の部分更新をそのまま実装したものではありません。view は状態を書き換えない純粋な関数にし、メッシュ・材質・スキニング資源はゲーム側で用意して借用します。再評価のたびに GPU リソースを新規作成しないようにします。

## エディタと AI

共通の検査契約は `core/kagura_core/hierarchy` の `Node`（`id / name / kind / generated / children`）です。描画時に解決したヒエラルキーをゲームが保持し、`kaguraSceneRuntime.hierarchy()` から公開します。ヒエラルキーを読むために view を再実行しません。

Studio は Play 中に **Scene hierarchy** を表示します。Flappy Bird / Arena 3D が対応済みです。約 250 ms ごとに読んで構造が変化した場合だけ DOM を更新します。停止中の状態変更も次の描画から反映されます。`kagura.runtime.hierarchy()` と WebMCP の `kagura.runtime_hierarchy` が同じ読み取り API です。

これは描画済みシーンの読み取り専用の投影です。状態変更はゲーム所有の runtime API、コードの変更はソース編集で行います。任意の `view.mbt` をエディタが構文解析・逆変換して保存する機能ではありません。既存の `scenes/*.mbt` は初期配置 fixture として引き続き使えます。

他ゲームも宣言 API を利用できますが、この変更で全 examples や IRON YARD の低レベル描画を変換したわけではありません。独自のスキニング・PBR・演出経路は既存レンダラーの契約を維持します。

```sh
just studio-declarative-test
just target=native studio-declarative-test
just studio-examples-build flappy_bird arena3d
```
