///|
/// JsonObjectPublisher receiver. Preserve JS references, symbols and own __proto__.
pub fn apply_object_patch(previous : @core.Any, patch : @core.Any) -> @core.Any {
  let value = @interop.object_spread(
    if @interop.truthy(patch._get("full")) {
      @core.null()
    } else {
      previous
    },
    patch._get("set"),
  )
  for key in @interop.array_values(patch._get("remove")) {
    @interop.delete_key(value, key.cast())
  }
  value
}

///|
pub fn create_dependency_gate() -> @core.Any {
  let previous : Ref[@core.Any?] = Ref(None)
  @core.from_fn1(fn(dependencies : @core.Any) -> Bool {
    let count : Int = dependencies._get("length").cast()
    if previous.val is Some(old) && @interop.length(old) == count {
      let mut same = true
      for i = 0; i < count; i = i + 1 {
        if !@object.Object::is_(
            dependencies._get_by_index(i),
            old._get_by_index(i),
          ) {
          same = false
          break
        }
      }
      if same {
        return false
      }
    }
    previous.val = Some(dependencies)
    true
  })
}
