///|
test "equipping each slot changes only its own visible parts and preserves an attack" {
  let actor = CharacterModel::new()
  let equipment = @game.Equipment::new()
  actor.equip_outfit(CharacterOutfit::from_equipment(equipment))
  let base = actor.parts.length()
  actor.trigger_attack()
  actor.update(0.05)
  for
    slot in [
      @game.Armor,
      @game.Helmet,
      @game.Gloves,
      @game.Boots,
      @game.Offhand,
      @game.Accessory,
      @game.Amulet,
    ] {
    let before = actor.outfit.key()
    ignore(
      equipment.equip(@game.hunter_equipment_item(slot, rarity=@game.Rare)),
    )
    actor.equip_outfit(CharacterOutfit::from_equipment(equipment))
    assert_true(actor.outfit.key() != before)
    assert_eq(equipment_appearance_key(equipment), actor.outfit.key())
    assert_true(actor.parts.length() > base)
    assert_eq(actor.anim_state, Attacking)
    assert_eq(actor.action_time, 0.05)
    ignore(equipment.unequip(slot))
    actor.equip_outfit(CharacterOutfit::from_equipment(equipment))
    assert_eq(actor.outfit.key(), before)
    assert_eq(actor.parts.length(), base)
  }
}

///|
test "species heads share the same rig and stay independent of helmet and weapon" {
  let counts : Array[Int] = []
  for species in [Human, Goblin, Kobold, Skeleton] {
    let actor = CharacterModel::new(species~)
    let head = character_head_parts(species)
    assert_true(head.length() > 0)
    let mut vertices = 0
    for part in head {
      vertices += part.skin.vertex_count
      for i in 0..<part.skin.vertex_count {
        assert_eq(part.skin.joint_indices[i * 4], 5)
      }
    }
    counts.push(vertices)
    actor.equip_weapon(@game.Bow)
    actor.equip_outfit(CharacterOutfit::empty())
    actor.trigger_attack()
    actor.update(0.15)
    assert_eq(actor.compute_skinning().length(), 17)
    assert_eq(actor.species, species)
    assert_true(actor.parts.length() >= head.length())
  }
  assert_true(counts[0] != counts[1])
  assert_true(counts[1] != counts[2])
  assert_true(counts[2] != counts[3])
}

///|
test "appearance rebuilds only on change and equipment cache remains bounded" {
  let actor = CharacterModel::new()
  let equipment = @game.Equipment::new()
  actor.equip_outfit(CharacterOutfit::from_equipment(equipment))
  let builds = actor.appearance_builds
  for _ in 0..<100 {
    actor.equip_outfit(CharacterOutfit::from_equipment(equipment))
  }
  assert_eq(actor.appearance_builds, builds)
  for rarity in [@game.Common, @game.Uncommon, @game.Rare, @game.Epic] {
    for
      slot in [
        @game.Armor,
        @game.Helmet,
        @game.Gloves,
        @game.Boots,
        @game.Offhand,
        @game.Accessory,
        @game.Amulet,
      ] {
      ignore(equipment.equip(@game.hunter_equipment_item(slot, rarity~)))
      actor.equip_outfit(CharacterOutfit::from_equipment(equipment))
      assert_true(actor.equipped_cache.length() <= 16)
    }
  }
}

///|
test "a new helmet preserves the exact species head and the other equipped meshes" {
  let actor = CharacterModel::new(species=Kobold)
  let equipment = @game.Equipment::new()
  @game.equip_hunter_starting_clothes(equipment)
  actor.equip_outfit(CharacterOutfit::from_equipment(equipment))
  let unchanged = actor.parts.filter(part => {
    part.name != "slot3_hat" &&
    part.name != "slot3_brass" &&
    part.name != "slot3_leather"
  })
  ignore(
    equipment.equip(
      @game.hunter_equipment_item(@game.Helmet, rarity=@game.Rare),
    ),
  )
  actor.equip_outfit(CharacterOutfit::from_equipment(equipment))
  for old in unchanged {
    let current = actor.parts.filter(part => part.name == old.name)[0]
    assert_eq(current.packed, old.packed)
    assert_eq(current.mesh.indices, old.mesh.indices)
  }
  assert_true(actor.parts.any(part => part.name == "slot3_shell"))
  assert_false(actor.parts.any(part => part.name == "slot3_hat"))
}

///|
test "the equipped shield stows on the back and every guard style binds to the left hand" {
  for style in [Worn, Leather, Plate, Occult] {
    for part in character_gear_parts(@game.Offhand, style) {
      assert_true(is_stowed_shield(part))
      for i in 0..<part.skin.vertex_count {
        assert_eq(part.skin.joint_indices[i * 4], 1)
      }
    }
    for part in character_guard_parts(style) {
      for i in 0..<part.skin.vertex_count {
        assert_eq(part.skin.joint_indices[i * 4], 7)
      }
    }
  }
}
