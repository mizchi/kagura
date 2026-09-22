///|
/// Editable scene source. Game behavior stays in game-owned code; data is compiled by its adapter.
pub(all) struct Document {
  version : Int
  name : String
  units : String
  up : String
  forward : String
  nodes : Array[Node]
  action : Action
  resources : Array[Resource]
} derive(FromJson, ToJson)

///|
pub extend Document with @moonbitlang/core/json.FromJson::{from_json}

///|
pub extend Document with ToJson::{to_json}

///|
pub(all) struct Node {
  id : String
  name : String
  asset : String
  parent : String
  position : Array[Double]
  rotation : Array[Double]
  scale : Array[Double]
  color : Int
} derive(FromJson, ToJson)

///|
pub extend Node with @moonbitlang/core/json.FromJson::{from_json}

///|
pub extend Node with ToJson::{to_json}

///|
pub(all) struct Action {
  target : String
  duration : Double
  flashDuration : Double
  recoilDuration : Double
  recoilStrength : Double
} derive(FromJson, ToJson)

///|
pub extend Action with @moonbitlang/core/json.FromJson::{from_json}

///|
pub extend Action with ToJson::{to_json}

///|
pub(all) struct Resource {
  id : String
  kind : String
  version : Int
  data : Json
} derive(FromJson, ToJson)

///|
pub extend Resource with @moonbitlang/core/json.FromJson::{from_json}

///|
pub extend Resource with ToJson::{to_json}

///|
struct Binding {
  node : String
  component : String
  properties : Json
} derive(FromJson)

///|
pub extend Binding with @moonbitlang/core/json.FromJson::{from_json}

///|
struct Bindings {
  game : String
  bindings : Array[Binding]
} derive(FromJson)

///|
pub extend Bindings with @moonbitlang/core/json.FromJson::{from_json}

///|
struct Destination {
  target : String
} derive(FromJson)

///|
pub extend Destination with @moonbitlang/core/json.FromJson::{from_json}

///|
/// Compile an editable declaration into the portable runtime recipe used by Arena/FPS.
pub fn Document::compile_entities(
  self : Document,
  game : String,
) -> @scene_data.Definition raise {
  if self.version != 1 ||
    self.units != "meters" ||
    self.up != "Y" ||
    self.forward != "+Z" {
    fail("Unsupported scene coordinates/version")
  }
  let resources = self.resources.filter(r => r.id == "kagura.scene")
  if resources.length() != 1 ||
    resources[0].kind != "kagura.scene" ||
    resources[0].version != 1 {
    fail("Missing game scene bindings")
  }
  let bindings : Bindings = @json.from_json(resources[0].data)
  if bindings.game != game || bindings.bindings.length() != self.nodes.length() {
    fail("Invalid scene bindings")
  }
  let entities : Array[@scene_data.Entity] = []
  for binding in bindings.bindings {
    let nodes = self.nodes.filter(n => n.id == binding.node)
    if nodes.length() != 1 {
      fail("Missing or duplicate scene node")
    }
    let node = nodes[0]
    if node.parent != "" ||
      node.rotation.length() != 3 ||
      node.rotation.any(v => v != 0.0) {
      fail("Use root nodes without rotation")
    }
    let target = if binding.component == "portal" {
      let destination : Destination = @json.from_json(binding.properties)
      destination.target
    } else {
      ""
    }
    entities.push({
      id: node.id,
      kind: binding.component,
      position: node.position,
      scale: node.scale,
      color: node.color,
      target,
    })
  }
  { version: 1, entities, }
}
