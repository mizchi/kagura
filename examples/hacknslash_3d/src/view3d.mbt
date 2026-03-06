// 3D rendering: dungeon graph, entity graph, draw

// Colors (RGBA, 0-1 range)
let color_floor : @math3d.Vec4 = @math3d.Vec4::new(0.16, 0.16, 0.23, 1.0)

let color_floor_alt : @math3d.Vec4 = @math3d.Vec4::new(0.18, 0.18, 0.24, 1.0)

let color_corridor : @math3d.Vec4 = @math3d.Vec4::new(0.2, 0.2, 0.27, 1.0)

let color_corridor_alt : @math3d.Vec4 = @math3d.Vec4::new(0.18, 0.18, 0.24, 1.0)

let color_wall : @math3d.Vec4 = @math3d.Vec4::new(0.42, 0.26, 0.15, 1.0)

let color_wall_alt : @math3d.Vec4 = @math3d.Vec4::new(0.36, 0.20, 0.09, 1.0)

let color_door : @math3d.Vec4 = @math3d.Vec4::new(0.55, 0.41, 0.08, 1.0)

let color_player : @math3d.Vec4 = @math3d.Vec4::new(0.0, 1.0, 0.8, 1.0)

let color_player_dash : @math3d.Vec4 = @math3d.Vec4::new(0.4, 0.87, 1.0, 1.0)

let color_player_hurt : @math3d.Vec4 = @math3d.Vec4::new(1.0, 1.0, 1.0, 1.0)

let color_enemy_basic : @math3d.Vec4 = @math3d.Vec4::new(0.8, 0.13, 0.13, 1.0)

let color_enemy_fast : @math3d.Vec4 = @math3d.Vec4::new(1.0, 0.53, 0.0, 1.0)

let color_enemy_tank : @math3d.Vec4 = @math3d.Vec4::new(0.53, 0.27, 0.8, 1.0)

let color_enemy_ranged : @math3d.Vec4 = @math3d.Vec4::new(0.27, 0.67, 1.0, 1.0)

let color_enemy_boss : @math3d.Vec4 = @math3d.Vec4::new(1.0, 0.13, 0.4, 1.0)

let color_item_health : @math3d.Vec4 = @math3d.Vec4::new(0.0, 1.0, 0.4, 1.0)

let color_item_score : @math3d.Vec4 = @math3d.Vec4::new(0.0, 1.0, 1.0, 1.0)

let color_projectile : @math3d.Vec4 = @math3d.Vec4::new(1.0, 0.27, 0.4, 1.0)

// Build static dungeon scene graph (cached, rebuilt on floor reset)
fn build_dungeon_graph(dungeon : DungeonData, meshes : Meshes3D) -> @scene3d.SceneGraph {
  let graph = @scene3d.SceneGraph::new()
  for row = 0; row < dungeon.grid.height; row = row + 1 {
    for col = 0; col < dungeon.grid.width; col = col + 1 {
      let tile = dungeon.grid.get(col, row)
      let x = col.to_double()
      let z = row.to_double()
      match tile {
        Floor => {
          let checker = (col + row) % 2
          let c = if checker == 0 { color_floor } else { color_floor_alt }
          graph.add_node(
            @scene3d.scene_node(
              mesh=Some(meshes.floor_tile),
              position=@math3d.Vec3::new(x, 0.0, z),
              color=c,
            ),
          ) |> ignore
        }
        Corridor | Door => {
          let stripe = (col + row) % 3
          let c = if tile == @terrain.Door {
            color_door
          } else if stripe == 0 {
            color_corridor
          } else {
            color_corridor_alt
          }
          graph.add_node(
            @scene3d.scene_node(
              mesh=Some(meshes.floor_tile),
              position=@math3d.Vec3::new(x, 0.0, z),
              color=c,
            ),
          ) |> ignore
        }
        Wall => {
          let brick_offset = if row % 2 == 0 { 0 } else { 2 }
          let brick_pos = (col + brick_offset) % 4
          let c = if brick_pos == 0 { color_wall_alt } else { color_wall }
          graph.add_node(
            @scene3d.scene_node(
              mesh=Some(meshes.wall),
              position=@math3d.Vec3::new(x, 0.5, z),
              color=c,
            ),
          ) |> ignore
        }
        _ => ()
      }
    }
  }
  graph
}

// Build dynamic entity scene graph (per frame, items/projectiles only)
fn build_entity_graph(state : GameState) -> @scene3d.SceneGraph {
  let graph = @scene3d.SceneGraph::new()
  // Items with Y-axis bob
  for item in state.items {
    if item.alive {
      let ix = item.x / tile_size
      let iz = item.y / tile_size
      let bob = 0.3 + 0.1 * @math.sin(state.frame_count.to_double() * 0.1)
      let c = if item.kind == item_health { color_item_health } else { color_item_score }
      graph.add_node(
        @scene3d.scene_node(
          mesh=Some(state.meshes.item),
          position=@math3d.Vec3::new(ix, bob, iz),
          color=c,
        ),
      ) |> ignore
    }
  }
  // Projectiles
  for proj in state.projectiles {
    if proj.alive {
      let prx = proj.x / tile_size
      let prz = proj.y / tile_size
      graph.add_node(
        @scene3d.scene_node(
          mesh=Some(state.meshes.projectile),
          position=@math3d.Vec3::new(prx, 0.3, prz),
          color=color_projectile,
        ),
      ) |> ignore
    }
  }
  graph
}

fn GameState::draw(
  self : GameState,
  ctx : @engine.EngineContext,
) -> Array[@gfx.DrawTrianglesCommand] {
  let sw = ctx.screen_w.to_double()
  let sh = ctx.screen_h.to_double()
  match self.mode {
    m if m == mode_title => {
      let hud_node = self.view_title()
      @scene.render_scene(hud_node, ctx.dst, ctx.shader, sw, sh)
    }
    m if m == mode_gameover => {
      let hud_node = self.view_gameover()
      @scene.render_scene(hud_node, ctx.dst, ctx.shader, sw, sh)
    }
    _ => self.draw_playing(ctx)
  }
}

fn GameState::draw_playing(
  self : GameState,
  ctx : @engine.EngineContext,
) -> Array[@gfx.DrawTrianglesCommand] {
  let sw = ctx.screen_w.to_double()
  let sh = ctx.screen_h.to_double()
  let camera = self.camera.to_camera3d()
  let entity_graph = build_entity_graph(self)
  // Render 3D dungeon (static graph)
  let cmds = @scene3d.render_scene3d_graph_gpu(
    self.dungeon_graph,
    camera,
    lighting=self.lighting,
    ctx.dst,
    self.shader3d,
    ctx.screen_w,
    ctx.screen_h,
  )
  // Render 3D entities (items/projectiles)
  let entity_cmds = @scene3d.render_scene3d_graph_gpu(
    entity_graph,
    camera,
    lighting=self.lighting,
    ctx.dst,
    self.shader3d,
    ctx.screen_w,
    ctx.screen_h,
  )
  for cmd in entity_cmds {
    cmds.push(cmd)
  }
  // Render skinned enemies
  let enemy_skinning = self.enemy_models.compute_skinning()
  let skinned_objects : Array[@scene3d.Object3D] = []
  for enemy in self.enemies {
    if enemy.alive {
      let ex = enemy.x / tile_size
      let ez = enemy.y / tile_size
      let color = if enemy.damage_timer > 0 {
        color_player_hurt
      } else {
        match enemy.kind {
          k if k == kind_fast => color_enemy_fast
          k if k == kind_tank => color_enemy_tank
          k if k == kind_ranged => color_enemy_ranged
          k if k == kind_boss => color_enemy_boss
          _ => color_enemy_basic
        }
      }
      let mesh_data = self.enemy_models.get_mesh_data(enemy.kind)
      // Face toward player
      let dx = self.player.x - enemy.x
      let dy = self.player.y - enemy.y
      let face_angle = @math.atan2(dy, dx)
      let rot = @math3d.Quaternion::from_axis_angle(
        @math3d.Vec3::unit_y(),
        -face_angle + @math.PI / 2.0,
      )
      skinned_objects.push(
        @scene3d.object3d(
          mesh=mesh_data.bind_mesh,
          position=@math3d.Vec3::new(ex, 0.0, ez),
          rotation=rot,
          color=color,
          skinning=Some(
            @scene3d.SkinningState::new_with_packed(
              mesh_data.skin_data,
              enemy_skinning,
              mesh_data.packed_vertex_data,
            ),
          ),
        ),
      )
    }
  }
  if skinned_objects.length() > 0 {
    let enemy_scene = @scene3d.scene3d(
      objects=skinned_objects,
      camera~,
      lighting=self.lighting,
    )
    let enemy_cmds = @scene3d.render_scene3d_gpu(
      enemy_scene,
      ctx.dst,
      self.shader3d,
      ctx.screen_w,
      ctx.screen_h,
      shader3d_skinned=Some(self.shader3d_skinned),
    )
    for cmd in enemy_cmds {
      cmds.push(cmd)
    }
  }
  // Render skinned player character
  let px = self.player.x / tile_size
  let pz = self.player.y / tile_size
  let player_color = if self.player.dash_timer > 0 {
    color_player_dash
  } else if self.player.damage_timer > 0 {
    color_player_hurt
  } else {
    color_player
  }
  let skinning_matrices = self.character.compute_skinning()
  // Rotate character to face movement direction
  let facing_rot = @math3d.Quaternion::from_axis_angle(
    @math3d.Vec3::unit_y(),
    -self.player.facing_angle + @math.PI / 2.0,
  )
  let player_objects : Array[@scene3d.Object3D] = [
    @scene3d.object3d(
      mesh=self.character.bind_mesh,
      position=@math3d.Vec3::new(px, 0.0, pz),
      rotation=facing_rot,
      color=player_color,
      skinning=Some(
        @scene3d.SkinningState::new_with_packed(
          self.character.skin_data,
          skinning_matrices,
          self.character.packed_vertex_data,
        ),
      ),
    ),
  ]
  let player_scene = @scene3d.scene3d(
    objects=player_objects,
    camera~,
    lighting=self.lighting,
  )
  let player_cmds = @scene3d.render_scene3d_gpu(
    player_scene,
    ctx.dst,
    self.shader3d,
    ctx.screen_w,
    ctx.screen_h,
    shader3d_skinned=Some(self.shader3d_skinned),
  )
  for cmd in player_cmds {
    cmds.push(cmd)
  }
  // Render 2D HUD overlay
  let hud_node = render_hud(self)
  let hud_cmds = @scene.render_scene(hud_node, ctx.dst, ctx.shader, sw, sh)
  for cmd in hud_cmds {
    cmds.push(cmd)
  }
  cmds
}
