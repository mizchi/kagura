///|
struct StartingBuildView {
  id : String
  index : Int
  name : String
  description : String
  glyph : String
  weapon : String
  equipment : Array[String]
  skills : Array[String]
} derive(ToJson)
///|
pub extend StartingBuildView with ToJson::{to_json}
///|
fn GameState::starting_build_views(
  self : GameState,
) -> Array[StartingBuildView] {
  @game.selectable_archetypes().mapi((index, archetype) => {
    let preset = @game.default_hunter_preset(archetype).profile()
    StartingBuildView::{
      id: archetype.to_string(),
      index,
      name: archetype.build_name(),
      description: archetype.build_description(),
      glyph: archetype.build_glyph(),
      weapon: preset.weapon.profile().name,
      equipment: archetype
      .starting_equipment()
      .filter(item => item.slot != @game.Weapon)
      .map(item => item.name),
      skills: preset.keys.map(key => self.hunter_action_view(key).name),
    }
  })
}
