///|
priv struct App {
  mut game : @sim.Game
  strix : @rig.Asset
  bastion : @rig.Asset
  mut animator : @rig.Animator
  mut eye : @math3d.Vec3
  mut input : @sim.Input
  mut previous : Double
  mut aspect : Double
  cube : @mesh3d.Mesh3D
  sphere : @mesh3d.Mesh3D
  plane : @mesh3d.Mesh3D
  sky : @mesh3d.Mesh3D
  scenery : Array[SceneryPart]
  pbr : @gfx.ShaderHandle
  unlit : @gfx.ShaderHandle
  textured_unlit : @gfx.ShaderHandle
  shadow_clear : @gfx.ShaderHandle
  textured : @gfx.ShaderHandle
  depth_shader : @gfx.ShaderHandle
  sky_shader : @gfx.ShaderHandle
  present : @gfx.ShaderHandle
  lighting : @light3d.LightingEnvironment
  environment : @draw3d.PbrEnvironment
  shadow : @draw3d.PbrShadow
  uniforms : Array[Array[Int]]
  mut uniform_cursor : Int
}

///|
let app : Ref[App?] = Ref(None)

///|
extern "js" fn now() -> Double =
  #| () => performance.now()/1000

///|
extern "js" fn publish(source : String, projection : String) -> Unit =
  #| (source, projection) => globalThis.ironYardFrame?.(JSON.parse(source),JSON.parse(projection))

///|
pub fn register_image(
  id : Int,
  width : Int,
  height : Int,
  rgba : Array[Int],
) -> Unit {
  @hooks.install("#app")
  @hooks.register_source_image_rgba8(id, width, height, rgba)
}

///|
pub fn start(strix : String, bastion : String) -> Unit {
  @hooks.install("#app")
  let strix = @rig.read_asset(strix) catch { _ => panic() }
  let bastion = @rig.read_asset(bastion) catch { _ => panic() }
  let game = @sim.new_game()
  let lighting = @light3d.LightingEnvironment::new(
    @light3d.DirectionalLight::new(
      @sim.vec(35.0, -65.0, 25.0),
      rgb(0xfff0d7),
      3.2,
    ),
    @light3d.AmbientLight::new(rgb(0xe1edff), 1.3),
  )
  let state : App = {
    game,
    strix,
    bastion,
    animator: @rig.new_animator(strix),
    eye: @sim.camera_position(game.pilot),
    input: @sim.input(),
    previous: now(),
    aspect: 1.5,
    cube: @mesh3d.Mesh3D::cube(1.0),
    sphere: @mesh3d.Mesh3D::sphere(1.0, 8, 6),
    plane: @mesh3d.Mesh3D::plane(1.0, 1.0),
    sky: sky_mesh(),
    scenery: scenery(game.stage),
    pbr: @gfx.new_shader_handle(
      102,
      instance_shader(@draw3d.shader3d_standard_wgsl(), 104),
    ),
    textured: @gfx.new_shader_handle(
      103,
      instance_shader(@draw3d.shader3d_standard_wgsl(srgb_texture=true), 104),
    ),
    unlit: @gfx.new_shader_handle(
      107,
      @draw3d.shader3d_standard_unlit_wgsl(tonemapped=false),
    ),
    textured_unlit: @gfx.new_shader_handle(
      108,
      @draw3d.shader3d_standard_unlit_wgsl(srgb_texture=true),
    ),
    shadow_clear: @gfx.new_shader_handle(
      109,
      @shadow3d.shader_shadow_clear_wgsl(),
    ),
    depth_shader: @gfx.new_shader_handle(
      105,
      instance_shader(@shadow3d.shader_shadow_depth_wgsl(packed_depth=true), 16),
    ),
    sky_shader: @gfx.new_shader_handle(
      106,
      @draw3d.shader3d_standard_unlit_wgsl(tonemapped=false, fog=false),
    ),
    present: @gfx.new_shader_handle(110, @draw3d.shader3d_present_wgsl()),
    lighting,
    environment: pbr_environment(),
    shadow: pbr_shadow(lighting),
    uniforms: [],
    uniform_cursor: 0,
  }
  app.val = Some(state)
  @engine.run(
    update=fn(_) { update(state) },
    draw=fn(ctx) { draw(state, ctx) },
    audio_ctx=mixer,
    width=960,
    height=640,
    title="IRON YARD / Kagura",
    canvas="#app",
  )
}

///|
pub fn set_input(
  forward : Double,
  strafe : Double,
  boost : Bool,
  jump : Bool,
  fire : Bool,
  lock : Bool,
  yaw : Double,
  pitch : Double,
) -> Unit {
  if app.val is Some(a) {
    a.input = @sim.input(
      forward~,
      strafe~,
      boost~,
      jump~,
      fire~,
      lock~,
      yaw~,
      pitch~,
    )
  }
}

///|
pub fn command(operation : String) -> Unit {
  if app.val is Some(a) {
    match operation {
      "start" => {
        @sim.start_playing(a.game)
        @audio.audio_resume()
        play_sound("battle", restart=false)
      }
      "pause" => {
        if a.game.phase == "playing" {
          pause_audio()
        }
        @sim.pause(a.game)
      }
      "reset" | "training" | "combat" => {
        let ai = if operation == "reset" {
          a.game.ai
        } else {
          operation == "combat"
        }
        a.game = @sim.new_game(ai~)
        a.animator = @rig.new_animator(a.strix)
        a.eye = @sim.camera_position(a.game.pilot)
        a.input = @sim.input()
      }
      _ => ()
    }
  }
}

///|
pub fn snapshot() -> String {
  if app.val is Some(a) {
    @sim.snapshot(a.game)
  } else {
    "{}"
  }
}

///|
fn camera(a : App) -> @camera3d.Camera3D {
  @camera3d.Camera3D::new_perspective(
    a.eye,
    @sim.camera_aim(a.game.pilot),
    @sim.vec(0.0, 1.0, 0.0),
    58.0 * @math.PI / 180.0,
    a.aspect,
    0.15,
    260.0,
  )
}

///|
fn update(a : App) -> Unit {
  let time = now()
  let dt = @sim.clamp(time - a.previous, 0.0, 0.1)
  a.previous = time
  let shots = a.game.shots
  let hits = a.game.hits
  let kills = a.game.kills
  let enemy_hits = a.game.enemy_hits
  let phase = a.game.phase
  @sim.advance_motion(a.game, a.input, dt)
  let boxes = @sim.colliders(a.game)
  let pilot = a.game.pilot
  a.eye = @sim.constrain_camera(
    @sim.camera_target(pilot),
    a.eye.lerp(@sim.camera_position(pilot), 1.0 - @math.exp(-14.0 * dt)),
    boxes,
  )
  let focus = @sim.view_focus(a.eye, @sim.camera_aim(pilot), boxes)
  let frame = @rig.update_animator(
    a.animator,
    pilot,
    focus,
    if a.game.phase == "playing" {
      dt
    } else {
      0.0
    },
    a.game.attack_age,
  )
  if a.game.phase == "playing" {
    @sim.advance_combat(a.game, a.input, { ..frame, eye: a.eye, }, dt)
    @sim.finish_mission(a.game, dt)
  }
  if a.game.shots > shots {
    play_sound("rifle")
  }
  if a.game.hits > hits {
    play_sound("hit")
  }
  if a.game.kills > kills {
    play_sound("explosion")
  }
  if a.game.enemy_hits > enemy_hits {
    play_sound("hit")
  }
  if phase == "playing" && a.game.phase != "playing" {
    pause_audio()
    play_sound(if a.game.phase == "won" { "confirm" } else { "cancel" })
  }
  let vp = camera(a).view_projection_matrix()
  let targets : Array[Json] = a.game.units.map(fn(e) {
    let p = e.position.add(@sim.vec(0.0, 3.8, 0.0))
    let v = vp.mul_vec4(@math3d.Vec4::new(p.x, p.y, p.z, 1.0))
    {
      "id": e.id,
      "distance": p.sub(a.eye).length(),
      "x": v.x / v.w,
      "y": v.y / v.w,
      "visible": v.w > 0.0 &&
      v.z / v.w >= 0.0 &&
      v.z / v.w <= 1.0 &&
      @sim.visible(a.eye, p, a.game.stage.solids),
    }
  })
  let projection : Json = { "targets": targets }
  publish(@sim.snapshot(a.game), projection.stringify())
}

///|
pub fn renderer_info() -> String {
  let j : Json = {
    "backend": "kagura-webgpu",
    "audioClips": sounds.length(),
    "audioVolumes": {
      "music": music_volume.val,
      "effects": effects_volume.val,
      "muted": muted.val,
    },
    "images": @hooks.source_image_cache_count(),
    "strixBatches": if app.val is Some(a) {
      a.strix.batches.length()
    } else {
      0
    },
    "bastionBatches": if app.val is Some(a) {
      a.bastion.batches.length()
    } else {
      0
    },
  }
  j.stringify()
}
