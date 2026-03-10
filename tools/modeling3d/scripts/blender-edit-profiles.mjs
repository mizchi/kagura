const EXCLUDED_FLOOR_IDS = new Set(["ground", "lily_pad"]);

const EXAMPLE_TARGETS = [
  {
    matchSourceIds: ["pedestal", "guide_orb", "clay_head"],
    primaryPrimitiveId: "pedestal",
    removablePrimitiveId: "guide_orb",
    sculptLayerId: "clay_head",
    helperSourceId: "blender_helper",
    helperName: "blender_helper",
    recolor: [0.890196, 0.611765, 0.329412, 1.0],
  },
  {
    matchSourceIds: ["seat_board", "right_side_brace", "seat_cushion"],
    primaryPrimitiveId: "seat_board",
    removablePrimitiveId: "right_side_brace",
    sculptLayerId: "seat_cushion",
    helperSourceId: "chair_helper",
    helperName: "chair_helper",
    recolor: [0.752941, 0.611765, 0.454902, 1.0],
  },
  {
    matchSourceIds: ["middle_shelf", "rear_brace", "crate_left"],
    primaryPrimitiveId: "middle_shelf",
    removablePrimitiveId: "rear_brace",
    helperSourceId: "shelf_helper",
    helperName: "shelf_helper",
    recolor: [0.721569, 0.572549, 0.392157, 1.0],
  },
  {
    matchSourceIds: ["left_eye_white", "right_pupil", "frog_body"],
    primaryPrimitiveId: "left_eye_white",
    removablePrimitiveId: "right_pupil",
    sculptLayerId: "frog_body",
    helperSourceId: "frog_helper",
    helperName: "frog_helper",
    recolor: [0.941176, 0.815686, 0.376471, 1.0],
  },
];

const PROFILE_ALIASES = new Map([
  ["pedestal_move_recolor", "primary_move_recolor"],
  ["chair_seat_move_recolor", "primary_move_recolor"],
  ["frog_eye_move_recolor", "primary_move_recolor"],
  ["guide_orb_delete", "secondary_delete"],
  ["chair_brace_delete", "secondary_delete"],
  ["frog_pupil_delete", "secondary_delete"],
  ["clay_head_stamp_count_increment", "sculpt_stamp_count_increment"],
  ["seat_cushion_stamp_count_increment", "sculpt_stamp_count_increment"],
  ["frog_body_stamp_count_increment", "sculpt_stamp_count_increment"],
  ["blender_helper_add", "helper_add"],
  ["chair_helper_add", "helper_add"],
  ["frog_helper_add", "helper_add"],
  ["pedestal_kind_mismatch", "primary_kind_mismatch"],
  ["chair_kind_mismatch", "primary_kind_mismatch"],
  ["frog_kind_mismatch", "primary_kind_mismatch"],
  ["roundtrip_diff_bundle", "roundtrip_diff_bundle"],
  ["chair_roundtrip_diff_bundle", "roundtrip_diff_bundle"],
  ["shelf_roundtrip_diff_bundle", "roundtrip_diff_bundle"],
  ["frog_roundtrip_diff_bundle", "roundtrip_diff_bundle"],
]);

function normalizeProfile(profile) {
  return PROFILE_ALIASES.get(profile) ?? profile;
}

function alternatePrimitiveKind(kind) {
  switch (kind) {
    case "sphere":
      return "cube";
    case "plane":
      return "cube";
    default:
      return "sphere";
  }
}

function resolveProfileTargets(expected) {
  const nodes = Array.isArray(expected?.nodes) ? expected.nodes : [];
  const sourceIds = new Set(nodes.map((node) => node.source_id).filter(Boolean));
  const primitives = nodes.filter((node) => node.node_kind === "primitive");
  const sculptLayers = nodes.filter((node) => node.node_kind === "sculpt_layer");
  const matchedConfig = EXAMPLE_TARGETS.find((config) =>
    config.matchSourceIds.every((sourceId) => sourceIds.has(sourceId)),
  );

  if (matchedConfig != null) {
    const primary = primitives.find((node) => node.source_id === matchedConfig.primaryPrimitiveId);
    const removable = primitives.find((node) => node.source_id === matchedConfig.removablePrimitiveId);
    const sculpt = matchedConfig.sculptLayerId == null
      ? null
      : sculptLayers.find((node) => node.source_id === matchedConfig.sculptLayerId);
    if (primary == null || removable == null) {
      throw new Error("matched example targets were incomplete");
    }
    return {
      primary,
      removable,
      sculpt,
      helperSourceId: matchedConfig.helperSourceId,
      helperName: matchedConfig.helperName,
      recolor: matchedConfig.recolor,
    };
  }

  const primary =
    primitives.find(
      (node) =>
        node.primitive_kind !== "plane" &&
        !EXCLUDED_FLOOR_IDS.has(node.source_id),
    ) ??
    primitives.find((node) => !EXCLUDED_FLOOR_IDS.has(node.source_id)) ??
    primitives[0] ??
    null;
  const removable =
    primitives.find(
      (node) =>
        node.source_id !== primary?.source_id &&
        !EXCLUDED_FLOOR_IDS.has(node.source_id),
    ) ??
    primitives.find((node) => node.source_id !== primary?.source_id) ??
    null;
  const sculpt = sculptLayers[0] ?? null;
  if (primary == null) {
    throw new Error("could not resolve a primary primitive target");
  }
  if (removable == null) {
    throw new Error("could not resolve a removable primitive target");
  }
  return {
    primary,
    removable,
    sculpt,
    helperSourceId: `${primary.source_id}_helper`,
    helperName: `${primary.source_id}_helper`,
    recolor: [0.8, 0.65, 0.45, 1.0],
  };
}

export function buildBlenderEditRecipe(expected, profile) {
  const normalizedProfile = normalizeProfile(profile);
  const targets = resolveProfileTargets(expected);
  const primaryKind = typeof targets.primary.primitive_kind === "string"
    ? targets.primary.primitive_kind
    : "cube";
  const primaryMoveRecolor = {
    type: "move_recolor",
    source_id: targets.primary.source_id,
    location_delta: [0.2, 0.0, 0.0],
    scale_multiplier: [1.0, 1.0, 1.15],
    base_color: targets.recolor,
  };
  const secondaryDelete = {
    type: "delete",
    source_id: targets.removable.source_id,
  };
  const sculptStampCountIncrement = targets.sculpt == null
    ? null
    : {
        type: "increment_stamp_count",
        source_id: targets.sculpt.source_id,
        increment: 1,
      };
  const helperAdd = {
    type: "duplicate_helper",
    source_id: targets.primary.source_id,
    new_source_id: targets.helperSourceId,
    new_name: targets.helperName,
    location: [1.2, 0.0, 0.0],
    scale: [0.2, 0.2, 0.2],
    node_kind: "primitive",
    primitive_kind: "cube",
    color_hex: "AAAAAA",
  };
  const primaryKindMismatch = {
    type: "set_primitive_kind",
    source_id: targets.primary.source_id,
    primitive_kind: alternatePrimitiveKind(primaryKind),
  };

  switch (normalizedProfile) {
    case "primary_move_recolor":
      return {
        profile,
        normalizedProfile,
        operations: [primaryMoveRecolor],
      };
    case "secondary_delete":
      return {
        profile,
        normalizedProfile,
        operations: [secondaryDelete],
      };
    case "sculpt_stamp_count_increment":
      if (sculptStampCountIncrement == null) {
        throw new Error(`edit profile ${profile} requires a sculpt layer target`);
      }
      return {
        profile,
        normalizedProfile,
        operations: [sculptStampCountIncrement],
      };
    case "helper_add":
      return {
        profile,
        normalizedProfile,
        operations: [helperAdd],
      };
    case "primary_kind_mismatch":
      return {
        profile,
        normalizedProfile,
        operations: [primaryKindMismatch],
      };
    case "roundtrip_diff_bundle":
      return {
        profile,
        normalizedProfile,
        operations: [
          primaryMoveRecolor,
          secondaryDelete,
          ...(sculptStampCountIncrement == null ? [] : [sculptStampCountIncrement]),
          helperAdd,
        ],
      };
    default:
      throw new Error(`unknown edit profile: ${profile}`);
  }
}
