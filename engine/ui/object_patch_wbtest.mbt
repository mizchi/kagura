///|
fn patch_fields(value : Json) -> Map[String, Json] {
  match value {
    Object(fields) => fields
    _ => abort("expected object")
  }
}

///|
test "object patches preserve null removal and reset semantics" {
  let publisher = JsonObjectPublisher::new()
  let first : Json = { "hp": 14, "menu": null, "items": ["sword"] }
  let patch = publisher.encode(patch_fields(first)).unwrap()
  let parsed = @json.parse(patch)
  assert_eq(patch_fields(parsed).get("full"), Some(true.to_json()))
  assert_eq(patch_fields(parsed).get("set"), Some(first))
  assert_eq(publisher.encode(patch_fields(first)), None)
  let next : Json = { "hp": 13, "menu": null }
  let delta = @json.parse(publisher.encode(patch_fields(next)).unwrap())
  assert_eq(patch_fields(delta).get("full"), Some(false.to_json()))
  assert_eq(patch_fields(delta).get("set"), Some({ "hp": 13 }))
  assert_eq(patch_fields(delta).get("remove"), Some(["items"]))
  publisher.reset()
  assert_eq(
    patch_fields(@json.parse(publisher.encode(patch_fields(next)).unwrap())).get(
      "full",
    ),
    Some(true.to_json()),
  )
}

///|
test "object publisher owns previous values when caller mutates arrays and objects" {
  let items : Array[Json] = ["sword"]
  let fields : Map[String, Json] = { "items": Json::array(items) }
  let publisher = JsonObjectPublisher::new()
  ignore(publisher.encode(fields))
  items.push("bow")
  let delta = @json.parse(publisher.encode(fields).unwrap())
  assert_eq(patch_fields(delta).get("set"), Some({ "items": ["sword", "bow"] }))
  assert_eq(publisher.encode(fields), None)
}
