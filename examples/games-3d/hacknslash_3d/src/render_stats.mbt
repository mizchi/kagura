///|
struct DrawPlayingStats {
  total_commands : Int
  estimated_draw_calls : Int
  total_index_count : Int
  shadow_depth_commands : Int
  shadow_lit_commands : Int
  direct_lit_commands : Int
  instanced_commands : Int
  instanced_instances : Int
  skinned_commands : Int
  ssao_commands : Int
  bloom_commands : Int
  tonemap_commands : Int
  fxaa_commands : Int
  final_output_commands : Int
} derive(Debug)

///|
pub impl Show for DrawPlayingStats with fn output(self, logger) {
  logger.write_object(to_repr(self))
}

///|
fn summarize_draw_playing_commands(
  commands : Array[@gfx.DrawTrianglesCommand],
  state : GameState,
  final_dst : @gfx.ImageHandle,
) -> DrawPlayingStats {
  let mut estimated_draw_calls = 0
  let mut total_index_count = 0
  let mut shadow_depth_commands = 0
  let mut shadow_lit_commands = 0
  let mut direct_lit_commands = 0
  let mut instanced_commands = 0
  let mut instanced_instances = 0
  let mut skinned_commands = 0
  let mut ssao_commands = 0
  let mut bloom_commands = 0
  let mut tonemap_commands = 0
  let mut fxaa_commands = 0
  let mut final_output_commands = 0
  for cmd in commands {
    estimated_draw_calls = estimated_draw_calls +
      @gfx.DrawTrianglesCommand::estimated_draw_call_count(cmd)
    total_index_count = total_index_count +
      @gfx.DrawTrianglesCommand::estimated_total_index_count(cmd)
    if cmd.dst.id == state.shadow_map.id &&
      cmd.shader.id == state.shadow_depth_shader.id {
      shadow_depth_commands = shadow_depth_commands + 1
    }
    if cmd.shader.id == state.shadow_lit_shader.id {
      shadow_lit_commands = shadow_lit_commands + 1
    }
    if cmd.dst.id == state.pipeline.scene_target.id &&
      (
        cmd.shader.id == state.shader3d.id ||
        cmd.shader.id == state.shader3d_colored.id
      ) {
      direct_lit_commands = direct_lit_commands + 1
    }
    if cmd.shader.id == state.shader3d_instanced.id {
      instanced_commands = instanced_commands + 1
      instanced_instances = instanced_instances + cmd.instance_count
    }
    if cmd.shader.id == state.shader3d_instanced_monochrome.id {
      instanced_commands = instanced_commands + 1
      instanced_instances = instanced_instances + cmd.instance_count
    }
    if cmd.shader.id == state.shader3d_skinned_instanced.id {
      instanced_commands = instanced_commands + 1
      instanced_instances = instanced_instances + cmd.instance_count
    }
    if cmd.shader.id == state.shader3d_skinned_instanced_monochrome.id {
      instanced_commands = instanced_commands + 1
      instanced_instances = instanced_instances + cmd.instance_count
    }
    if cmd.shader.id == state.shader3d_skinned.id ||
      cmd.shader.id == state.shader3d_skinned_instanced.id ||
      cmd.shader.id == state.shader3d_skinned_instanced_monochrome.id {
      skinned_commands = skinned_commands + 1
    }
    if cmd.dst.id == state.pipeline.ssao_target.id &&
      cmd.shader.id == state.pipeline.ssao_sh.id {
      ssao_commands = ssao_commands + 1
    }
    if cmd.shader.id == state.pipeline.bloom_threshold_sh.id ||
      cmd.shader.id == state.pipeline.bloom_hblur_sh.id ||
      cmd.shader.id == state.pipeline.bloom_vblur_sh.id ||
      cmd.shader.id == state.pipeline.bloom_composite_sh.id {
      bloom_commands = bloom_commands + 1
    }
    if cmd.shader.id == state.pipeline.tonemap_sh.id {
      tonemap_commands = tonemap_commands + 1
    }
    if cmd.shader.id == state.pipeline.fxaa_sh.id {
      fxaa_commands = fxaa_commands + 1
    }
    if cmd.dst.id == final_dst.id {
      final_output_commands = final_output_commands + 1
    }
  }
  {
    total_commands: commands.length(),
    estimated_draw_calls,
    total_index_count,
    shadow_depth_commands,
    shadow_lit_commands,
    direct_lit_commands,
    instanced_commands,
    instanced_instances,
    skinned_commands,
    ssao_commands,
    bloom_commands,
    tonemap_commands,
    fxaa_commands,
    final_output_commands,
  }
}
