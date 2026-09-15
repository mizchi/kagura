///|
pub(all) struct BrowserOptions {
  url : String
  output : String?
  width : Int
  height : Int
  headed : Bool
  timeout : Int
  samples : Int
  profile_ms : Int
  warmup_ms : Int
} derive(Eq, Debug)

///|
fn bounded_integer(text : String, minimum : Int, maximum : Int) -> Int? {
  if text.is_empty() {
    return None
  }
  let mut value = 0
  for ch in text {
    if ch < '0' || ch > '9' {
      return None
    }
    let digit = ch.to_int() - '0'.to_int()
    if value > (maximum - digit) / 10 {
      return None
    }
    value = value * 10 + digit
    if value > maximum {
      return None
    }
  }
  if value < minimum {
    None
  } else {
    Some(value)
  }
}

///|
fn parse_browser_args(args : Array[String]) -> Result[Command, String] {
  let command = args[0]
  let capture = command == "capture"
  let values : Map[String, String] = Map([])
  let mut url : String? = None
  let mut headed = false
  let mut positional = false
  let mut index = 1
  while index < args.length() {
    let arg = args[index]
    index += 1
    if !positional && (arg == "--help" || arg == "-h") {
      return Ok(Help(Some(command)))
    }
    if !positional && arg == "--" {
      positional = true
      continue
    }
    if !positional && arg == "--headed" {
      if headed {
        return Err("Duplicate option: --headed")
      }
      headed = true
      continue
    }
    if !positional && arg.has_prefix("-") {
      let allowed = arg == "--url" ||
        arg == "--width" ||
        arg == "--height" ||
        arg == "--timeout" ||
        (capture && arg == "--output") ||
        (
          !capture &&
          (
            arg == "--out-dir" ||
            arg == "--samples" ||
            arg == "--profile-ms" ||
            arg == "--warmup-ms"
          )
        )
      if !allowed {
        return Err("Unknown \{command} option: \{arg}")
      }
      if index >= args.length() ||
        args[index].is_empty() ||
        args[index].has_prefix("--") {
        return Err("Missing value for \{arg}")
      }
      if values.contains(arg) {
        return Err("Duplicate option: \{arg}")
      }
      let value = args[index]
      index += 1
      if arg == "--url" {
        if url is Some(_) {
          return Err("Specify one URL")
        }
        url = Some(value)
      }
      values[arg] = value
    } else {
      if url is Some(_) || arg.is_empty() {
        return Err("Specify one URL")
      }
      url = Some(arg)
    }
  }
  let url = url.unwrap_or("http://localhost:8080/")
  if !url.has_prefix("http://") && !url.has_prefix("https://") {
    return Err("URL must use http:// or https://")
  }
  let numbers : Map[String, Int] = Map([])
  for
    (flag, fallback, minimum, maximum) in [
      ("--width", if capture { 1600 } else { 1280 }, 1, 16384),
      ("--height", 900, 1, 16384),
      ("--timeout", 30000, 1, 300000),
      ("--samples", 240, 1, 3600),
      ("--profile-ms", 4000, 1, 60000),
      ("--warmup-ms", 1000, 0, 60000),
    ] {
    let value = match values.get(flag) {
      None => fallback
      Some(text) =>
        match bounded_integer(text, minimum, maximum) {
          Some(value) => value
          None =>
            return Err(
              "\{flag} must be an integer from \{minimum} to \{maximum}",
            )
        }
    }
    numbers[flag] = value
  }
  let options = {
    url,
    output: if capture {
      Some(values.get("--output").unwrap_or("output/game.png"))
    } else {
      values.get("--out-dir")
    },
    width: numbers["--width"],
    height: numbers["--height"],
    headed,
    timeout: numbers["--timeout"],
    samples: numbers["--samples"],
    profile_ms: numbers["--profile-ms"],
    warmup_ms: numbers["--warmup-ms"],
  }
  Ok(if capture { Capture(options) } else { Profile(options) })
}

///|
fn browser_request(command : String, options : BrowserOptions) -> Json {
  {
    "ok": true,
    "command": command.to_json(),
    "url": options.url.to_json(),
    "output": optional_json(options.output),
    "viewport": {
      "width": options.width.to_json(),
      "height": options.height.to_json(),
    },
    "headed": options.headed.to_json(),
    "timeout": options.timeout.to_json(),
    "samples": options.samples.to_json(),
    "profileMs": options.profile_ms.to_json(),
    "warmupMs": options.warmup_ms.to_json(),
  }
}
