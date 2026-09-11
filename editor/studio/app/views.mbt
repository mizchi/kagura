///|
fn button(
  label : String,
  action : () -> Unit,
  class? : String = "",
) -> @dom.DomNode {
  @dom.button(class~, on=@dom.events().click(fn(_) { action() }), [
    @dom.text(label),
  ])
}

///|
fn heading(title : String, detail : String) -> @dom.DomNode {
  @dom.div(class="panel-heading", [
    @dom.h2([@dom.text(title)]),
    @dom.span(class="muted", [@dom.text(detail)]),
  ])
}

///|
pub fn set_layout(value : String) -> Unit {
  if value == "scene" || value == "action" {
    ignore(request({ "method": "layout", "value": value.to_json() }))
    host_action("layout", value)
  }
}

///|
fn toolbar() -> @dom.DomNode {
  @dom.header_(class="toolbar", [
    @dom.div(class="brand", [
      @dom.span(class="brand-mark", [@dom.text("K")]),
      @dom.div([
        @dom.strong([@dom.text("KAGURA")]),
        @dom.span(class="brand-sub", [@dom.text("STUDIO / 01")]),
      ]),
    ]),
    @dom.div(class="project-title", [
      @dom.text_dyn(fn() {
        ignore(view_tick.get())
        session.document.name
      }),
      @dom.span(class="muted", [@dom.text(" / Workspace")]),
    ]),
    @dom.div(class="toolbar-actions", [
      @dom.button(
        dyn_disabled=fn() {
          ignore(view_tick.get())
          !session.can_undo()
        },
        on=@dom.events().click(fn(_) {
          ignore(history("undo", session.revision))
        }),
        [@dom.text("Undo")],
      ),
      @dom.button(
        dyn_disabled=fn() {
          ignore(view_tick.get())
          !session.can_redo()
        },
        on=@dom.events().click(fn(_) {
          ignore(history("redo", session.revision))
        }),
        [@dom.text("Redo")],
      ),
      button("Save", fn() {
        host_action("save", session.document.to_json().stringify())
      }),
      button("Export JSON", fn() {
        host_action("export", session.document.to_json().stringify())
      }),
      button("Export GLB", fn() { host_action("glb", "") }),
      @dom.label(class="file-button", for_="import-scene", [
        @dom.text("Import JSON"),
      ]),
      @dom.input(
        id="import-scene",
        type_="file",
        class="file-input",
        attrs=[
          ("accept", @dom.AttrString("application/json,.json,.kgrscene,.mbt")),
          ("aria-label", @dom.AttrString("Import scene")),
        ],
        on=@dom.events().change(fn(_) { host_action("import", "") }),
      ),
    ]),
  ])
}

///|
fn hierarchy() -> @dom.DomNode {
  @dom.aside(class="panel hierarchy", [
    heading("Hierarchy", "SCENE"),
    @dom.div(class="panel-body", [
      @dom.div(class="scene-root", [
        @dom.text_dyn(fn() {
          ignore(view_tick.get())
          "◈  " + session.document.name
        }),
      ]),
      @dom.for_each(
        fn() {
          ignore(view_tick.get())
          @editor.hierarchy_nodes(session.document)
        },
        fn(n, _) {
          let mut depth = 0
          let mut parent = n.parent
          while parent != "" {
            match @editor.find_node(session.document, parent) {
              Some(p) => {
                depth += 1
                parent = p.parent
              }
              None => break
            }
          }
          @dom.button(
            dyn_class=fn() {
              if selection.get() == n.id {
                "tree-node selected"
              } else {
                "tree-node"
              }
            },
            style="padding-left: " + (12 + depth * 14).to_string() + "px",
            attrs=[("data-node-id", @dom.AttrString(n.id))],
            on=@dom.events().click(fn(_) { select_node(n.id) }),
            [
              @dom.span(class="node-icon", [
                @dom.text(if n.asset == "group" { "◇" } else { "▧" }),
              ]),
              @dom.text(n.name),
              @dom.span(class="node-id", [@dom.text(n.id)]),
            ],
          )
        },
      ),
    ]),
    @dom.div(class="panel-note", [
      @dom.text("Select in the tree or click an object in the viewport."),
    ]),
  ])
}

///|
fn vector_fields(
  n : @editor.SceneNode,
  property : String,
  values : Array[Double],
) -> @dom.DomNode {
  @dom.div(class="transform-field", [
    @dom.div(class="field-title", [
      @dom.text(property),
      @dom.span(class="muted", [
        @dom.text(
          if property == "Rotation" {
            "rad"
          } else if property == "Position" {
            "m"
          } else {
            ""
          },
        ),
      ]),
    ]),
    @dom.div(
      class="xyz",
      [0, 1, 2].map(fn(i) {
        let axis = ["X", "Y", "Z"][i]
        let id = property + "-" + axis
        @dom.label(class="axis-field", [
          @dom.span(class="axis-" + axis, [@dom.text(axis)]),
          @dom.input(
            id~,
            type_="number",
            dyn_value=fn() {
              ignore(view_tick.get())
              values[i].to_string()
            },
            attrs=[
              ("step", @dom.AttrString("0.1")),
              ("aria-label", @dom.AttrString(property + " " + axis)),
            ],
            on=@dom.events().change(fn(_) {
              transform_input(n, property, i, input_number(id))
            }),
          ),
        ])
      }),
    ),
  ])
}

///|
fn inspector() -> @dom.DomNode {
  @dom.aside(class="panel inspector", [
    heading("Inspector", "PROPERTIES"),
    @dom.show(fn() { selected() is None }, fn() {
      @dom.p(class="panel-note", [
        @dom.text("Select an object to edit its properties."),
      ])
    }),
    @dom.for_each(
      fn() {
        match selected() {
          Some(n) => [n]
          None => []
        }
      },
      fn(n, _) {
        @dom.div(class="panel-body", [
          @dom.div(class="object-heading", [
            @dom.span(class="object-icon", [@dom.text("▧")]),
            @dom.div([
              @dom.strong([@dom.text(n.name)]),
              @dom.code([@dom.text(n.id)]),
            ]),
          ]),
          @dom.label(class="field", for_="node-name", [
            @dom.text("Name"),
            @dom.input(
              id="node-name",
              dyn_value=fn() {
                ignore(view_tick.get())
                n.name
              },
              on=@dom.events().change(fn(_) {
                command({
                  "op": "node.rename",
                  "id": n.id.to_json(),
                  "name": input_value("node-name").to_json(),
                })
              }),
            ),
          ]),
          @dom.label(class="field", for_="node-parent", [
            @dom.text("Parent ID"),
            @dom.input(
              id="node-parent",
              dyn_value=fn() {
                ignore(view_tick.get())
                n.parent
              },
              placeholder="Scene root",
              on=@dom.events().change(fn(_) {
                command({
                  "op": "node.reparent",
                  "id": n.id.to_json(),
                  "parent": input_value("node-parent").to_json(),
                })
              }),
            ),
          ]),
          @dom.h3([@dom.text("Transform")]),
          vector_fields(n, "Position", n.position),
          vector_fields(n, "Rotation", n.rotation),
          vector_fields(n, "Scale", n.scale),
          @dom.h3([@dom.text("Material")]),
          @dom.label(class="field color-field", for_="node-color", [
            @dom.text("Base color"),
            @dom.input(
              id="node-color",
              type_="color",
              dyn_value=fn() {
                ignore(view_tick.get())
                color_string(n.color)
              },
              on=@dom.events().change(fn(_) {
                command({
                  "op": "node.material",
                  "id": n.id.to_json(),
                  "color": color_number("node-color").to_json(),
                })
              }),
            ),
          ]),
          @dom.p(class="muted", [@dom.text(n.asset)]),
          button(
            "Delete object",
            fn() { command({ "op": "node.remove", "id": n.id.to_json() }) },
            class="danger",
          ),
        ])
      },
    ),
  ])
}

///|
fn viewport() -> @dom.DomNode {
  @dom.section(class="panel viewport", [
    @dom.div(class="viewport-toolbar", [
      @dom.div([
        @dom.strong([@dom.text("Scene")]),
        @dom.span(class="muted", [@dom.text(" / Perspective")]),
      ]),
      @dom.div(class="view-buttons", [
        button("Perspective", fn() { host_action("camera", "perspective") }),
        button("Front", fn() { host_action("camera", "front") }),
        button("Side", fn() { host_action("camera", "side") }),
        button("Top", fn() { host_action("camera", "top") }),
        button("Frame selected", fn() { host_action("frame", selection.get()) }),
      ]),
    ]),
    @dom.div(id="viewport", [
      @dom.div(class="viewport-badge", [
        @dom.span(class="live-dot", []),
        @dom.text("AUTHORING VIEW"),
      ]),
      @dom.div(class="viewport-help", [
        @dom.text("Drag to orbit · Scroll to zoom · Right-drag to pan"),
      ]),
      @dom.div(class="axis-guide", [
        @dom.span(class="axis-X", [@dom.text("X")]),
        @dom.span(class="axis-Y", [@dom.text("Y")]),
        @dom.span(class="axis-Z", [@dom.text("Z")]),
      ]),
    ]),
  ])
}

///|
fn assets() -> @dom.DomNode {
  @dom.section(class="panel assets", [
    heading("Resources", "BUILT-IN"),
    @dom.div(class="resource-list", [
      button(
        "Browse storage",
        fn() { host_action("storage", "") },
        class="resource",
      ),
      button("Add box", fn() { add_node("primitive.box") }, class="resource"),
      button(
        "Add sphere",
        fn() { add_node("primitive.sphere") },
        class="resource",
      ),
      button(
        "Add cylinder",
        fn() { add_node("primitive.cylinder") },
        class="resource",
      ),
      button("Add group", fn() { add_node("group") }, class="resource"),
    ]),
    @dom.p(class="panel-note", [
      @dom.text(
        "Primitives are recipes. Instances keep stable IDs and editable transforms.",
      ),
    ]),
  ])
}

///|
fn action_fields() -> @dom.DomNode {
  @dom.for_each(
    fn() {
      ignore(view_tick.get())
      [session.document.action]
    },
    fn(a, _) {
      @dom.div(
        class="action-fields",
        [
          ("Duration", "duration", a.duration),
          ("Flash", "flashDuration", a.flashDuration),
          ("Recoil", "recoilDuration", a.recoilDuration),
          ("Strength", "recoilStrength", a.recoilStrength),
        ].map(fn(entry) {
          let (label, key, value) = entry
          let id = "action-" + key
          @dom.label(class="field", for_=id, [
            @dom.text(label),
            @dom.input(
              id~,
              type_="number",
              dyn_value=fn() {
                ignore(view_tick.get())
                value.to_string()
              },
              attrs=[("step", @dom.AttrString("0.01"))],
              on=@dom.events().change(fn(_) {
                let value = input_number(id)
                if !(value >= 0 && value <= 60) {
                  status.set("Error · Enter a valid action value")
                  view_tick.set(view_tick.get() + 1)
                  return
                }
                let next = match key {
                  "duration" => { ..a, duration: value, }
                  "flashDuration" => { ..a, flashDuration: value, }
                  "recoilDuration" => { ..a, recoilDuration: value, }
                  _ => { ..a, recoilStrength: value, }
                }
                command({ "op": "action.set", "action": ToJson::to_json(next) })
              }),
            ),
          ])
        }),
      )
    },
  )
}

///|
fn timeline() -> @dom.DomNode {
  @dom.section(class="panel timeline", [
    heading("Action preview", "SECONDS"),
    @dom.div(class="timeline-body", [
      @dom.div(class="transport", [
        button(
          "Play preview",
          fn() { host_action("play", "") },
          class="primary",
        ),
        button("Pause", fn() { host_action("pause", "") }),
        @dom.code([@dom.text_dyn(fn() { cursor.get().to_string() + " s" })]),
        @dom.label(class="target-field", for_="action-target", [
          @dom.text("Target"),
          @dom.input(
            id="action-target",
            placeholder="Node ID",
            dyn_value=fn() {
              ignore(view_tick.get())
              session.document.action.target
            },
            on=@dom.events().change(fn(_) {
              let action = {
                ..session.document.action,
                target: input_value("action-target"),
              }
              command({ "op": "action.set", "action": ToJson::to_json(action) })
            }),
          ),
        ]),
      ]),
      @dom.input(
        id="preview-time",
        type_="range",
        dyn_value=fn() { cursor.get().to_string() },
        attrs=[
          ("min", @dom.AttrString("0")),
          ("step", @dom.AttrString("0.01")),
          ("aria-label", @dom.AttrString("Preview time")),
        ],
        dyn_attrs=[
          (
            "max",
            @dom.attr_dynamic(fn() {
              ignore(view_tick.get())
              session.document.action.duration.to_string()
            }),
          ),
        ],
        on=@dom.events().input(fn(_) {
          host_action("pause", "")
          seek(input_number("preview-time"))
        }),
      ),
      @dom.div(class="track", [
        @dom.span([@dom.text("Flash")]),
        @dom.div(class="track-lane", [
          @dom.div(
            class="flash-clip",
            dyn_style=fn() {
              ignore(view_tick.get())
              "width:" +
              (session.document.action.flashDuration /
              session.document.action.duration *
              100).to_string() +
              "%"
            },
            [],
          ),
        ]),
      ]),
      @dom.div(class="track", [
        @dom.span([@dom.text("Recoil")]),
        @dom.div(class="track-lane", [
          @dom.div(
            class="recoil-clip",
            dyn_style=fn() {
              ignore(view_tick.get())
              "width:" +
              (session.document.action.recoilDuration /
              session.document.action.duration *
              100).to_string() +
              "%"
            },
            [],
          ),
        ]),
      ]),
      action_fields(),
    ]),
  ])
}

///|
fn agent_panel() -> @dom.DomNode {
  @dom.section(class="panel agent", [
    heading("Command console", "AI / JSON"),
    @dom.div(class="panel-body", [
      @dom.p(class="muted", [
        @dom.text("Inspect → edit → review. Each batch is one undo step."),
      ]),
      @dom.label(for_="commands", class="sr-only", [@dom.text("Command JSON")]),
      @dom.textarea(
        id="commands",
        attrs=[("spellcheck", @dom.AttrString("false"))],
        [
          @dom.text(
            "{\n  \"expectedRevision\": 0,\n  \"commands\": [{\n    \"op\": \"node.rename\",\n    \"id\": \"hero\",\n    \"name\": \"Player\"\n  }]\n}",
          ),
        ],
      ),
      @dom.div(class="console-actions", [
        button(
          "Apply commands",
          fn() { ignore(dispatch(input_value("commands"))) },
          class="primary",
        ),
        button("Copy context", fn() { host_action("copy", pretty(snapshot())) }),
      ]),
      @dom.p(class="panel-note", [
        @dom.text(
          "window.kagura · snapshot / dispatch / undo / redo / subscribe",
        ),
      ]),
    ]),
  ])
}

///|
fn splitter(id : String, label : String, orientation : String) -> @dom.DomNode {
  @dom.div(
    class="splitter splitter-" + orientation,
    attrs=[
      ("role", @dom.AttrString("separator")),
      ("tabindex", @dom.AttrString("0")),
      ("aria-label", @dom.AttrString(label)),
      ("aria-orientation", @dom.AttrString(orientation)),
      ("data-split", @dom.AttrString(id)),
    ],
    [],
  )
}

///|
pub fn mount(target : @browser.Element) -> Unit {
  @dom.mount_to(
    target,
    @dom.div(dyn_class=fn() { "studio layout-" + layout.get() }, [
      toolbar(),
      @dom.nav(class="workspace-bar", [
        @dom.div(class="layout-switch", [
          button("Scene layout", fn() { set_layout("scene") }),
          button("Action layout", fn() { set_layout("action") }),
        ]),
        @dom.span(class="workspace-info", [
          @dom.text_dyn(fn() {
            ignore(view_tick.get())
            session.document.nodes.length().to_string() +
            " objects  ·  Y-up  ·  meters"
          }),
        ]),
        @dom.span(class="revision", [
          @dom.text_dyn(fn() { "REV " + revision.get().to_string() }),
        ]),
      ]),
      @dom.main_(class="workspace", [
        @dom.div(
          class="pane-column",
          attrs=[("data-column", @dom.AttrString("0"))],
          [
            hierarchy(),
            splitter("row-0", "Resize hierarchy and resources", "horizontal"),
            assets(),
          ],
        ),
        splitter("column-0", "Resize hierarchy and scene columns", "vertical"),
        @dom.div(
          class="pane-column",
          attrs=[("data-column", @dom.AttrString("1"))],
          [
            viewport(),
            splitter("row-1", "Resize scene and action preview", "horizontal"),
            timeline(),
          ],
        ),
        splitter("column-1", "Resize scene and inspector columns", "vertical"),
        @dom.div(
          class="pane-column",
          attrs=[("data-column", @dom.AttrString("2"))],
          [
            inspector(),
            splitter(
              "row-2", "Resize inspector and command console", "horizontal",
            ),
            agent_panel(),
          ],
        ),
      ]),
      @dom.footer_(class="statusbar", [
        @dom.div(attrs=[("role", @dom.AttrString("status"))], [
          @dom.text_dyn(fn() { status.get() }),
        ]),
        @dom.span([@dom.text("Luna UI · MoonBit · three")]),
      ]),
    ]),
  )
}
