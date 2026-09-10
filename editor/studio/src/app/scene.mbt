///|
/// Renderer adapter: rebuilding this view never changes authoring state or history.
pub fn build_scene() -> @three.Group {
  let root = @three.Group()
  let objects : Map[String, @three.Object3D] = Map([])
  for n in session.document.nodes {
    let object = if n.asset == "group" {
      @three.Group().as_object3d()
    } else {
      let geometry = match n.asset {
        "primitive.sphere" =>
          @three.SphereGeometry(0.5, 24, 16).as_buffer_geometry()
        "primitive.cylinder" =>
          @three.CylinderGeometry(0.5, 0.5, 1, 24).as_buffer_geometry()
        _ => @three.BoxGeometry(1, 1, 1).as_buffer_geometry()
      }
      @three.Mesh(
        geometry,
        @three.MeshStandardMaterial(n.color, roughness=0.75, metalness=0.05).as_material(),
      ).as_object3d()
    }
    object.set_name(n.id)
    object.position().set(n.position[0], n.position[1], n.position[2]) |> ignore
    object.rotation().set(n.rotation[0], n.rotation[1], n.rotation[2]) |> ignore
    object.scale().set(n.scale[0], n.scale[1], n.scale[2]) |> ignore
    objects[n.id] = object
  }
  for n in session.document.nodes {
    let object = objects[n.id]
    match objects.get(n.parent) {
      Some(parent) => parent.add(object) |> ignore
      None => root.add(object) |> ignore
    }
  }
  root
}
