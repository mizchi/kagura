///|
fn test_item(rarity : @game.ItemRarity, icon_id : Int) -> @game.ItemData {
  {
    name: "Test",
    rarity,
    slot: @game.Weapon,
    atk_bonus: 0,
    def_bonus: 0,
    hp_bonus: 0,
    str_bonus: 0,
    int_bonus: 0,
    dex_bonus: 0,
    str_scaling: 0.0,
    int_scaling: 0.0,
    dex_scaling: 0.0,
    prefix: None,
    suffix: None,
    icon_id,
  }
}

///|
fn test_skill(icon_id : Int) -> @game.SkillNode {
  {
    id: @game.PowerStrike,
    name: "Test Skill",
    max_level: 3,
    level: 0,
    cost: 1,
    icon_id,
    prereqs: [],
    tree_x: 0.5,
    tree_y: 0.5,
    node_size: 0,
    connections: [],
  }
}

///|
fn expect_icon_source(
  atlas : IconAtlas,
  key : @atlas.AssetKey,
) -> @atlas.AtlasDrawSource {
  match @atlas.get_atlas_draw_source(atlas.repo, key) {
    Some(source) => source
    None => panic()
  }
}

///|
test "item_icon_key resolves to packed rarity variant" {
  let atlas = create_icon_atlas(atlas_id=777)
  let item = test_item(@game.Rare, 8)
  let key = item_icon_key(item)
  let source = expect_icon_source(atlas, key)
  let expected = expect_icon_source(
    atlas,
    @atlas.new_asset_key("item_2_" + @game.Rare.color().to_string()),
  )
  assert_eq(source.page_image_id, 777)
  assert_eq(source.u0, expected.u0)
  assert_eq(source.v0, expected.v0)
  assert_eq(source.u1, expected.u1)
  assert_eq(source.v1, expected.v1)
}

///|
test "skill_icon_key normalizes skill icon ids to skill atlas range" {
  let atlas = create_icon_atlas(atlas_id=555)
  let source = expect_icon_source(atlas, skill_icon_key(test_skill(13)))
  let expected = expect_icon_source(atlas, @atlas.new_asset_key("skill_3"))
  assert_eq(source.page_image_id, 555)
  assert_eq(source.u0, expected.u0)
  assert_eq(source.v0, expected.v0)
  assert_eq(source.u1, expected.u1)
  assert_eq(source.v1, expected.v1)
}

///|
test "append_icon_draw_command appends textured quad from icon atlas" {
  let atlas = create_icon_atlas(atlas_id=888)
  let cmds : Array[@gfx.DrawTrianglesCommand] = []
  let appended = append_icon_draw_command(
    cmds,
    atlas,
    @atlas.new_asset_key("skill_4"),
    @gfx.new_image_handle(1, screen_w, screen_h),
    @gfx.new_shader_handle(2, "icon"),
    32.0,
    48.0,
    16.0,
  )
  assert_true(appended)
  assert_eq(cmds.length(), 1)
  let cmd = cmds[0]
  assert_eq(cmd.src_image_ids.length(), 1)
  assert_eq(cmd.src_image_ids[0], 888)
  assert_eq(cmd.indices.length(), 6)
  assert_eq(cmd.vertex_data[0], 32.0)
  assert_eq(cmd.vertex_data[1], 48.0)
  assert_eq(cmd.vertex_data[4], 48.0)
  assert_eq(cmd.vertex_data[5], 48.0)
  assert_eq(cmd.vertex_data[8], 48.0)
  assert_eq(cmd.vertex_data[9], 64.0)
  assert_eq(cmd.vertex_data[12], 32.0)
  assert_eq(cmd.vertex_data[13], 64.0)
}
