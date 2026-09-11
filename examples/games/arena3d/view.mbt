///|
/// Camera, lighting and the object hierarchy are declared together.
fn GameState::scene(self : GameState) -> @scene3d.SceneView {
  @scene3d.scene(
    root=self.scene_view(),
    camera=self.camera.to_camera3d(),
    lighting=self.lighting,
  )
}

///|
/// The scene hierarchy is the declaration itself; loops are explicit dynamic branches.
fn GameState::scene_view(self : GameState) -> @scene3d.View {
  if self.authored is Some(session) {
    return @scene3d.group(key="arena", children=[
      @scene3d.group(key="level", children=[
        @scene3d.for_each(fn() { self.authored_nodes(session) }),
      ]),
    ])
  }
  let h = arena_half
  let wh = wall_height / 2.0
  let wt = wall_thickness
  @scene3d.group(key="arena", children=[
    @scene3d.group(key="environment", children=[
      @scene3d.mesh(key="ground", mesh=self.meshes.ground, color=color_ground),
      @scene3d.group(key="walls", children=[
        @scene3d.mesh(
          key="north",
          mesh=self.meshes.wall,
          position=@math3d.Vec3::new(0.0, wh, -(h + wt / 2.0)),
          scale=@math3d.Vec3::new(h * 2.0 + wt * 2.0, wall_height, wt),
          color=color_wall,
        ),
        @scene3d.mesh(
          key="south",
          mesh=self.meshes.wall,
          position=@math3d.Vec3::new(0.0, wh, h + wt / 2.0),
          scale=@math3d.Vec3::new(h * 2.0 + wt * 2.0, wall_height, wt),
          color=color_wall,
        ),
        @scene3d.mesh(
          key="west",
          mesh=self.meshes.wall,
          position=@math3d.Vec3::new(-(h + wt / 2.0), wh, 0.0),
          scale=@math3d.Vec3::new(wt, wall_height, h * 2.0),
          color=color_wall,
        ),
        @scene3d.mesh(
          key="east",
          mesh=self.meshes.wall,
          position=@math3d.Vec3::new(h + wt / 2.0, wh, 0.0),
          scale=@math3d.Vec3::new(wt, wall_height, h * 2.0),
          color=color_wall,
        ),
      ]),
    ]),
    @scene3d.group(key="items", children=[
      @scene3d.for_each(fn() {
        let nodes = []
        for i, item in self.items {
          if item.active {
            nodes.push(
              @scene3d.mesh(
                key="item-" + i.to_string(),
                mesh=self.meshes.item,
                position=item.position,
                color=color_item,
              ),
            )
          }
        }
        nodes
      }),
    ]),
    @scene3d.group(key="enemies", children=[
      @scene3d.for_each(fn() {
        self.enemies.mapi(fn(i, enemy) {
          @scene3d.mesh(
            key="enemy-" + i.to_string(),
            mesh=self.meshes.enemy,
            position=enemy.position,
            color=color_enemy,
          )
        })
      }),
    ]),
    @scene3d.mesh(
      key="player",
      mesh=self.meshes.player,
      position=self.player.position,
      color=color_player,
    ),
  ])
}

///|
fn GameState::scene_hierarchy(self : GameState) -> String {
  self.scene_root.hierarchy().to_json().stringify()
}
