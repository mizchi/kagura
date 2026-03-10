#!/usr/bin/env python3

import os
import json
import sys


def find_object(scene_objects, name):
    for obj in scene_objects:
        try:
            if obj.name == name:
                return obj
        except ReferenceError:
            continue
    raise SystemExit(f"object not found: {name}")


def find_material(obj, material_name=None):
    if obj.type != "MESH":
        raise SystemExit(f"object is not mesh: {obj.name}")
    if material_name is None and len(obj.material_slots) > 0:
        return obj.material_slots[0].material
    for slot in obj.material_slots:
        material = slot.material
        if material is not None and material.name == material_name:
            return material
    raise SystemExit(f"material not found on object {obj.name}: {material_name}")


def find_principled(material):
    if material is None or not getattr(material, "use_nodes", False):
        return None
    for node in material.node_tree.nodes:
        if node.type == "BSDF_PRINCIPLED":
            return node
    return None


def apply_delete(scene_objects, source_id):
    import bpy

    obj = find_object_by_source_id(scene_objects, source_id)
    bpy.data.objects.remove(obj, do_unlink=True)


def find_object_by_source_id(scene_objects, source_id):
    for obj in scene_objects:
        try:
            if obj.get("kagura_source_id") == source_id:
                return obj
        except ReferenceError:
            continue
    raise SystemExit(f"object not found for kagura_source_id: {source_id}")


def apply_increment_stamp_count(scene_objects, source_id, increment):
    obj = find_object_by_source_id(scene_objects, source_id)
    stamp_count = int(obj.get("kagura_stamp_count", 0))
    obj["kagura_stamp_count"] = stamp_count + int(increment)


def apply_move_recolor(scene_objects, source_id, location_delta, scale_multiplier, base_color):
    obj = find_object_by_source_id(scene_objects, source_id)
    delta = location_delta or [0.0, 0.0, 0.0]
    multiplier = scale_multiplier or [1.0, 1.0, 1.0]
    obj.location.x += float(delta[0] if len(delta) > 0 else 0.0)
    obj.location.y += float(delta[1] if len(delta) > 1 else 0.0)
    obj.location.z += float(delta[2] if len(delta) > 2 else 0.0)
    obj.scale.x *= float(multiplier[0] if len(multiplier) > 0 else 1.0)
    obj.scale.y *= float(multiplier[1] if len(multiplier) > 1 else 1.0)
    obj.scale.z *= float(multiplier[2] if len(multiplier) > 2 else 1.0)
    material = find_material(obj)
    principled = find_principled(material)
    if principled is None:
        raise SystemExit(f"{obj.name} does not use Principled BSDF")
    color = base_color or [1.0, 1.0, 1.0, 1.0]
    principled.inputs["Base Color"].default_value = (
        float(color[0] if len(color) > 0 else 1.0),
        float(color[1] if len(color) > 1 else 1.0),
        float(color[2] if len(color) > 2 else 1.0),
        float(color[3] if len(color) > 3 else 1.0),
    )


def apply_duplicate_helper(scene_objects, source_id, new_source_id, new_name, location, scale, node_kind, primitive_kind, color_hex):
    import bpy

    source = find_object_by_source_id(scene_objects, source_id)
    helper = source.copy()
    helper.data = source.data.copy()
    helper.animation_data_clear()
    helper.name = new_name
    helper.location = (
        float(location[0] if len(location) > 0 else 0.0),
        float(location[1] if len(location) > 1 else 0.0),
        float(location[2] if len(location) > 2 else 0.0),
    )
    helper.scale = (
        float(scale[0] if len(scale) > 0 else 1.0),
        float(scale[1] if len(scale) > 1 else 1.0),
        float(scale[2] if len(scale) > 2 else 1.0),
    )
    helper["kagura_source_id"] = new_source_id
    helper["kagura_node_kind"] = node_kind
    helper["kagura_primitive_kind"] = primitive_kind
    helper["kagura_color_hex"] = color_hex
    bpy.context.scene.collection.objects.link(helper)


def apply_set_primitive_kind(scene_objects, source_id, primitive_kind):
    obj = find_object_by_source_id(scene_objects, source_id)
    obj["kagura_primitive_kind"] = primitive_kind


def apply_recipe(scene_objects, recipe):
    operations = recipe.get("operations", [])
    for operation in operations:
        operation_type = operation.get("type")
        if operation_type == "move_recolor":
            apply_move_recolor(
                scene_objects,
                operation.get("source_id"),
                operation.get("location_delta", []),
                operation.get("scale_multiplier", []),
                operation.get("base_color", []),
            )
        elif operation_type == "delete":
            apply_delete(scene_objects, operation.get("source_id"))
        elif operation_type == "increment_stamp_count":
            apply_increment_stamp_count(
                scene_objects,
                operation.get("source_id"),
                operation.get("increment", 1),
            )
        elif operation_type == "duplicate_helper":
            apply_duplicate_helper(
                scene_objects,
                operation.get("source_id"),
                operation.get("new_source_id"),
                operation.get("new_name"),
                operation.get("location", []),
                operation.get("scale", []),
                operation.get("node_kind", "primitive"),
                operation.get("primitive_kind", "cube"),
                operation.get("color_hex", "AAAAAA"),
            )
        elif operation_type == "set_primitive_kind":
            apply_set_primitive_kind(
                scene_objects,
                operation.get("source_id"),
                operation.get("primitive_kind", "cube"),
            )
        else:
            raise SystemExit(f"unknown recipe operation: {operation_type}")


def main():
    argv = sys.argv
    if "--" not in argv:
        raise SystemExit("expected input path, output path, and profile after --")
    args = argv[argv.index("--") + 1 :]
    if len(args) < 2:
        raise SystemExit("expected input path and output path after --")
    input_path = args[0]
    output_path = args[1]
    profile = args[2] if len(args) >= 3 else "pedestal_move_recolor"

    import bpy

    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=input_path)

    scene_objects = list(bpy.context.scene.objects)
    recipe_json = os.environ.get("KAGURA_EDIT_RECIPE")
    if recipe_json:
        apply_recipe(scene_objects, json.loads(recipe_json))
    else:
        raise SystemExit("KAGURA_EDIT_RECIPE is required")

    os.makedirs(os.path.dirname(output_path) or ".", exist_ok=True)
    bpy.ops.export_scene.gltf(
        filepath=output_path,
        export_format="GLB",
        export_extras=True,
        export_yup=True,
        use_selection=False,
    )

    print(
        f"edited_glb: {os.path.basename(input_path)} -> {os.path.basename(output_path)} ({profile})"
    )


if __name__ == "__main__":
    main()
