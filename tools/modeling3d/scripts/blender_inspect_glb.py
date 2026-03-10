#!/usr/bin/env python3

import json
import os
import sys


def find_principled(material):
    if material is None or not getattr(material, "use_nodes", False):
        return None
    for node in material.node_tree.nodes:
        if node.type == "BSDF_PRINCIPLED":
            return node
    return None


def material_summary(material):
    principled = find_principled(material)
    base_color = [1.0, 1.0, 1.0, 1.0]
    metallic = 0.0
    roughness = 0.5
    if principled is not None:
      base_color = list(principled.inputs["Base Color"].default_value[:4])
      metallic = float(principled.inputs["Metallic"].default_value)
      roughness = float(principled.inputs["Roughness"].default_value)
    elif material is not None:
      base_color = list(material.diffuse_color[:4])
    return {
        "name": material.name if material is not None else "",
        "double_sided": False if material is None else (not material.use_backface_culling),
        "base_color": base_color,
        "metallic": metallic,
        "roughness": roughness,
    }


def object_summary(obj):
    materials = []
    if obj.type == "MESH":
        for slot in obj.material_slots:
            if slot.material is not None:
                materials.append(material_summary(slot.material))
    custom_properties = {}
    for key in obj.keys():
        if key.startswith("_"):
            continue
        value = obj[key]
        if isinstance(value, (str, int, float, bool)):
            custom_properties[key] = value
    return {
        "name": obj.name,
        "type": obj.type,
        "location": list(obj.location[:3]),
        "scale": list(obj.scale[:3]),
        "rotation_euler": list(obj.rotation_euler[:3]),
        "custom_properties": custom_properties,
        "materials": materials,
    }


def main():
    argv = sys.argv
    if "--" not in argv:
        raise SystemExit("expected glb path after --")
    glb_path = argv[argv.index("--") + 1]

    import bpy

    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=glb_path)

    mesh_objects = [obj for obj in bpy.context.scene.objects if obj.type == "MESH"]
    materials = []
    seen = set()
    for obj in mesh_objects:
        for slot in obj.material_slots:
            material = slot.material
            if material is None or material.name in seen:
                continue
            seen.add(material.name)
            materials.append(material_summary(material))

    print(
        json.dumps(
            {
                "file": os.path.basename(glb_path),
                "objects": [object_summary(obj) for obj in mesh_objects],
                "materials": materials,
            },
            sort_keys=True,
        )
    )


if __name__ == "__main__":
    main()
