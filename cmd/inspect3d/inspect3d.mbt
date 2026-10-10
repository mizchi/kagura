///|
/// Reads a number for the human report; queries return plain JSON numbers.
fn num(j : Json) -> String {
  match j {
    Number(x, ..) => {
      let r = (x * 100000.0).round() / 100000.0 + 0.0
      r.to_string()
    }
    _ => j.stringify()
  }
}

///|
fn vec_text(j : Json) -> String {
  match j {
    Array(xs) => "(" + xs.map(num).join(", ") + ")"
    _ => j.stringify()
  }
}

///|
fn report(operation : String, value : Json) -> String {
  match (operation, value) {
    (
      "check",
      Object(
        {
          "findings": Array(findings),
          "unused_allow": Array(unused),
          "failed": failed,
          ..
        }
      ),
    ) => {
      let lines = []
      for f in findings {
        guard f
          is Object(
            {
              "kind": String(kind),
              "message": String(message),
              "allowed": allowed,
              ..
            }
          ) else {
          continue
        }
        let tag = if allowed is True { " (allowed)" } else { "" }
        lines.push("\{kind}\{tag}: \{message}")
      }
      for rule in unused {
        lines.push("unused allow rule: \{rule.stringify()}")
      }
      let open = findings
        .filter(f => f is Object({ "allowed": False, .. }))
        .length()
      lines.push(
        if failed is True {
          "scene3d check: \{open} finding(s), \{unused.length()} unused allow rule(s)"
        } else {
          "scene3d check: ok (\{findings.length()} allowed finding(s))"
        },
      )
      lines.join("\n")
    }
    (
      "distance",
      Object(
        {
          "a": String(a),
          "b": String(b),
          "distance": d,
          "intersecting": hit,
          "point_a": pa,
          "point_b": pb,
          ..
        }
      ),
    ) =>
      if hit is True {
        "\{a} and \{b} intersect (distance 0) near \{vec_text(pa)}"
      } else {
        "distance \{num(d)} between \{a} at \{vec_text(pa)} and \{b} at \{vec_text(pb)}"
      }
    ("overlaps", Object({ "pairs": Array(pairs), .. })) =>
      if pairs.is_empty() {
        "no overlapping meshes"
      } else {
        pairs
        .map(p => {
          match p {
            Array([String(a), String(b)]) => "\{a} overlaps \{b}"
            _ => p.stringify()
          }
        })
        .join("\n")
      }
    ("raycast", Object({ "hits": Array(hits), .. })) =>
      if hits.is_empty() {
        "no hit"
      } else {
        hits
        .map(h => {
          match h {
            Object({ "path": String(path), "distance": d, .. }) =>
              "\{num(d)}\t\{path}"
            _ => h.stringify()
          }
        })
        .join("\n")
      }
    _ => value.stringify()
  }
}

///|
/// JSON boundary for the Node host: `request` is the CLI request, `snapshot`
/// the snapshot file's text. Returns
/// `{"ok": true, "value": ..., "text": ..., "exitCode": 0 | 1}` or
/// `{"ok": false, "error": ...}`. The analysis itself is
/// `@scene3d.query_scene3d_snapshot`, shared with game tests.
pub fn analyze_scene3d(request : String, snapshot : String) -> String {
  let reply : Json = try {
    let req = @json.parse(request)
    let doc = @json.parse(snapshot) catch {
      _ => fail("snapshot is not valid JSON")
    }
    let value = @scene3d.query_scene3d_snapshot(req, doc)
    let operation = match req {
      Object({ "operation": String(op), .. }) => op
      _ => ""
    }
    let failed = value is Object({ "failed": True, .. })
    {
      "ok": true,
      "value": value,
      "text": report(operation, value).to_json(),
      "exitCode": if failed {
        1
      } else {
        0
      },
    }
  } catch {
    @scene3d.Scene3DSnapshotError(message) | Failure(message) =>
      { "ok": false, "error": message.to_json() }
    error => { "ok": false, "error": error.to_string().to_json() }
  }
  reply.stringify()
}
