///|
pub fn definition() -> @scene_flow.Definition {
  let project = @scenes.project() catch { error => abort(error.to_string()) }
  project.flow_definition()
}
///|
pub fn definition_json() -> String {
  definition().to_json().stringify()
}
