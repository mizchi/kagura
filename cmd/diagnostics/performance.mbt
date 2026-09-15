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
fn text(value : Json, fallback? : String = "") -> String {
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
    "mean": round2(mean).to_json(),
    "min": round2(minimum).to_json(),
    "p25": round2(p25).to_json(),
    "p50": round2(@statistics.percentile(values, 0.5)).to_json(),
    "p75": round2(p75).to_json(),
    "p95": round2(@statistics.percentile(values, 0.95)).to_json(),
    "max": round2(maximum).to_json(),
    "trimmedMean": round2(
      if trimmed_count > 0 {
        trimmed_total / trimmed_count.to_double()
      } else {
        mean
      },
    ).to_json(),
    "outlierCount": (values.length() - trimmed_count).to_json(),
    "upperFence": round2(upper).to_json(),
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
  result.to_json()
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
      (Number(a, ..), Number(b, ..)) =>
        ((b - a).max(0.0) * 1000.0 / frames).to_json()
      _ => Json::null()
    }
  }
  output.to_json()
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
    result[output] = round2(
      (number(field(after, key)) - number(field(before, key))).max(0.0) * 1000.0,
    ).to_json()
  }
  for
    (key, output) in [
      ("LayoutCount", "layoutCountDelta"),
      ("RecalcStyleCount", "recalcStyleCountDelta"),
    ] {
    result[output] = (number(field(after, key)) -
      number(field(before, key)) +
      0.5)
      .floor()
      .max(0.0)
      .to_json()
  }
  for
    (key, output) in [
      ("JSHeapUsedSize", "jsHeapUsedSizeMb"),
      ("JSHeapTotalSize", "jsHeapTotalSizeMb"),
    ] {
    result[output] = round2(number(field(after, key)) / 1048576.0).to_json()
  }
  for
    (key, output) in [
      ("Nodes", "nodes"),
      ("Documents", "documents"),
      ("Frames", "frames"),
    ] {
    result[output] = (number(field(after, key)) + 0.5).floor().to_json()
  }
  result.to_json()
}

///|
/// Preserve first-seen order on ties, matching stable JS sorting.
fn ranked(rows : Array[Json], metric : String, limit : Int) -> Json {
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
  [ for i in 0..<indices.length().min(limit) => rows[indices[i]] ].to_json()
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
  let positions : Map[String, Int] = Map([])
  for node in array(field(profile, "nodes")) {
    let frame = field(node, "callFrame")
    let name = text(field(frame, "functionName"))
    let url = text(field(frame, "url"))
    let line = number(field(frame, "lineNumber")) + 1.0
    let key = [url.to_json(), line.to_json(), name.to_json()]
      .to_json()
      .stringify()
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
      "name": name.to_json(),
      "url": url.to_json(),
      "line": line.to_json(),
      "selfMs": (number(field(rows[index], "selfMs")) + duration).to_json(),
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
  mut count : Int
}

///|
fn add_total(
  rows : Array[TraceTotal],
  indices : Map[String, Int],
  key : String,
  duration : Double,
  process_name? : String = "",
  thread_name? : String = "",
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
  let total_indices : Map[String, Int] = Map([])
  let thread_indices : Map[String, Int] = Map([])
  let process_indices : Map[String, Int] = Map([])
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
      "name": row.name.to_json(),
      "totalMs": round2(row.total_ms).to_json(),
      "count": row.count.to_json(),
    }
  })
  let threads = thread_totals.map(fn(row) -> Json {
    {
      "label": row.name.to_json(),
      "processName": row.process_name.to_json(),
      "threadName": row.thread_name.to_json(),
      "totalMs": round2(row.total_ms).to_json(),
      "count": row.count.to_json(),
    }
  })
  let processes = process_totals.map(fn(row) -> Json {
    {
      "label": row.name.to_json(),
      "totalMs": round2(row.total_ms).to_json(),
      "count": row.count.to_json(),
    }
  })
  {
    "totalEvents": array(input).length().to_json(),
    "completeEventCount": count.to_json(),
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
