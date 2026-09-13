///|
pub fn equipment_slots() -> Array[EquipSlot] {
  [Weapon, Armor, Accessory, Helmet, Gloves, Boots, Offhand, Amulet]
}

///|
pub fn EquipSlot::index(self : EquipSlot) -> Int {
  match self {
    Weapon => 0
    Armor => 1
    Accessory => 2
    Helmet => 3
    Gloves => 4
    Boots => 5
    Offhand => 6
    Amulet => 7
  }
}

///|
pub fn equip_slot_from_index(index : Int) -> EquipSlot? {
  let slots = equipment_slots()
  if index >= 0 && index < slots.length() {
    Some(slots[index])
  } else {
    None
  }
}

///|
pub fn EquipSlot::label(self : EquipSlot) -> String {
  match self {
    Weapon => "武器"
    Armor => "胴"
    Accessory => "指"
    Helmet => "頭"
    Gloves => "手"
    Boots => "足"
    Offhand => "副手"
    Amulet => "首"
  }
}

///|
pub fn ItemData::motion_weapon(self : ItemData) -> PlayerWeaponKind? {
  if self.slot != Weapon {
    return None
  }
  Some(player_weapon_from_index(self.icon_id - 40).or(Cleaver))
}

///|
pub fn ItemData::footprint(self : ItemData) -> @gameplay2d.GridFootprint {
  if self.slot == Weapon && self.icon_id == 40 {
    return @gameplay2d.GridFootprint::new([(0, 0), (1, 0), (0, 1), (0, 2)]).unwrap()
  }
  let (width, height) = match self.slot {
    Weapon =>
      match self.motion_weapon() {
        Some(Spear) => (1, 4)
        Some(Knuckles) => (2, 1)
        Some(Focus) => (1, 2)
        Some(Bow) => (2, 3)
        _ => (1, 3)
      }
    Armor => (2, 3)
    Helmet | Boots | Offhand => (2, 2)
    Gloves => (2, 1)
    Accessory | Amulet => (1, 1)
  }
  @gameplay2d.GridFootprint::rectangle(width, height).unwrap()
}

///|
pub fn Inventory::new_grid(width : Int, height : Int) -> Inventory {
  let inv = Inventory::new(width.max(0) * height.max(0))
  inv.grid = Some(@gameplay2d.ItemGrid::new(width, height))
  inv
}

///|
pub fn Inventory::clear(self : Inventory) -> Unit {
  for i in 0..<self.capacity {
    self.items[i] = None
  }
  if self.grid is Some(grid) {
    grid.clear()
  }
}

///|
fn Inventory::clone(self : Inventory) -> Inventory {
  {
    items: self.items.copy(),
    capacity: self.capacity,
    grid: self.grid.map(grid => grid.clone()),
  }
}

///|
fn Inventory::free_index(self : Inventory) -> Int? {
  for i in 0..<self.capacity {
    if self.items[i] is None {
      return Some(i)
    }
  }
  None
}

///|
fn Inventory::put_item(
  self : Inventory,
  index : Int,
  item : ItemData,
  preferred : @gameplay2d.GridPlacement?,
) -> Bool {
  if index < 0 || index >= self.capacity || self.items[index] is Some(_) {
    return false
  }
  if self.grid is Some(grid) {
    let shape = item.footprint()
    if preferred is Some(pos) {
      if grid.place(index, shape, pos.x, pos.y, rotated=pos.rotated) {
        self.items[index] = Some(item)
        return true
      }
    }
    for rotated in [false, true] {
      if grid.find_space(shape, rotated~) is Some((x, y)) {
        ignore(grid.place(index, shape, x, y, rotated~))
        self.items[index] = Some(item)
        return true
      }
    }
    return false
  }
  self.items[index] = Some(item)
  true
}

///|
/// Import/repair placement without discarding overflow. Unplaced items can be equipped or moved later.
pub fn Inventory::repack(self : Inventory) -> Unit {
  self.restore_layout([])
}

///|
pub fn Inventory::restore_layout(
  self : Inventory,
  positions : Array[(Int, Int, Bool)?],
) -> Unit {
  if self.grid is Some(grid) {
    grid.clear()
    for i in 0..<self.capacity.min(positions.length()) {
      if self.items[i] is Some(item) {
        if positions[i] is Some((x, y, rotated)) {
          ignore(grid.place(i, item.footprint(), x, y, rotated~))
        }
      }
    }
    for i in 0..<self.capacity {
      if self.items[i] is Some(item) && grid.placement(i) is None {
        self.items[i] = None
        if !self.put_item(i, item, None) {
          self.items[i] = Some(item)
        }
      }
    }
  }
}

///|
pub(all) enum InventorySource {
  Bag(Int)
  Equipped(EquipSlot)
}

///|
pub(all) enum InventoryTarget {
  Cell(Int, Int, Bool)
  Wear(EquipSlot)
  Ground
}

///|
pub fn GameWorld::transfer_inventory(
  self : GameWorld,
  source : InventorySource,
  target : InventoryTarget,
) -> Bool {
  if self.mode != Playing || self.ui_mode != Inventory {
    return false
  }
  self.exchange_inventory(source, target)
}

///|
fn GameWorld::exchange_inventory(
  self : GameWorld,
  source : InventorySource,
  target : InventoryTarget,
) -> Bool {
  let inventory = self.inventory.clone()
  let equipment = self.equipment.clone()
  let position = match source {
    Bag(index) =>
      match inventory.grid {
        Some(grid) => grid.placement(index)
        None => None
      }
    Equipped(_) => None
  }
  let item = match source {
    Bag(index) => inventory.remove(index)
    Equipped(slot) => equipment.unequip(slot)
  }
  let item = match item {
    Some(item) => item
    None => return false
  }
  if item.slot == Weapon &&
    (
      self.hunter_action_locked() ||
      self.weapon_attack is Some(_) ||
      self.player_charge is Some(_) ||
      self.player.dash_timer > 0
    ) {
    return false
  }
  match target {
    Ground => ()
    Wear(slot) => {
      if item.slot != slot {
        return false
      }
      if equipment.equip(item) is Some(previous) {
        let index = match source {
          Bag(index) => Some(index)
          Equipped(_) => inventory.free_index()
        }
        match index {
          Some(index) =>
            if !inventory.put_item(index, previous, position) {
              return false
            }
          None => return false
        }
      }
    }
    Cell(x, y, rotated) => {
      let grid = match inventory.grid {
        Some(grid) => grid
        None => return false
      }
      let overlaps = match grid.overlaps(item.footprint(), x, y, rotated~) {
        Some(ids) => ids
        None => return false
      }
      if overlaps.length() > 1 {
        return false
      }
      let displaced = if overlaps.length() == 1 {
        let index = overlaps[0]
        inventory.remove(index).map(item => (index, item))
      } else {
        None
      }
      let index = match source {
        Bag(index) => index
        Equipped(_) =>
          match inventory.free_index() {
            Some(index) => index
            None => return false
          }
      }
      if !grid.place(index, item.footprint(), x, y, rotated~) {
        return false
      }
      inventory.items[index] = Some(item)
      if displaced is Some((old_index, previous)) {
        match source {
          Bag(_) =>
            if !inventory.put_item(old_index, previous, position) {
              return false
            }
          Equipped(slot) => {
            if previous.slot != slot {
              return false
            }
            ignore(equipment.equip(previous))
          }
        }
      }
    }
  }
  for i in 0..<inventory.capacity {
    self.inventory.items[i] = inventory.items[i]
  }
  self.inventory.grid = inventory.grid
  for slot in equipment_slots() {
    ignore(self.equipment.replace_slot(slot, equipment.item_for_slot(slot)))
  }
  let weapon_changed = match (source, target) {
    (Equipped(Weapon), _) | (_, Wear(Weapon)) => true
    _ => false
  }
  if weapon_changed {
    self.reset_cleaver_combo()
    self.player_weapon = match self.equipment.weapon {
      Some(item) => item.motion_weapon().or(Knuckles)
      None => Knuckles
    }
  }
  self.refresh_player_stats()
  if target is Ground {
    spawn_ground_item(self, self.player.x, self.player.y, Equipment(item))
    // Keep the exact item recoverable, but don't collect it again while standing here.
    self.items[self.items.length() - 1].pickup_blocked = Some(true)
  }
  true
}
