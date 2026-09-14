///|
/// Axis-aligned 2D authoring rectangles. Behavior and component constraints belong to each game.
pub(all) struct Element {
  id : String
  name : String
  kind : String
  x : Double
  y : Double
  width : Double
  height : Double
  color : Int
} derive(FromJson, ToJson)

///|
pub(all) struct Document {
  coordinates : String
  width : Int
  height : Int
  background : Int
  objects : Array[Element]
} derive(FromJson, ToJson)

///|
fn valid_id(value : String) -> Bool {
  value.length() > 0 &&
  value.length() <= 80 &&
  value.iter().take(1).all(c => c >= 'a' && c <= 'z') &&
  value
  .iter()
  .all(c => {
    (c >= 'a' && c <= 'z') ||
    (c >= '0' && c <= '9') ||
    c == '_' ||
    c == '-' ||
    c == '.'
  })
}

///|
pub fn Document::validate(self : Document) -> Unit raise {
  if self.coordinates != "pixels-y-down" ||
    self.width < 1 ||
    self.height < 1 ||
    self.width > 8192 ||
    self.height > 8192 ||
    self.objects.length() > 512 {
    fail("Invalid 2D screen")
  }
  if self.background < 0 || self.background > 0xffffff {
    fail("Invalid background")
  }
  let ids : Array[String] = []
  for o in self.objects {
    if !valid_id(o.id) ||
      ids.contains(o.id) ||
      !valid_id(o.kind) ||
      o.name.trim().is_empty() ||
      o.name.length() > 120 {
      fail("Invalid 2D object")
    }
    ids.push(o.id)
    for value in [o.x, o.y, o.width, o.height] {
      if !(value >= -1000000.0 && value <= 1000000.0) {
        fail("Invalid 2D transform")
      }
    }
    if o.width <= 0.0 || o.height <= 0.0 || o.color < 0 || o.color > 0xffffff {
      fail("Invalid 2D size/color")
    }
  }
}

///|
pub fn Document::element(self : Document, id : String) -> Element raise {
  for object in self.objects {
    if object.id == id {
      return object
    }
  }
  fail("Missing 2D object: " + id)
}
