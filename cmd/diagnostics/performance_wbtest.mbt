///|
test "distribution excludes IQR outliers while retaining the full mean" {
  let summary = summarize_numeric([8.1, 8.4, 8.5, 8.7, 9.0, 205.2])
  assert_eq(field(summary, "p50"), 8.7.to_json())
  assert_eq(field(summary, "trimmedMean"), 8.54.to_json())
  assert_eq(field(summary, "outlierCount"), (1).to_json())
  assert_eq(field(summarize_numeric([]), "mean"), 0.0.to_json())
}

///|
test "CPU accounting preserves absent counters and merges call sites" {
  let result = cpu_per_frame({
    "before": { "TaskDuration": 1 },
    "after": { "TaskDuration": 2 },
    "frames": 2,
  })
  assert_eq(field(result, "TaskDuration"), 500.0.to_json())
  assert_eq(field(result, "ScriptDuration"), Json::null())
  let profile : Json = {
    "nodes": [
      {
        "id": 1,
        "callFrame": {
          "functionName": "upload",
          "url": "gfx.js",
          "lineNumber": 12,
        },
      },
      {
        "id": 2,
        "callFrame": {
          "functionName": "upload",
          "url": "gfx.js",
          "lineNumber": 12,
        },
      },
    ],
    "samples": [1, 2],
    "timeDeltas": [100, 300],
  }
  let rows = array(summarize_cpu(profile))
  assert_eq(rows.length(), 1)
  assert_eq(field(rows[0], "selfMs"), 0.4.to_json())
  assert_eq(field(rows[0], "line"), 13.0.to_json())
}
