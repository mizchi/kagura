///|
fn float3(j : Json?, what : String) -> @math3d.Vec3 raise {
  json_vec(j, what)
}

///|
fn vec_out(v : @math3d.Vec3) -> Json {
  [v.x.to_json(), v.y.to_json(), v.z.to_json()]
}

///|
/// An `--allow` rule: `kind` or `kind@path`. A path also covers what is below it.
fn allow_matches(rule : String, finding : Scene3DFinding) -> Bool raise {
  let (kind, path) = match rule.find("@") {
    Some(i) =>
      (
        rule.unsafe_substring(start=0, end=i),
        Some(rule.unsafe_substring(start=i + 1, end=rule.length())),
      )
    None => (rule, None)
  }
  guard scene3d_finding_kinds.contains(kind) else {
    raise Scene3DSnapshotError("unknown finding kind in allow rule: \{rule}")
  }
  finding.kind == kind &&
  (match path {
    None => true
    Some(p) => finding.paths.iter().any(q => q == p || q.has_prefix(p + "/"))
  })
}

///|
/// JSON entry point for tools (the `kagura scene3d` CLI): runs one operation
/// on a snapshot document.
///
/// `tolerance` (default 0.01) is how deep an overlap must be to count, for
/// `check` and `overlaps`.
/// - `{"operation": "check", "allow": ["overlap@world/door", ...]}` ->
///   `{"findings": [{kind, paths, message, allowed}], "unused_allow": [...], "failed": bool}`.
///   `failed` is true when a finding is not allowed or an allow rule matched
///   nothing (a stale exemption is itself a defect).
/// - `{"operation": "distance", "paths": [a, b]}` ->
///   `{"a", "b", "distance", "intersecting", "point_a", "point_b"}`
/// - `{"operation": "overlaps"}` -> `{"pairs": [[a, b], ...]}`
/// - `{"operation": "raycast", "from": [x, y, z], "direction": [x, y, z]}` ->
///   `{"hits": [{"path", "distance"}, ...]}`, nearest first
pub fn query_scene3d_snapshot(request : Json, snapshot : Json) -> Json raise {
  guard request is Object(r) else {
    raise Scene3DSnapshotError("request: expected an object")
  }
  let snap = Scene3DSnapshot::from_json(snapshot)
  let tolerance = match r.get("tolerance") {
    Some(Number(t, ..)) if t >= 0.0 => t
    None | Some(Null) => 0.01
    _ => raise Scene3DSnapshotError("tolerance: expected a non-negative number")
  }
  match r.get("operation") {
    Some(String("check")) => {
      let rules = match r.get("allow") {
        Some(Array(items)) =>
          items.map(item => {
            match item {
              String(s) => s
              _ => raise Scene3DSnapshotError("allow: expected strings")
            }
          })
        None | Some(Null) => []
        _ => raise Scene3DSnapshotError("allow: expected an array")
      }
      let used = rules.map(_ => false)
      let findings = []
      let mut failed = false
      for f in snap.check(contact_tolerance=tolerance) {
        let mut allowed = false
        for i, rule in rules {
          if allow_matches(rule, f) {
            allowed = true
            used[i] = true
          }
        }
        if !allowed {
          failed = true
        }
        findings.push(
          (
            {
              "kind": f.kind.to_json(),
              "paths": f.paths.to_json(),
              "message": f.message.to_json(),
              "allowed": allowed.to_json(),
            } : Json),
        )
      }
      let unused = []
      for i, rule in rules {
        if !used[i] {
          // Validate the rule even when nothing was found.
          ignore(
            allow_matches(rule, { kind: "overlap", paths: [], message: "", }),
          )
          unused.push(rule)
          failed = true
        }
      }
      {
        "findings": Json::array(findings),
        "unused_allow": unused.to_json(),
        "failed": failed.to_json(),
      }
    }
    Some(String("distance")) => {
      guard r.get("paths") is Some(Array([String(a), String(b)])) else {
        raise Scene3DSnapshotError("distance: expected paths [a, b]")
      }
      let d = snap.distance(a, b)
      {
        "a": a.to_json(),
        "b": b.to_json(),
        "distance": d.distance.to_json(),
        "intersecting": d.intersecting.to_json(),
        "point_a": vec_out(d.point_a),
        "point_b": vec_out(d.point_b),
      }
    }
    Some(String("overlaps")) =>
      {
        "pairs": Json::array(
          snap
          .overlaps(contact_tolerance=tolerance)
          .map(p => ([p.0.to_json(), p.1.to_json()] : Json)),
        ),
      }
    Some(String("raycast")) => {
      let hits = snap.raycast(
        float3(r.get("from"), "raycast.from"),
        float3(r.get("direction"), "raycast.direction"),
      )
      {
        "hits": Json::array(
          hits.map(h => {
            ({ "path": h.0.to_json(), "distance": h.1.to_json() } : Json)
          }),
        ),
      }
    }
    _ =>
      raise Scene3DSnapshotError(
        "operation: expected check, distance, overlaps or raycast",
      )
  }
}
