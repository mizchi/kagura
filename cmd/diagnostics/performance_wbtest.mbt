///|
test "distribution excludes IQR outliers while retaining the full mean" {
  let summary = summarize_numeric([8.1, 8.4, 8.5, 8.7, 9.0, 205.2])
  assert_eq(field(summary, "p50"), Json(8.7))
  assert_eq(field(summary, "trimmedMean"), Json(8.54))
  assert_eq(field(summary, "outlierCount"), Json(1))
  assert_eq(field(summarize_numeric([]), "mean"), Json(0.0))
}

///|
test "CPU accounting preserves absent counters and merges call sites" {
  let result = cpu_per_frame({
    "before": { "TaskDuration": 1 },
    "after": { "TaskDuration": 2 },
    "frames": 2,
  })
  assert_eq(field(result, "TaskDuration"), Json(500.0))
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
  assert_eq(field(rows[0], "selfMs"), Json(0.4))
  assert_eq(field(rows[0], "line"), Json(13.0))
}
