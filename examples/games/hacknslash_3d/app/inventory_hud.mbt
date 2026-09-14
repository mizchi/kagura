// Read-only inventory contract. IDs refer to bag indices or -1-body slot index.

///|
struct HunterItemView {
  source : Int
  name : String
  slot : Int
  slot_name : String
  rarity : String
  glyph : String
  width : Int
  height : Int
  cells : Array[(Int, Int)]
  x : Int
  y : Int
  rotated : Bool
  stats : Array[(String, Double)]
} derive(ToJson)

///|
struct HunterEquipmentView {
  id : Int
  label : String
  glyph : String
  item : HunterItemView?
} derive(ToJson)

///|
struct HunterInventoryView {
  width : Int
  height : Int
  used : Int
  items : Array[HunterItemView]
  equipment : Array[HunterEquipmentView]
  atk : Int
  def : Int
  hp : Int
  notice : String
} derive(ToJson)

///|
fn equipment_glyph(slot : @game.EquipSlot) -> String {
  match slot {
    Weapon => "blade"
    Armor => "coat"
    Accessory => "ring"
    Helmet => "hat"
    Gloves => "gloves"
    Boots => "boots"
    Offhand => "shield"
    Amulet => "amulet"
  }
}

///|
fn hunter_item_view(
  item : @game.ItemData,
  source : Int,
  position : @inventory.GridPlacement?,
) -> HunterItemView {
  let (width, height) = item.footprint().size()
  let glyph = match item.motion_weapon() {
    Some(kind) =>
      match kind {
        Cleaver => "blade"
        Spear => "spear"
        Knuckles => "fist"
        Focus => "fire"
        Bow => "bow"
      }
    None => equipment_glyph(item.slot)
  }
  {
    source,
    name: item.display_name(),
    slot: item.slot.index(),
    slot_name: item.slot.label(),
    rarity: rarity_name(item.rarity),
    glyph,
    width,
    height,
    cells: item.footprint().cells(),
    x: match position {
      Some(p) => p.x
      None => -1
    },
    y: match position {
      Some(p) => p.y
      None => -1
    },
    rotated: match position {
      Some(p) => p.rotated
      None => false
    },
    stats: [
      ("攻撃力", item.total_atk().to_double()),
      ("防御力", item.total_def().to_double()),
      ("最大体力", item.total_hp().to_double()),
      ("筋力", item.total_str_bonus().to_double()),
      ("知力", item.total_int_bonus().to_double()),
      ("敏捷", item.total_dex_bonus().to_double()),
      ("会心率 %", item.total_crit() * 100.0),
      ("吸血 %", item.total_life_steal() * 100.0),
      ("移動速度 %", item.total_speed_bonus() * 100.0),
      ("再使用短縮 %", item.total_cooldown_reduction() * 100.0),
    ],
  }
}

///|
fn GameState::hunter_inventory_view(self : GameState) -> HunterInventoryView? {
  if self.world.ui_mode != @game.Inventory {
    return None
  }
  let inv = self.world.inventory
  guard inv.grid is Some(grid) else { return None }
  let items : Array[HunterItemView] = []
  for i, item in inv.items {
    if item is Some(item) {
      items.push(hunter_item_view(item, i, grid.placement(i)))
    }
  }
  Some({
    width: grid.width,
    height: grid.height,
    used: grid.used_cells(),
    items,
    equipment: @game.equipment_slots().map(slot => {
      id: slot.index(),
      label: slot.label(),
      glyph: equipment_glyph(slot),
      item: self.world.equipment
      .item_for_slot(slot)
      .map(item => hunter_item_view(item, -1 - slot.index(), None)),
    }),
    atk: self.world.player_stats.atk,
    def: self.world.player_stats.def,
    hp: self.world.player_stats.max_hp,
    notice: self.inventory_notice,
  })
}

///|
fn GameState::apply_inventory_command(
  self : GameState,
  command : Array[Int],
) -> Bool {
  if command.length() != 5 {
    return false
  }
  let source : @game.InventorySource = if command[0] >= 0 {
    @game.Bag(command[0])
  } else {
    guard @game.equip_slot_from_index(-1 - command[0]) is Some(slot) else {
      return false
    }
    @game.Equipped(slot)
  }
  let target : @game.InventoryTarget = if command[1] == -1 {
    @game.Cell(command[2], command[3], command[4] == 1)
  } else if command[1] == -2 {
    @game.Ground
  } else {
    guard @game.equip_slot_from_index(command[1]) is Some(slot) else {
      return false
    }
    @game.Wear(slot)
  }
  if !self.world.transfer_inventory(source, target) {
    self.inventory_notice = "配置できません。空きマスと装備部位を確認してください。"
    return false
  }
  self.sync_character_equipment()
  self.inventory_notice = if target is @game.Ground {
    "足元に捨てました。一度離れてから戻ると拾えます。"
  } else {
    "装備袋を保存しました"
  }
  self.save_game()
  true
}
