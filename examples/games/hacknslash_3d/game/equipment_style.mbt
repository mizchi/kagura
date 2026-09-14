///|
pub(all) enum EquipmentStyle {
  WornGear
  LeatherGear
  PlateGear
  OccultGear
} derive(Eq, Debug)

///|
pub fn EquipmentStyle::index(self : EquipmentStyle) -> Int {
  match self {
    WornGear => 0
    LeatherGear => 1
    PlateGear => 2
    OccultGear => 3
  }
}

///|
/// Icons 60..91 identify common starter clothes by style and equipment slot.
/// Legacy item icons continue to derive their appearance from rarity.
pub fn ItemData::equipment_style(self : ItemData) -> EquipmentStyle {
  if self.slot != Weapon && self.icon_id >= 60 && self.icon_id < 92 {
    return [WornGear, LeatherGear, PlateGear, OccultGear][(self.icon_id - 60) /
      8]
  }
  match self.rarity {
    Common => WornGear
    Uncommon => LeatherGear
    Rare => PlateGear
    Epic => OccultGear
  }
}
