///|
/// Pure command contract. Filesystem discovery and process ownership belong to
/// the Node host, so parsing is testable without a compiler, Vite, or a browser.
pub enum Command {
  Help(String?)
  Dev(String?, Int?, String)
  Build(String?, String?)
  Studio(Int?, String)
  NewWeb(String)
} derive(Eq, Debug)

///|
fn known_command(name : String) -> Bool {
  name == "dev" || name == "build" || name == "studio" || name == "new"
}

///|
fn parse_port(value : String) -> Int? {
  if value.is_empty() {
    return None
  }
  let mut port = 0
  for ch in value {
    if ch < '0' || ch > '9' {
      return None
    }
    port = port * 10 + ch.to_int() - '0'.to_int()
    // Bound each step, including inputs too large for an Int.
    if port > 65535 {
      return None
    }
  }
  if port == 0 {
    None
  } else {
    Some(port)
  }
}

///|
pub fn parse_args(args : Array[String]) -> Result[Command, String] {
  if args.is_empty() || args == ["--help"] || args == ["-h"] || args == ["help"] {
    return Ok(Help(None))
  }
  if args.length() == 2 && args[0] == "help" && known_command(args[1]) {
    return Ok(Help(Some(args[1])))
  }
  let command = args[0]
  if !known_command(command) {
    return Err("Unknown command: \{command}")
  }
  let mut project : String? = None
  let mut port : Int? = None
  let mut host : String? = None
  let mut out_dir : String? = None
  let mut positional = false
  let mut web = false
  let mut index = 1
  while index < args.length() {
    let argument = args[index]
    index += 1
    if !positional && (argument == "--help" || argument == "-h") {
      return Ok(Help(Some(command)))
    }
    if !positional && argument == "--" {
      positional = true
      continue
    }
    if !positional && argument.has_prefix("-") {
      if argument == "--web" {
        if command != "new" || web {
          return Err("--web is only supported once by new")
        }
        web = true
        continue
      }
      if command == "new" {
        return Err("Unknown new option: \{argument}")
      }
      if argument != "--port" && argument != "--host" && argument != "--out-dir" {
        return Err("Unknown option: \{argument}")
      }
      if (argument == "--out-dir") != (command == "build") {
        return Err("\{argument} is not supported by \{command}")
      }
      if index >= args.length() ||
        args[index].is_empty() ||
        args[index].has_prefix("--") {
        return Err("Missing value for \{argument}")
      }
      let value = args[index]
      index += 1
      match argument {
        "--port" => {
          if port is Some(_) {
            return Err("Duplicate option: --port")
          }
          port = parse_port(value)
          if port is None {
            return Err("--port must be an integer from 1 to 65535")
          }
        }
        "--host" => {
          if host is Some(_) {
            return Err("Duplicate option: --host")
          }
          host = Some(value)
        }
        _ => {
          if out_dir is Some(_) {
            return Err("Duplicate option: --out-dir")
          }
          out_dir = Some(value)
        }
      }
    } else {
      if command == "studio" {
        return Err("studio does not take a project argument")
      }
      if project is Some(_) || argument.is_empty() {
        return Err("Specify one project")
      }
      project = Some(argument)
    }
  }
  if command == "new" {
    return if web {
      Ok(NewWeb(project.unwrap_or(".")))
    } else {
      Err("Specify a template: kagura new [directory] --web")
    }
  }
  Ok(
    match command {
      "dev" => Dev(project, port, host.unwrap_or("127.0.0.1"))
      "build" => Build(project, out_dir)
      _ => Studio(port, host.unwrap_or("127.0.0.1"))
    },
  )
}

///|
/// JSON is the versionable JS boundary; no MoonBit enum representation leaks.
fn[T : ToJson] optional_json(value : T?) -> Json {
  match value {
    Some(value) => value.to_json()
    None => Json::null()
  }
}

///|
pub fn parse_cli(args : Array[String]) -> String {
  let reply : Json = match parse_args(args) {
    Err(message) => { "ok": false, "error": message.to_json() }
    Ok(Help(command)) =>
      { "ok": true, "command": "help", "topic": optional_json(command) }
    Ok(Dev(project, port, host)) =>
      {
        "ok": true,
        "command": "dev",
        "project": optional_json(project),
        "port": optional_json(port),
        "host": host.to_json(),
      }
    Ok(Build(project, out_dir)) =>
      {
        "ok": true,
        "command": "build",
        "project": optional_json(project),
        "outDir": optional_json(out_dir),
      }
    Ok(Studio(port, host)) =>
      {
        "ok": true,
        "command": "studio",
        "port": optional_json(port),
        "host": host.to_json(),
      }
    Ok(NewWeb(directory)) =>
      { "ok": true, "command": "new", "directory": directory.to_json() }
  }
  reply.stringify()
}

///|
pub fn help_text() -> String {
  let text =
    #|Kagura development tools (Node.js 24+, pnpm, MoonBit)
    #|
    #|Usage:
    #|  kagura new [directory] --web
    #|  kagura dev [project] [--port 8080] [--host 127.0.0.1]
    #|  kagura build [project] [--out-dir directory]
    #|  kagura studio [--port 5190] [--host 127.0.0.1]
    #|  kagura help [new|dev|build|studio]
    #|
    #|project: example name or MoonBit project directory; defaults to the current project.
    #|new --web: generate a Web game in an empty directory (default: current directory).
    #|           Then: pnpm install, kagura dev. Mooncakes dependencies require the new Kagura release.
    #|dev: watch MoonBit sources and serve the game with browser reload.
    #|build: compile a JS release and package a static website in <project>/dist.
    #|       --out-dir is relative to the calling directory.
    #|studio: launch the checkout's editor. Install once: just studio-install.
    #|PORT supplies the server port when --port is omitted. Ctrl+C stops the server and watchers.
    #|
    #|From this checkout: pnpm kagura dev hacknslash_3d, or just kagura studio.
    #|Install: moon install ./cmd/kagura. A checkout can also be linked with pnpm link --global.
    #|Set KAGURA_ROOT for checkout examples and Studio if the installation source was moved.
  text
}
