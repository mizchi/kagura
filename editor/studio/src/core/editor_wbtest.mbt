///|
test "transaction applies all commands as one undo step" {
  let editor = Session::new()
  let original = editor.document.to_json().stringify()
  editor.execute(
    @json.parse(
      "{\"expectedRevision\":0,\"commands\":[{\"op\":\"node.add\",\"id\":\"crate\",\"name\":\"Crate\",\"asset\":\"primitive.box\"},{\"op\":\"node.transform\",\"id\":\"crate\",\"position\":[2,1,0],\"rotation\":[0,0,0],\"scale\":[1,2,1]}]}",
    ),
  )
  assert_eq(editor.revision, 1)
  assert_eq(editor.document.nodes.length(), 4)
  assert_eq(editor.document.nodes[3].position, [2.0, 1.0, 0.0])
  editor.undo()
  assert_eq(editor.document.to_json().stringify(), original)
  assert_eq(editor.revision, 2)
  editor.redo()
  assert_eq(editor.document.nodes.length(), 4)
  assert_eq(editor.revision, 3)
}

///|
test "invalid second command rolls back document revision and history" {
  let editor = Session::new()
  let original = editor.document.to_json().stringify()
  let result = attempt(fn() raise {
    editor.execute(
      @json.parse(
        "{\"expectedRevision\":0,\"commands\":[{\"op\":\"node.add\",\"id\":\"crate\",\"name\":\"Crate\",\"asset\":\"primitive.box\"},{\"op\":\"node.transform\",\"id\":\"crate\",\"position\":[0,0,0],\"rotation\":[0,0,0],\"scale\":[0,1,1]}]}",
      ),
    )
  })
  assert_false(result)
  assert_eq(editor.document.to_json().stringify(), original)
  assert_eq(editor.revision, 0)
  assert_eq(editor.past.length(), 0)
}

///|
test "stale revisions cannot overwrite human edits including after undo" {
  let editor = Session::new()
  let command = @json.parse(
    "{\"expectedRevision\":0,\"commands\":[{\"op\":\"node.rename\",\"id\":\"hero\",\"name\":\"Actor\"}]}",
  )
  editor.execute(command)
  assert_false(attempt(fn() raise { editor.execute(command) }))
  editor.undo()
  assert_false(attempt(fn() raise { editor.execute(command) }))
}

///|
test "hierarchy rejects missing parents cycles and deletes a subtree" {
  let editor = Session::new()
  editor.execute(
    @json.parse(
      "{\"expectedRevision\":0,\"commands\":[{\"op\":\"node.add\",\"id\":\"child\",\"name\":\"Child\",\"asset\":\"primitive.sphere\",\"parent\":\"hero\"}]}",
    ),
  )
  assert_false(
    attempt(fn() raise {
      editor.execute(
        @json.parse(
          "{\"expectedRevision\":1,\"commands\":[{\"op\":\"node.reparent\",\"id\":\"hero\",\"parent\":\"child\"}]}",
        ),
      )
    }),
  )
  assert_false(
    attempt(fn() raise {
      editor.execute(
        @json.parse(
          "{\"expectedRevision\":1,\"commands\":[{\"op\":\"node.reparent\",\"id\":\"hero\",\"parent\":\"missing\"}]}",
        ),
      )
    }),
  )
  editor.execute(
    @json.parse(
      "{\"expectedRevision\":1,\"commands\":[{\"op\":\"node.remove\",\"id\":\"hero\"}]}",
    ),
  )
  assert_eq(editor.document.nodes.length(), 2)
}

///|
test "strict input rejects unknown fields unknown assets duplicate IDs and empty batches" {
  for
    source in [
      "{\"expectedRevision\":0,\"commands\":[]}", "{\"expectedRevision\":0,\"commands\":[{\"op\":\"node.rename\",\"id\":\"hero\",\"name\":\"Actor\",\"typo\":1}]}",
      "{\"expectedRevision\":0,\"commands\":[{\"op\":\"node.add\",\"id\":\"hero\",\"name\":\"Duplicate\",\"asset\":\"primitive.box\"}]}",
      "{\"expectedRevision\":0,\"commands\":[{\"op\":\"node.add\",\"id\":\"unknown\",\"name\":\"Unknown\",\"asset\":\"unknown\"}]}",
      "{\"expectedRevision\":0.5,\"commands\":[{\"op\":\"node.remove\",\"id\":\"hero\"}]}",
    ] {
    let editor = Session::new()
    assert_false(attempt(fn() raise { editor.execute(@json.parse(source)) }))
    assert_eq(editor.revision, 0)
  }
}

///|
test "document roundtrip import is undoable and validates version and references" {
  let editor = Session::new()
  let saved = editor.document.to_json()
  editor.execute(
    @json.parse(
      "{\"expectedRevision\":0,\"commands\":[{\"op\":\"node.remove\",\"id\":\"hero\"}]}",
    ),
  )
  editor.execute({
    "expectedRevision": 1,
    "commands": [{ "op": "document.replace", "document": saved }],
  })
  assert_eq(editor.document.to_json(), saved)
  editor.undo()
  assert_eq(editor.document.nodes.length(), 2)
  assert_false(
    attempt(fn() raise { ignore(decode_document({ "version": 99 })) }),
  )
}

///|
test "new edit after undo invalidates redo" {
  let editor = Session::new()
  editor.execute(
    @json.parse(
      "{\"expectedRevision\":0,\"commands\":[{\"op\":\"node.remove\",\"id\":\"hero\"}]}",
    ),
  )
  editor.undo()
  editor.execute(
    @json.parse(
      "{\"expectedRevision\":2,\"commands\":[{\"op\":\"node.rename\",\"id\":\"hero\",\"name\":\"Branch\"}]}",
    ),
  )
  assert_false(attempt(fn() raise { editor.redo() }))
  assert_eq(editor.revision, 3)
}

///|
test "preview is deterministic supports backward seek and leaves source untouched" {
  let editor = Session::new()
  let original = editor.document.to_json()
  let first = sample_action(editor.document.action, 0.03)
  ignore(sample_action(editor.document.action, 0.7))
  assert_eq(sample_action(editor.document.action, 0.03), first)
  assert_true(first.flash)
  assert_false(sample_action(editor.document.action, 0.5).flash)
  assert_eq(sample_action(editor.document.action, 0.0).offset, 0.0)
  assert_eq(editor.document.to_json(), original)
  assert_eq(editor.revision, 0)
}

///|
fn attempt(f : () -> Unit raise) -> Bool {
  try {
    f()
    true
  } catch {
    _ => false
  }
}

///|
test "action references validate and removing target clears its preview binding" {
  let editor = Session::new()
  let invalid = { ..editor.document.action, target: "missing" }
  assert_false(
    attempt(fn() raise {
      ignore(
        apply(editor.document, {
          "op": "action.set",
          "action": ToJson::to_json(invalid),
        }),
      )
    }),
  )
  editor.execute(
    @json.parse(
      "{\"expectedRevision\":0,\"commands\":[{\"op\":\"node.remove\",\"id\":\"hero\"}]}",
    ),
  )
  assert_eq(editor.document.action.target, "")
  editor.undo()
  assert_eq(editor.document.action.target, "hero")
}

///|
test "hierarchy traversal groups children under parents even after reparenting" {
  let doc = apply(default_document(), {
    "op": "node.reparent",
    "id": "ground",
    "parent": "block",
  })
  assert_eq(hierarchy_nodes(doc).map(fn(n) { n.id }), [
    "hero", "block", "ground",
  ])
}
