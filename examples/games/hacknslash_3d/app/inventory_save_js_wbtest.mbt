///|
test "equipment affixes survive inventory saves with elemental and tagged bonuses" {
  let affix : @game.Affix = {
    name: "Ash",
    atk: 3,
    def: 2,
    hp: 5,
    str_bonus: 1,
    int_bonus: 2,
    dex_bonus: 3,
    crit: 0.04,
    life_steal: 0.03,
    speed_bonus: 0.1,
    cooldown_reduction: 0.2,
    str_scaling: 0.3,
    int_scaling: 0.4,
    dex_scaling: 0.5,
    spell_damage_pct: 0.25,
    chain_bonus: 2,
    tag_bonuses: [
      {
        tag: @game.Fire,
        damage_pct: 0.2,
        cooldown_reduction: 0.1,
        extra_targets: 1,
        aoe_radius_pct: 0.3,
        crit_bonus: 0.05,
      },
    ],
  }
  let item = @game.ItemData::{
    ..@game.hunter_equipment_item(@game.Amulet),
    prefix: Some(affix),
  }
  let restored = deserialize_item(serialize_item(item)).unwrap()
  assert_true(restored.slot == @game.Amulet)
  let saved = restored.prefix.unwrap()
  assert_eq(saved.spell_damage_pct, 0.25)
  assert_eq(saved.chain_bonus, 2)
  assert_eq(saved.tag_bonuses.length(), 1)
  assert_true(saved.tag_bonuses[0].tag == @game.Fire)
  assert_eq(saved.tag_bonuses[0].crit_bonus, 0.05)
  assert_eq(saved.int_scaling, 0.4)
}
