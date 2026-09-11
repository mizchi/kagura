///|
/// Both standalone and Studio consume the same MoonBit-authored layout.
pub fn layout() -> @scene2d.Document raise {
  for resource in training().resources {
    if resource.id == "kagura.scene2d" {
      if resource.kind != "kagura.scene2d" || resource.version != 1 { fail("Unsupported 2D scene version") }
      return @json.from_json(resource.data)
    }
  }
  fail("Missing 2D scene")
}

///|
pub fn document_json(_id : String) -> String {
  training().to_json().stringify()
}
