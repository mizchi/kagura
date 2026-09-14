///|
/// JS boundary primitives only. Algorithms and state belong in the other files.
fn field(value : @core.Any, key : String) -> @core.Any {
  if @core.is_nullish(value) {
    @core.undefined()
  } else {
    value._get(key)
  }
}

///|
/// JS default arguments substitute undefined, but preserve null.
fn argument(value : @core.Any, default : @core.Any) -> @core.Any {
  if @core.is_undefined(value) {
    default
  } else {
    value
  }
}

///|
fn array_values(value : @core.Any) -> Array[@core.Any] {
  if @core.is_nullish(value) {
    []
  } else {
    @core.array_from(value)
  }
}

///|
extern "js" fn truthy(value : @core.Any) -> Bool =
  #| (value) => !!value

///|
fn number(value : @core.Any) -> Double {
  value.cast()
}
