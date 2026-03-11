///|
/// Build a Skeleton from a glTF skin definition.
fn skeleton_from_gltf(
  doc : GltfDocument,
  skin_index : Int,
  buffers : Array[Bytes],
) -> @skeleton3d.Skeleton raise GltfError {
  let skin = doc.skins[skin_index]
  let joint_count = skin.joints.length()
  // Read inverse bind matrices
  let ibms : Array[@math3d.Mat4] = []
  match skin.inverse_bind_matrices {
    Some(acc_idx) => {
      let floats = read_accessor_floats(doc, acc_idx, buffers)
      for i in 0..<joint_count {
        let off = i * 16
        // Column-major: elements[col*4+row]
        let c0 = @math3d.Vec4::new(
          floats[off],
          floats[off + 1],
          floats[off + 2],
          floats[off + 3],
        )
        let c1 = @math3d.Vec4::new(
          floats[off + 4],
          floats[off + 5],
          floats[off + 6],
          floats[off + 7],
        )
        let c2 = @math3d.Vec4::new(
          floats[off + 8],
          floats[off + 9],
          floats[off + 10],
          floats[off + 11],
        )
        let c3 = @math3d.Vec4::new(
          floats[off + 12],
          floats[off + 13],
          floats[off + 14],
          floats[off + 15],
        )
        ibms.push(@math3d.Mat4::from_cols(c0, c1, c2, c3))
      }
    }
    None =>
      for _i in 0..<joint_count {
        ibms.push(@math3d.Mat4::identity())
      }
  }
  // Build bones from joint nodes
  let bones : Array[@skeleton3d.Bone] = []
  // Create a mapping from node index to joint index
  let node_to_joint : Map[Int, Int] = {}
  for i in 0..<joint_count {
    node_to_joint[skin.joints[i]] = i
  }
  for i in 0..<joint_count {
    let node_idx = skin.joints[i]
    let node = doc.nodes[node_idx]
    // Find parent: look for which joint has this node as a child
    let mut parent_joint = -1
    for p in 0..<joint_count {
      if p == i {
        continue
      }
      let parent_node_idx = skin.joints[p]
      let parent_node = doc.nodes[parent_node_idx]
      for child_idx in parent_node.children {
        if child_idx == node_idx {
          parent_joint = p
          break
        }
      }
      if parent_joint >= 0 {
        break
      }
    }
    let local_transform = @transform3d.Transform3D::from_components(
      node.translation,
      node.rotation,
      node.scale,
    )
    bones.push({
      name: "joint_" + i.to_string(),
      parent: parent_joint,
      local_transform,
    })
  }
  @skeleton3d.Skeleton::new(bones, ibms)
}

///|
/// Build SkinData from the first primitive of the first mesh that has skin attributes.
fn skin_data_from_gltf(
  doc : GltfDocument,
  skin_index : Int,
  buffers : Array[Bytes],
) -> @skeleton3d.SkinData? raise GltfError {
  // Find the mesh node that references this skin
  let mut mesh_idx : Int? = None
  for node in doc.nodes {
    match (node.skin, node.mesh) {
      (Some(si), Some(mi)) =>
        if si == skin_index {
          mesh_idx = Some(mi)
          break
        }
      _ => ()
    }
  }
  let mi = match mesh_idx {
    Some(i) => i
    None => return None
  }
  let mesh = doc.meshes[mi]
  if mesh.primitives.is_empty() {
    return None
  }
  let prim = mesh.primitives[0]
  if not(prim.attributes.contains("JOINTS_0")) ||
    not(prim.attributes.contains("WEIGHTS_0")) {
    return None
  }
  let raw_joints = read_skin_joints_from_primitive(doc, prim, buffers)
  let weights = read_skin_weights_from_primitive(doc, prim, buffers)
  let vertex_count = raw_joints.length() / 4
  // Remap joint indices: glTF joint indices are node indices in the skin.joints array
  // They're already indices into the joints array, so no remapping needed
  Some(@skeleton3d.SkinData::{
    joint_indices: raw_joints,
    weights,
    vertex_count,
  })
}

///|
/// Build AnimationClips from all glTF animations.
fn animations_from_gltf(
  doc : GltfDocument,
  skin_index : Int,
  buffers : Array[Bytes],
) -> Array[@animation3d.AnimationClip] raise GltfError {
  let skin = doc.skins[skin_index]
  // Create node-to-joint mapping for this skin
  let node_to_joint : Map[Int, Int] = {}
  for i in 0..<skin.joints.length() {
    node_to_joint[skin.joints[i]] = i
  }
  let clips : Array[@animation3d.AnimationClip] = []
  for anim in doc.animations {
    let channels : Array[@animation3d.AnimChannel] = []
    let mut duration = 0.0
    for gltf_channel in anim.channels {
      // Only include channels targeting joints in this skin
      let joint_idx = match node_to_joint.get(gltf_channel.target_node) {
        Some(j) => j
        None => continue
      }
      let sampler = anim.samplers[gltf_channel.sampler]
      let times = read_accessor_floats(doc, sampler.input, buffers)
      let values = read_accessor_floats(doc, sampler.output, buffers)
      // Update duration
      for t in times {
        if t > duration {
          duration = t
        }
      }
      let target : @animation3d.ChannelTarget = match gltf_channel.target_path {
        "translation" => Translation
        "rotation" => Rotation
        "scale" => Scale
        _ => continue
      }
      let interpolation : @animation3d.Interpolation = match
        sampler.interpolation {
        "STEP" => Step
        _ => Linear
      }
      channels.push(@animation3d.AnimChannel::{
        node_index: joint_idx,
        target,
        interpolation,
        times,
        values,
      })
    }
    if channels.length() > 0 {
      clips.push(@animation3d.AnimationClip::{
        name: anim.name,
        channels,
        duration,
      })
    }
  }
  clips
}
