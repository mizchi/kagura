///|
/// A logical subject can be referenced by several render nodes. No renderer handles.
pub(all) struct Subject {
  id : String
  name : String
  fields : Array[Field]
} derive(ToJson)

///|
pub(all) enum Field {
  Number(String, String, Double, String, Bool)
  Text(String, String, String, Bool)
  Boolean(String, String, Bool, Bool)
}

///|
pub fn number(
  id : String,
  value : Double,
  label? : String = id,
  unit? : String = "",
  editable? : Bool = false,
) -> Field {
  Number(id, label, value, unit, editable)
}

///|
pub impl ToJson for Field with fn to_json(self) {
  let (id, label, kind, value, unit, editable) = match self {
    Number(id, label, value, unit, editable) =>
      (id, label, "number", value.to_json(), unit, editable)
    Text(id, label, value, editable) =>
      (id, label, "string", value.to_json(), "", editable)
    Boolean(id, label, value, editable) =>
      (id, label, "boolean", value.to_json(), "", editable)
  }
  {
    "id": id,
    "label": label,
    "kind": kind,
    "value": value,
    "unit": unit,
    "access": if editable {
      "runtime"
    } else {
      "readonly"
    },
  }
}
