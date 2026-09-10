///|
/// Only JSON strings cross the plugin boundary; no compiler-specific object layout leaks.
pub fn manifest() -> String {
  let value : Json = {
    "apiVersion": 1,
    "id": "demo.moonbit",
    "title": "MoonBit tools",
    "tools": [
      {
        "name": "count_nodes",
        "description": "Count nodes in the current authoring scene",
        "effect": "read",
        "inputSchema": {
          "type": "object",
          "properties": {},
          "additionalProperties": false,
        },
        "outputSchema": { "type": "integer", "minimum": 0 },
      },
      {
        "name": "rename_selected",
        "description": "Rename the selected scene node",
        "effect": "transaction",
        "inputSchema": {
          "type": "object",
          "properties": {
            "name": { "type": "string", "minLength": 1, "maxLength": 120 },
          },
          "required": ["name"],
          "additionalProperties": false,
        },
        "outputSchema": { "type": "string" },
      },
    ],
  }
  value.stringify()
}

///|
pub fn invoke(source : String) -> String {
  try {
    let request = @json.parse(source)
    let response : Json = match request {
      {
        "tool": "count_nodes",
        "snapshot": { "document": { "nodes": Array(nodes), .. }, .. },
        ..
      } => { "result": nodes.length() }
      {
        "tool": "rename_selected",
        "arguments": { "name": String(name), .. },
        "snapshot": { "selection": String(id), .. },
        ..
      } =>
        {
          "result": name,
          "commands": [{ "op": "node.rename", "id": id, "name": name }],
        }
      _ => { "result": null }
    }
    response.stringify()
  } catch {
    _ => "{\"result\":null}"
  }
}
