///|
fn inspect(definition : @scene_flow.Definition) -> Json raise {
  if definition.scenes.length() > 256 || definition.transitions.length() > 2048 {
    fail("Scene flow exceeds 256 scenes / 2048 transitions")
  }
  let labels = [definition.entry, ..definition.scenes, ..definition.terminal]
  for edge in definition.transitions {
    labels.push(edge.from)
    labels.push(edge.to)
    labels.push(edge.event)
  }
  if labels.any(s => s.length() > 512) {
    fail("Scene flow labels exceed 512 characters")
  }
  {
    "ok": true,
    "definition": definition.to_json(),
    "report": definition.analyze().to_json(),
    "mermaid": definition.to_mermaid(),
  }
}

///|
pub fn inspect_json(source : String) -> String {
  let result : Json = try {
    if source.length() > 4 * 1024 * 1024 {
      fail("Scene flow exceeds 4 MiB")
    }
    inspect(@json.from_json(@json.parse(source)))
  } catch {
    error => { "ok": false, "error": error.to_string() }
  }
  result.stringify()
}

///|
#derive(FromJson)
struct SceneDocument {
  id : String
  data : @scene_document.Document
}

///|
#derive(FromJson)
struct Documents {
  entry : String
  game : String
  scenes : Array[SceneDocument]
}

///|
pub extend SceneDocument with @moonbitlang/core/json.FromJson::{from_json}

///|
pub extend Documents with @moonbitlang/core/json.FromJson::{from_json}

///|
/// Use the game's compiler and portal projection; the browser has no graph rules.
pub fn inspect_documents_json(source : String) -> String {
  let result : Json = try {
    if source.length() > 4 * 1024 * 1024 {
      fail("Scene project exceeds 4 MiB")
    }
    let documents : Documents = @json.from_json(@json.parse(source))
    let project : @scene_data.Project = {
      entry: documents.entry,
      scenes: documents.scenes.map(s => {
        id: s.id,
        data: s.data.compile_entities(documents.game),
      }),
    }
    inspect(project.flow_definition())
  } catch {
    error => { "ok": false, "error": error.to_string() }
  }
  result.stringify()
}
