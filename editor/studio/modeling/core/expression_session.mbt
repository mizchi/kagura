///|
struct ExpressionEdit {
  before : ModelDocument
  weights : Map[String, Double]
  id : String
  name : String
}

///|
fn ModelEditor::handle_expression(
  self : ModelEditor,
  req : Json,
  op : String,
) -> Unit raise {
  match op {
    "expression.preview" => {
      keys(req, ["op", "weights"])
      let weights : Map[String, Double] = @json.from_json(field(req, "weights"))
      // Validate the full result before touching session state.
      ignore(evaluate_expressions(self.document, weights))
      self.weights = weights
    }
    "expression.begin" => {
      keys(req, ["op", "id", "name"])
      let id = string_field(req, "id")
      let name = string_field(req, "name")
      require(
        id.length() > 0 &&
        id.length() <= 80 &&
        name.length() > 0 &&
        name.length() <= 120,
        "Invalid expression name or ID",
      )
      let existing = self.document.expressions.any(e => e.id == id)
      require(
        existing || self.document.expressions.length() < 32,
        "At most 32 expressions",
      )
      let draft = if existing {
        evaluate_expressions(self.document, Map([(id, 1.0)]))
      } else {
        self.document
      }
      self.expression_edit = Some({
        before: self.document,
        weights: self.weights,
        id,
        name,
      })
      self.weights = Map([])
      self.document = draft
      self.mode = "object"
      self.indices = []
      self.face = -1
    }
    "expression.save" => {
      keys(req, ["op"])
      guard self.expression_edit is Some(edit) else {
        raise Invalid("No expression draft")
      }
      let expression = capture_expression(
        edit.before,
        self.document,
        edit.id,
        edit.name,
      )
      let expressions = edit.before.expressions.copy()
      let mut found = false
      for i, e in expressions {
        if e.id == edit.id {
          expressions[i] = expression
          found = true
        }
      }
      if !found {
        expressions.push(expression)
      }
      let next = { ..edit.before, expressions, }
      validate_document(next)
      self.expression_edit = None
      self.document = edit.before
      self.commit(edit.before, next)
      self.weights = Map([(edit.id, 1.0)])
      self.mode = "object"
      self.indices = []
      self.face = -1
    }
    "expression.cancel" => {
      keys(req, ["op"])
      guard self.expression_edit is Some(edit) else {
        raise Invalid("No expression draft")
      }
      self.document = edit.before
      self.weights = edit.weights
      self.expression_edit = None
      self.mode = "object"
      self.indices = []
      self.face = -1
    }
    "expression.remove" => {
      keys(req, ["op", "id"])
      let id = string_field(req, "id")
      require(
        self.document.expressions.any(e => e.id == id),
        "Unknown expression: " + id,
      )
      self.commit(self.document, {
        ..self.document,
        expressions: self.document.expressions.filter(e => e.id != id),
      })
      self.weights = Map([])
    }
    _ => raise Invalid("Unknown expression operation: " + op)
  }
}
