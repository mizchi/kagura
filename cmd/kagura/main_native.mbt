///|
#borrow(script, payload)
extern "C" fn launch_node(script : Bytes, payload : Bytes) -> Unit = "kagura_launch_node"

///|
fn main {
  let raw = @env.args()
  let args = [ for i in 1..<raw.length() => raw[i] ]
  if parse_args(args) is Ok(Help(_)) {
    println(help_text())
    return
  }
  let files = match parse_args(args) {
    Ok(NewWeb(directory)) => {
      let name = project_name(directory, @env.current_dir().unwrap_or("game"))
      @json.parse(scaffold_files(name)) catch {
        _ => Json::null()
      }
    }
    _ => Json::null()
  }
  let request = @json.parse(parse_cli(args)) catch { _ => Json::null() }
  let payload : Json = {
    "request": request,
    "files": files,
    "runtime": if parse_args(args) is Ok(NewWeb(_)) {
      runtime_payload.to_json()
    } else {
      Json::null()
    },
  }
  launch_node(@utf8.encode(node_host), @utf8.encode(payload.stringify()))
}
