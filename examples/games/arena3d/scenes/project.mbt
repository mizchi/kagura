///| Game-owned bootstrap: handwritten MoonBit may compose declarations here.
pub fn project() -> @scene_data.Project raise {
  { entry: "training", scenes: [
    { id: "training", data: training().compile_entities("arena3d") },
    { id: "second", data: second().compile_entities("arena3d") },
  ] }
}

///| Data interchange export for tools.
pub fn document_json(id : String) -> String {
  let document = match id {
    "training" => training()
    "second" => second()
    _ => abort("Unknown scene ID")
  }
  document.to_json().stringify()
}
