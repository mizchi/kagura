///|
/// `kagura scene3d <operation> <snapshot.json> ...`. The analysis runs in
/// `cmd/inspect3d`; this only validates the command line.
pub(all) struct Scene3DOptions {
  operation : String
  snapshot : String
  paths : Array[String]
  from : Array[Double]?
  direction : Array[Double]?
  allow : Array[String]
  /// How deep an overlap must be to count (check, overlaps); None = 0.01.
  tolerance : Double?
  json : Bool
} derive(Eq, Debug)

///|
/// `x,y,z` with finite decimal numbers.
fn parse_triple(text : String) -> Array[Double]? {
  let parts = text.split(",").to_array()
  guard parts.length() == 3 else { return None }
  let values = []
  for part in parts {
    let value = @string.parse_double(part) catch { _ => return None }
    if value.is_nan() || value.is_inf() {
      return None
    }
    values.push(value)
  }
  Some(values)
}

///|
fn parse_scene3d_args(args : Array[String]) -> Result[Command, String] {
  let operations = ["check", "distance", "overlaps", "raycast"]
  if args.length() >= 2 && (args[1] == "--help" || args[1] == "-h") {
    return Ok(Help(Some("scene3d")))
  }
  guard args.length() >= 2 && operations.contains(args[1]) else {
    return Err(
      "scene3d needs an operation: check, distance, overlaps or raycast",
    )
  }
  let operation = args[1]
  let positional = []
  let allow = []
  let mut from : Array[Double]? = None
  let mut direction : Array[Double]? = None
  let mut json = false
  let mut tolerance : Double? = None
  let mut index = 2
  while index < args.length() {
    let arg = args[index]
    index += 1
    if arg == "--help" || arg == "-h" {
      return Ok(Help(Some("scene3d")))
    }
    if arg == "--json" {
      json = true
      continue
    }
    if arg == "--tolerance" {
      if operation != "check" && operation != "overlaps" {
        return Err(
          "--tolerance is only supported by scene3d check and overlaps",
        )
      }
      if tolerance is Some(_) {
        return Err("Duplicate option: --tolerance")
      }
      if index >= args.length() {
        return Err("Missing value for --tolerance")
      }
      let value = @string.parse_double(args[index]) catch { _ => -1.0 }
      index += 1
      if value.is_nan() || value.is_inf() || value < 0.0 {
        return Err("--tolerance must be a non-negative number")
      }
      tolerance = Some(value)
      continue
    }
    if arg == "--allow" || arg == "--from" || arg == "--direction" {
      if index >= args.length() || args[index].is_empty() {
        return Err("Missing value for \{arg}")
      }
      let value = args[index]
      index += 1
      match arg {
        "--allow" => {
          if operation != "check" {
            return Err("--allow is only supported by scene3d check")
          }
          allow.push(value)
        }
        _ => {
          if operation != "raycast" {
            return Err("\{arg} is only supported by scene3d raycast")
          }
          guard parse_triple(value) is Some(xyz) else {
            return Err("\{arg} must be x,y,z")
          }
          if arg == "--from" {
            if from is Some(_) {
              return Err("Duplicate option: --from")
            }
            from = Some(xyz)
          } else {
            if direction is Some(_) {
              return Err("Duplicate option: --direction")
            }
            direction = Some(xyz)
          }
        }
      }
      continue
    }
    if arg.has_prefix("--") {
      return Err("Unknown scene3d option: \{arg}")
    }
    positional.push(arg)
  }
  guard !positional.is_empty() else {
    return Err(
      "Specify the snapshot file: kagura scene3d \{operation} <snapshot.json>",
    )
  }
  let snapshot = positional[0]
  let paths = positional[1:].to_owned()
  let expected = if operation == "distance" { 2 } else { 0 }
  if paths.length() != expected {
    return Err(
      if operation == "distance" {
        "scene3d distance takes two node paths"
      } else {
        "scene3d \{operation} takes only the snapshot file"
      },
    )
  }
  if operation == "raycast" && (from is None || direction is None) {
    return Err("scene3d raycast needs --from x,y,z and --direction x,y,z")
  }
  Ok(
    Scene3D({
      operation,
      snapshot,
      paths,
      from,
      direction,
      allow,
      tolerance,
      json,
    }),
  )
}

///|
fn scene3d_request(options : Scene3DOptions) -> Json {
  {
    "ok": true,
    "command": "scene3d",
    "operation": options.operation.to_json(),
    "snapshot": options.snapshot.to_json(),
    "paths": options.paths.to_json(),
    "from": optional_json(options.from),
    "direction": optional_json(options.direction),
    "allow": options.allow.to_json(),
    "tolerance": optional_json(options.tolerance),
    "json": options.json.to_json(),
  }
}
