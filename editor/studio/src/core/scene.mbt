///|
priv struct SceneBinding {
  node : String
  component : String
  properties : Json
} derive(FromJson, ToJson)

///|
priv struct GameSceneBindings {
  game : String
  bindings : Array[SceneBinding]
} derive(FromJson, ToJson)

///|
/// Shared node references cascade with generic deletion. Other game data stays opaque.
fn remove_scene_bindings(resource : Resource, removed : Map[String, Bool]) -> Resource {
  if resource.id != "kagura.scene" || resource.kind != "kagura.scene" || resource.version != 1 {
    return resource
  }
  try {
    keys(resource.data, ["game", "bindings"])
    let data : GameSceneBindings = @json.from_json(resource.data)
    let values : Array[Json] = @json.from_json(field(resource.data, "bindings"))
    for value in values { keys(value, ["node", "component", "properties"]) }
    let data = { ..data, bindings: data.bindings.filter(fn(binding) { !removed.contains(binding.node) }) }
    { ..resource, data: ToJson::to_json(data) }
  } catch {
    // Preserve malformed/unknown data so it can be repaired or undone without loss.
    _ => resource
  }
}
