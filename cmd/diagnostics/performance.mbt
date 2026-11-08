///|
fn field(value : Json, key : String) -> Json {
  match value {
    Object(fields) => fields.get(key).unwrap_or(Json::null())
    _ => Json::null()
  }
}

///|
fn array(value : Json) -> Array[Json] {
  match value {
    Array(values) => values
    _ => []
  }
}

///|
fn number(value : Json) -> Double {
  match value {
    Number(value, ..) => value
    _ => 0.0
  }
}

///|
fn text(value : Json, fallback~ : String = "") -> String {
  match value {
    String(value) => value
    _ => fallback
  }
}

///|
fn round2(value : Double) -> Double {
  (value * 100.0 + 0.5).floor() / 100.0
}

///|
fn summarize_numeric(values : Array[Double]) -> Json {
  let p25 = @statistics.percentile(values, 0.25)
  let p75 = @statistics.percentile(values, 0.75)
  let fence = (p75 - p25) * 1.5
  let upper = p75 + fence
  let lower = p25 - fence
  let mut total = 0.0
  let mut trimmed_total = 0.0
  let mut trimmed_count = 0
  let mut minimum = if values.is_empty() { 0.0 } else { values[0] }
  let mut maximum = minimum
  for value in values {
    total += value
    minimum = minimum.min(value)
    maximum = maximum.max(value)
    if value >= lower && value <= upper {
      trimmed_total += value
      trimmed_count += 1
    }
  }
  let mean = if values.is_empty() {
    0.0
  } else {
    total / values.length().to_double()
  }
  {
    "mean": Json(round2(mean)),
    "min": Json(round2(minimum)),
    "p25": Json(round2(p25)),
    "p50": Json(round2(@statistics.percentile(values, 0.5))),
    "p75": Json(round2(p75)),
    "p95": Json(round2(@statistics.percentile(values, 0.95))),
    "max": Json(round2(maximum)),
    "trimmedMean": Json(
      round2(
        if trimmed_count > 0 {
          trimmed_total / trimmed_count.to_double()
        } else {
          mean
        },
      ),
    ),
    "outlierCount": Json(values.length() - trimmed_count),
    "upperFence": Json(round2(upper)),
  }
}

///|
fn map_metrics(input : Json) -> Json {
  let result : Map[String, Json] = Map([])
  for metric in array(input) {
    if field(metric, "name") is String(name) {
      result[name] = field(metric, "value")
    }
  }
  Json(result)
}

///|
fn cpu_per_frame(input : Json) -> Json {
  let before = field(input, "before")
  let after = field(input, "after")
  let frames = number(field(input, "frames"))
  let output : Map[String, Json] = Map([])
  for
    key in [
      "TaskDuration", "ScriptDuration", "LayoutDuration", "RecalcStyleDuration",
    ] {
    output[key] = match (field(before, key), field(after, key)) {
      (Number(a, ..), Number(b, ..)) => Json((b - a).max(0.0) * 1000.0 / frames)
      _ => Json::null()
    }
  }
  Json(output)
}

///|
fn summarize_browser(input : Json) -> Json {
  let before = field(input, "before")
  let after = field(input, "after")
  let result : Map[String, Json] = Map([])
  for
    (key, output) in [
      ("TaskDuration", "taskDurationMs"),
      ("ScriptDuration", "scriptDurationMs"),
      ("LayoutDuration", "layoutDurationMs"),
      ("RecalcStyleDuration", "recalcStyleDurationMs"),
    ] {
    result[output] = Json(
      round2(
        (number(field(after, key)) - number(field(before, key))).max(0.0) *
        1000.0,
      ),
    )
  }
  for
    (key, output) in [
      ("LayoutCount", "layoutCountDelta"),
      ("RecalcStyleCount", "recalcStyleCountDelta"),
    ] {
    result[output] = Json(
      (number(field(after, key)) - number(field(before, key)) + 0.5)
      .floor()
      .max(0.0),
    )
  }
  for
    (key, output) in [
      ("JSHeapUsedSize", "jsHeapUsedSizeMb"),
      ("JSHeapTotalSize", "jsHeapTotalSizeMb"),
    ] {
    result[output] = Json(round2(number(field(after, key)) / 1048576.0))
  }
  for
    (key, output) in [
      ("Nodes", "nodes"),
      ("Documents", "documents"),
      ("Frames", "frames"),
    ] {
    result[output] = Json((number(field(after, key)) + 0.5).floor())
  }
  Json(result)
}

///|
/// Preserve first-seen order on ties, matching stable JS sorting.
fn ranked(rows : Array[Json], metric : String, limit : Int32) -> Json {
  let indices = [ for i in 0..<rows.length() => i ]
  indices.sort_by(fn(a, b) {
    let order = number(field(rows[b], metric)).compare(
      number(field(rows[a], metric)),
    )
    if order == 0 {
      a.compare(b)
    } else {
      order
    }
  })
  Json([ for i in 0..<indices.length().min(limit) => rows[indices[i]] ])
}

///|
fn summarize_cpu(profile : Json) -> Json {
  let times : Map[String, Double] = Map([])
  let samples = array(field(profile, "samples"))
  let deltas = array(field(profile, "timeDeltas"))
  for i in 0..<samples.length() {
    let id = samples[i].stringify()
    let delta = if i < deltas.length() { number(deltas[i]) } else { 0.0 }
    times[id] = times.get(id).unwrap_or(0.0) + delta
  }
  let rows : Array[Json] = []
  let positions : Map[String, Int32] = Map([])
  for node in array(field(profile, "nodes")) {
    let frame = field(node, "callFrame")
    let name = text(field(frame, "functionName"))
    let url = text(field(frame, "url"))
    let line = number(field(frame, "lineNumber")) + 1.0
    let key = Json([Json(url), Json(line), Json(name)]).stringify()
    let index = match positions.get(key) {
      Some(index) => index
      None => {
        let index = rows.length()
        positions[key] = index
        rows.push(Json::null())
        index
      }
    }
    let duration = times.get(field(node, "id").stringify()).unwrap_or(0.0) /
      1000.0
    rows[index] = {
      "name": Json(name),
      "url": Json(url),
      "line": Json(line),
      "selfMs": Json(number(field(rows[index], "selfMs")) + duration),
    }
  }
  ranked(rows, "selfMs", 25)
}

///|
priv struct TraceTotal {
  name : String
  process_name : String
  thread_name : String
  mut total_ms : Double
  mut count : Int32
}

///|
fn add_total(
  rows : Array[TraceTotal],
  indices : Map[String, Int32],
  key : String,
  duration : Double,
  process_name~ : String = "",
  thread_name~ : String = "",
) -> Unit {
  if indices.get(key) is Some(index) {
    rows[index].total_ms += duration
    rows[index].count += 1
  } else {
    indices[key] = rows.length()
    rows.push({
      name: key,
      process_name,
      thread_name,
      total_ms: duration,
      count: 1,
    })
  }
}

///|
fn summarize_trace(input : Json) -> Json {
  let events = array(input)
  let processes : Map[String, String] = Map([])
  let threads : Map[String, String] = Map([])
  for event in events {
    if field(event, "ph") != "M" {
      continue
    }
    let pid = field(event, "pid")
    let tid = field(event, "tid")
    if field(event, "name") == "process_name" && pid != Json::null() {
      processes[pid.stringify()] = text(
        field(field(event, "args"), "name"),
        fallback="pid:" + pid.stringify(),
      )
    }
    if field(event, "name") == "thread_name" &&
      pid != Json::null() &&
      tid != Json::null() {
      threads[pid.stringify() + ":" + tid.stringify()] = text(
        field(field(event, "args"), "name"),
        fallback="tid:" + tid.stringify(),
      )
    }
  }
  let totals : Array[TraceTotal] = []
  let thread_totals : Array[TraceTotal] = []
  let process_totals : Array[TraceTotal] = []
  let total_indices : Map[String, Int32] = Map([])
  let thread_indices : Map[String, Int32] = Map([])
  let process_indices : Map[String, Int32] = Map([])
  let mut count = 0
  for event in events {
    if field(event, "ph") != "X" {
      continue
    }
    guard field(event, "dur") is Number(duration, ..) else { continue }
    let duration = duration / 1000.0
    count += 1
    add_total(totals, total_indices, text(field(event, "name")), duration)
    let pid = field(event, "pid")
    let tid = field(event, "tid")
    if pid != Json::null() && tid != Json::null() {
      let process_name = processes
        .get(pid.stringify())
        .unwrap_or("pid:" + pid.stringify())
      let thread_name = threads
        .get(pid.stringify() + ":" + tid.stringify())
        .unwrap_or("tid:" + tid.stringify())
      add_total(
        thread_totals,
        thread_indices,
        process_name + ":" + thread_name,
        duration,
        process_name~,
        thread_name~,
      )
      add_total(process_totals, process_indices, process_name, duration)
    }
  }
  let events = totals.map(fn(row) -> Json {
    {
      "name": Json(row.name),
      "totalMs": Json(round2(row.total_ms)),
      "count": Json(row.count),
    }
  })
  let threads = thread_totals.map(fn(row) -> Json {
    {
      "label": Json(row.name),
      "processName": Json(row.process_name),
      "threadName": Json(row.thread_name),
      "totalMs": Json(round2(row.total_ms)),
      "count": Json(row.count),
    }
  })
  let processes = process_totals.map(fn(row) -> Json {
    {
      "label": Json(row.name),
      "totalMs": Json(round2(row.total_ms)),
      "count": Json(row.count),
    }
  })
  {
    "totalEvents": Json(array(input).length()),
    "completeEventCount": Json(count),
    "topDurationEvents": ranked(events, "totalMs", 12),
    "topThreadGroups": ranked(threads, "totalMs", 12),
    "topProcessGroups": ranked(processes, "totalMs", 12),
  }
}

///|
/// Versioned JSON boundary shared by Node scripts and the installed CLI host.
pub fn analyze_performance(operation : String, source : String) -> String {
  let input = @json.parse(source) catch {
    _ => return "{\"ok\":false,\"error\":\"Invalid JSON\"}"
  }
  let result = match operation {
    "numeric" => {
      let values : Array[Double] = []
      guard input is Array(entries) else {
        return "{\"ok\":false,\"error\":\"Expected numeric samples\"}"
      }
      for value in entries {
        guard value is Number(value, ..) else {
          return "{\"ok\":false,\"error\":\"Samples must be finite numbers\"}"
        }
        values.push(value)
      }
      summarize_numeric(values)
    }
    "metrics" => map_metrics(input)
    "browser" => summarize_browser(input)
    "cpu" => summarize_cpu(input)
    "trace" => summarize_trace(input)
    "perFrame" => {
      let frames = number(field(input, "frames"))
      if frames <= 0.0 || frames.floor() != frames {
        return "{\"ok\":false,\"error\":\"No rendered frames\"}"
      }
      cpu_per_frame(input)
    }
    _ => return "{\"ok\":false,\"error\":\"Unknown performance operation\"}"
  }
  ({ "ok": true, "value": result } : Json).stringify()
}
