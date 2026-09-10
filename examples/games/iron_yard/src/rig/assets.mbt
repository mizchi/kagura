///|
pub(all) struct Material {
  color : @math3d.Vec4
  metallic : Double
  roughness : Double
  emissive : @math3d.Vec3
  texture : Int
  transparent : Bool
  unlit : Bool
}

///|
pub(all) struct Batch {
  bone : Int
  mesh : @mesh3d.Mesh3D
  material : Material
}

///|
pub(all) struct Bone {
  name : String
  parent : Int
  rest : @transform3d.Transform3D
}

///|
pub(all) struct Asset {
  batches : Array[Batch]
  bones : Array[Bone]
  clips : Map[String, @animation3d.AnimationClip]
}

///|
fn field(j : Json, key : String) -> Json {
  match j {
    Object(m) => m.get(key).unwrap_or(null)
    _ => null
  }
}

///|
fn arr(j : Json) -> Array[Json] {
  match j {
    Array(a) => a
    _ => []
  }
}

///|
fn num(j : Json) -> Double {
  match j {
    Number(n, ..) => n
    _ => 0.0
  }
}

///|
fn text(j : Json) -> String {
  match j {
    String(s) => s
    _ => ""
  }
}

///|
fn numbers(j : Json) -> Array[Double] {
  arr(j).map(num)
}

///|
fn v3(j : Json) -> @math3d.Vec3 {
  let a = numbers(j)
  @sim.vec(a[0], a[1], a[2])
}

///|
fn quat(j : Json) -> @math3d.Quaternion {
  let a = numbers(j)
  @math3d.Quaternion::new(a[0], a[1], a[2], a[3])
}

///|
pub fn read_asset(source : String) -> Asset raise {
  let json = @json.parse(source)
  guard num(field(json, "version")) == 1.0 else {
    fail("Unsupported render asset version")
  }
  let bones = arr(field(json, "bones")).map(fn(b) {
    Bone::{
      name: text(field(b, "name")),
      parent: num(field(b, "parent")).to_int(),
      rest: @transform3d.Transform3D::from_components(
        v3(field(b, "position")),
        quat(field(b, "rotation")),
        v3(field(b, "scale")),
      ),
    }
  })
  let batches = arr(field(json, "batches")).map(fn(b) {
    let m = field(b, "material")
    let color = numbers(field(m, "color"))
    Batch::{
      bone: num(field(b, "bone")).to_int(),
      mesh: @mesh3d.Mesh3D::new(
        numbers(field(b, "vertices")),
        arr(field(b, "indices")).map(fn(i) { num(i).to_int() }),
      ),
      material: {
        color: @math3d.Vec4::new(color[0], color[1], color[2], color[3]),
        metallic: num(field(m, "metallic")),
        roughness: num(field(m, "roughness")),
        emissive: v3(field(m, "emissive")),
        texture: num(field(m, "texture")).to_int(),
        transparent: text(field(m, "alpha")) == "BLEND",
        unlit: field(m, "unlit") is True,
      },
    }
  })
  let clips : Map[String, @animation3d.AnimationClip] = Map([])
  for c in arr(field(json, "clips")) {
    let name = text(field(c, "name"))
    let channels = arr(field(c, "channels")).map(fn(ch) {
      @animation3d.AnimChannel::{
        node_index: num(field(ch, "bone")).to_int(),
        target: match text(field(ch, "path")) {
          "translation" => Translation
          "scale" => Scale
          _ => Rotation
        },
        interpolation: if text(field(ch, "interpolation")) == "STEP" {
          Step
        } else {
          Linear
        },
        times: numbers(field(ch, "times")),
        values: numbers(field(ch, "values")),
      }
    })
    clips[name] = { name, channels, duration: num(field(c, "duration")) }
  }
  { batches, bones, clips }
}

///|
pub fn sample(
  asset : Asset,
  clip : String,
  time : Double,
) -> Array[@transform3d.Transform3D] {
  let pose = asset.bones.map(fn(b) { b.rest })
  if asset.clips.get(clip) is Some(c) {
    let t = if clip == "Boost" {
      @sim.clamp(time, 0.0, c.duration)
    } else {
      time - c.duration * (time / c.duration).floor()
    }
    for channel in c.channels {
      let i = channel.node_index
      pose[i] = match channel.target {
        Translation =>
          pose[i].with_position(@animation3d.sample_vec3(channel, t))
        Scale => pose[i].with_scale(@animation3d.sample_vec3(channel, t))
        Rotation => pose[i].with_rotation(@animation3d.sample_quat(channel, t))
      }
    }
  }
  pose
}
