///|
pub(all) enum ModelSelectionKind {
  PrimitiveSelection
  SculptLayerSelection
}

///|
pub(all) struct ModelSelection {
  kind : ModelSelectionKind
  target_id : String
}

///|
pub(all) struct StampHistoryEntry {
  layer_id : String
  stamp_id : String
  mode : SculptMode
  enabled : Bool
  radius : Double
  center : @math3d.Vec3
}

///|
pub fn default_selection(doc : ModelDocument) -> ModelSelection? {
  match doc.sculpt_layers.get(0) {
    Some(layer) => Some({ kind: SculptLayerSelection, target_id: layer.id })
    None => None
  }
}

///|
pub fn selection_from_surface_hit(hit : SurfaceHit?) -> ModelSelection? {
  match hit {
    Some(surface_hit) =>
      Some({
        kind: match surface_hit.kind {
          PrimitiveSurface => PrimitiveSelection
          SculptSurface => SculptLayerSelection
          BakedSculptSurface => SculptLayerSelection
        },
        target_id: surface_hit.target_id,
      })
    None => None
  }
}

///|
fn sculpt_layer_index_by_id(doc : ModelDocument, layer_id : String) -> Int? {
  for i in 0..<doc.sculpt_layers.length() {
    if doc.sculpt_layers[i].id == layer_id {
      return Some(i)
    }
  }
  None
}

///|
pub fn resolve_active_sculpt_layer_index(
  doc : ModelDocument,
  selection : ModelSelection?,
  hover_hit : SurfaceHit?,
) -> Int? {
  match hover_hit {
    Some(hit) =>
      match hit.kind {
        SculptSurface => sculpt_layer_index_by_id(doc, hit.target_id)
        BakedSculptSurface => sculpt_layer_index_by_id(doc, hit.target_id)
        PrimitiveSurface =>
          match selection {
            Some(current) =>
              match current.kind {
                SculptLayerSelection =>
                  sculpt_layer_index_by_id(doc, current.target_id)
                PrimitiveSelection =>
                  if doc.sculpt_layers.is_empty() {
                    None
                  } else {
                    Some(0)
                  }
              }
            None => if doc.sculpt_layers.is_empty() { None } else { Some(0) }
          }
      }
    None =>
      match selection {
        Some(current) =>
          match current.kind {
            SculptLayerSelection =>
              sculpt_layer_index_by_id(doc, current.target_id)
            PrimitiveSelection =>
              if doc.sculpt_layers.is_empty() {
                None
              } else {
                Some(0)
              }
          }
        None => if doc.sculpt_layers.is_empty() { None } else { Some(0) }
      }
  }
}

///|
pub fn recent_sculpt_history(
  doc : ModelDocument,
  layer_index : Int,
  limit : Int,
) -> Array[StampHistoryEntry] {
  if limit <= 0 {
    return []
  }
  match doc.sculpt_layers.get(layer_index) {
    None => []
    Some(layer) => {
      let history : Array[StampHistoryEntry] = []
      let len = layer.stamps.length()
      for offset in 0..<len {
        if history.length() >= limit {
          break
        }
        let stamp = layer.stamps[len - 1 - offset]
        history.push({
          layer_id: layer.id,
          stamp_id: stamp.id,
          mode: stamp.mode,
          enabled: is_sculpt_stamp_enabled(layer, stamp.id),
          radius: stamp.radius,
          center: stamp.center,
        })
      }
      history
    }
  }
}
