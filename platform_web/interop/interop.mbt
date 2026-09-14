///|
/// JS boundary primitives only. Algorithms and state belong in the other files.
pub fn field(value : @core.Any, key : String) -> @core.Any {
  if @core.is_nullish(value) {
    @core.undefined()
  } else {
    value._get(key)
  }
}

///|
pub fn fallback(value : @core.Any, default : @core.Any) -> @core.Any {
  if @core.is_nullish(value) {
    default
  } else {
    value
  }
}

///|
/// JS default arguments substitute undefined, but preserve null.
pub fn argument(value : @core.Any, default : @core.Any) -> @core.Any {
  if @core.is_undefined(value) {
    default
  } else {
    value
  }
}

///|
pub fn number_field(
  value : @core.Any,
  key : String,
  default : Double,
) -> Double {
  fallback(field(value, key), @core.any(default)).cast()
}

///|
pub fn array_values(value : @core.Any) -> Array[@core.Any] {
  if @core.is_nullish(value) {
    []
  } else {
    @core.array_from(value)
  }
}

///|
pub extern "js" fn finite(value : @core.Any) -> Bool =
  #| (value) => Number.isFinite(value)

///|
pub extern "js" fn safe_integer(value : @core.Any) -> Bool =
  #| (value) => Number.isSafeInteger(value)

///|
pub extern "js" fn truthy(value : @core.Any) -> Bool =
  #| (value) => !!value

///|
pub extern "js" fn range_error(message : String) -> Unit =
  #| (message) => { throw new RangeError(message); }

///|
pub extern "js" fn object_spread(
  left : @core.Any,
  right : @core.Any,
) -> @core.Any =
  #| (left, right) => ({...left, ...right})

///|
pub extern "js" fn delete_key(value : @core.Any, key : String) -> Unit =
  #| (value, key) => { delete value[key]; }

///|
pub extern "js" fn fixed_decimal(value : Double, digits : Int) -> Double =
  #| (value, digits) => Number(value.toFixed(digits))

///|
pub fn clamp(value : Double, low : Double, high : Double) -> Double {
  value.max(low).min(high)
}

///|
pub fn vector(x : Double, y : Double) -> @core.Any {
  @core.from_entries([("x", @core.any(x)), ("y", @core.any(y))])
}

///|
pub fn number(value : @core.Any) -> Double {
  value.cast()
}

///|
pub fn length(value : @core.Any) -> Int {
  value._get("length").cast()
}
