///|
/// Session owns authoring state. Preview, camera and view layout never enter document history.
pub struct Session {
  mut document : Document
  mut revision : Int
  past : Array[Document]
  future : Array[Document]
}

///|
pub fn Session::new() -> Session {
  { document: default_document(), revision: 0, past: [], future: [] }
}

///|
pub fn Session::can_undo(self : Session) -> Bool {
  !self.past.is_empty()
}

///|
pub fn Session::can_redo(self : Session) -> Bool {
  !self.future.is_empty()
}

///|
pub fn Session::execute(self : Session, envelope : Json) -> Unit raise {
  keys(envelope, ["expectedRevision", "commands"])
  let expected : Int = integer(field(envelope, "expectedRevision"))
  if expected != self.revision {
    raise Conflict(self.revision)
  }
  guard field(envelope, "commands") is Array(commands) else {
    raise Invalid("Expected commands array")
  }
  require(
    commands.length() > 0 && commands.length() <= 100,
    "Transaction requires 1-100 commands",
  )
  let mut next = self.document
  for command in commands {
    next = apply(next, command)
  }
  self.past.push(self.document)
  if self.past.length() > 100 {
    ignore(self.past.remove(0))
  }
  self.document = next
  self.future.clear()
  self.revision += 1
}

///|
pub fn Session::undo(self : Session) -> Unit raise EditorError {
  guard self.past.pop() is Some(previous) else {
    raise Invalid("Nothing to undo")
  }
  self.future.push(self.document)
  self.document = previous
  self.revision += 1
}

///|
pub fn Session::redo(self : Session) -> Unit raise EditorError {
  guard self.future.pop() is Some(next) else {
    raise Invalid("Nothing to redo")
  }
  self.past.push(self.document)
  self.document = next
  self.revision += 1
}
