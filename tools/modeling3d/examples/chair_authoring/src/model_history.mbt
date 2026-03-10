///|
fn contains_string(items : Array[String], value : String) -> Bool {
  for item in items {
    if item == value {
      return true
    }
  }
  false
}

///|
fn is_sculpt_stamp_enabled(layer : SculptLayer, stamp_id : String) -> Bool {
  !contains_string(layer.muted_stamp_ids, stamp_id)
}

///|
fn model_document_with_sculpt_layer(
  doc : ModelDocument,
  layer_index : Int,
  next_layer : SculptLayer,
) -> ModelDocument {
  let layers = doc.sculpt_layers.copy()
  layers[layer_index] = next_layer
  {
    name: doc.name,
    notes: doc.notes,
    primitives: doc.primitives,
    sculpt_layers: layers,
  }
}

///|
fn without_string(items : Array[String], value : String) -> Array[String] {
  let next : Array[String] = []
  for item in items {
    if item != value {
      next.push(item)
    }
  }
  next
}

///|
fn toggle_sculpt_stamp_muted(
  doc : ModelDocument,
  layer_index : Int,
  stamp_id : String,
) -> ModelDocument {
  match doc.sculpt_layers.get(layer_index) {
    None => doc
    Some(layer) => {
      let muted_stamp_ids = if contains_string(layer.muted_stamp_ids, stamp_id) {
        without_string(layer.muted_stamp_ids, stamp_id)
      } else {
        let next = layer.muted_stamp_ids.copy()
        next.push(stamp_id)
        next
      }
      model_document_with_sculpt_layer(doc, layer_index, {
        id: layer.id,
        voxel_size: layer.voxel_size,
        half_extent: layer.half_extent,
        color_hex: layer.color_hex,
        muted_stamp_ids,
        stamps: layer.stamps,
      })
    }
  }
}

///|
fn toggle_recent_sculpt_stamp_muted(
  doc : ModelDocument,
  layer_index : Int,
  history_index : Int,
) -> ModelDocument {
  if history_index < 0 {
    return doc
  }
  match doc.sculpt_layers.get(layer_index) {
    None => doc
    Some(layer) => {
      let stamp_index = layer.stamps.length() - 1 - history_index
      if stamp_index < 0 || stamp_index >= layer.stamps.length() {
        doc
      } else {
        toggle_sculpt_stamp_muted(
          doc,
          layer_index,
          layer.stamps[stamp_index].id,
        )
      }
    }
  }
}

///|
fn undo_last_sculpt_stamp(
  doc : ModelDocument,
  layer_index : Int,
) -> ModelDocument {
  match doc.sculpt_layers.get(layer_index) {
    None => doc
    Some(layer) => {
      let len = layer.stamps.length()
      if len == 0 {
        doc
      } else {
        let stamps = layer.stamps.copy()
        let removed = stamps.pop()
        let muted_stamp_ids = match removed {
          Some(stamp) => without_string(layer.muted_stamp_ids, stamp.id)
          None => layer.muted_stamp_ids
        }
        model_document_with_sculpt_layer(doc, layer_index, {
          id: layer.id,
          voxel_size: layer.voxel_size,
          half_extent: layer.half_extent,
          color_hex: layer.color_hex,
          muted_stamp_ids,
          stamps,
        })
      }
    }
  }
}
