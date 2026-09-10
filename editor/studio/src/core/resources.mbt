///|
/// Versioned game-owned JSON. Domain-specific validation belongs to the game's command adapter.
pub(all) struct Resource {
  id : String
  kind : String
  version : Int
  data : Json
} derive(ToJson, FromJson, Eq, Debug)

///|
fn decode_resource(value : Json) -> Resource raise {
  keys(value, ["id", "kind", "version", "data"])
  ignore(integer(field(value, "version")))
  let resource : Resource = @json.from_json(value)
  validate_resources([resource])
  resource
}

///|
fn validate_resources(resources : Array[Resource]) -> Unit raise EditorError {
  require(resources.length() <= 128, "Resource limit is 128")
  let ids : Map[String, Bool] = Map([])
  let mut size = 0
  for resource in resources {
    require(
      valid_id(resource.id) && !ids.contains(resource.id),
      "Invalid or duplicate resource ID",
    )
    ids[resource.id] = true
    require(
      valid_id(resource.kind) && resource.version > 0,
      "Invalid resource kind or version",
    )
    require(resource.data is Object(_), "Resource data must be an object")
    validate_resource_json(resource.data, 0)
    size += resource.data.stringify().length()
  }
  require(size <= 262144, "Resource data exceeds 256K characters")
}

///|
fn validate_resource_json(value : Json, depth : Int) -> Unit raise EditorError {
  require(depth <= 32, "Resource data exceeds nesting limit")
  match value {
    Number(n, ..) =>
      require(
        n >= -1.7976931348623157e308 && n <= 1.7976931348623157e308,
        "Resource numbers must be finite",
      )
    Object(fields) =>
      for _, child in fields {
        validate_resource_json(child, depth + 1)
      }
    Array(items) =>
      for child in items {
        validate_resource_json(child, depth + 1)
      }
    _ => ()
  }
}
