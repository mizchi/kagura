// Matches app/character.mbt. Existing body and coat indices remain stable.
const definitions = [
  ["root", -1, [0, 0, 0]],
  ["torso", 0, [0, 0.55, 0], "Spine3"],
  [
    "r_upper_arm",
    1,
    [0.24, 0.63, 0],
    "R_Shoulder",
    "R_Elbow",
    [0.3, 0.46, 0.02],
  ],
  ["r_forearm", 2, [0.3, 0.46, 0.02], "R_Elbow", "R_Wrist", [0.33, 0.33, 0.08]],
  ["sword", 3, [0.33, 0.33, 0.08]],
  ["head", 1, [0, 0.7, 0], "Head"],
  [
    "l_upper_arm",
    1,
    [-0.24, 0.63, 0],
    "L_Shoulder",
    "L_Elbow",
    [-0.3, 0.46, 0.02],
  ],
  [
    "l_forearm",
    6,
    [-0.3, 0.46, 0.02],
    "L_Elbow",
    "L_Wrist",
    [-0.32, 0.3, 0.08],
  ],
  ["l_thigh", 0, [-0.115, 0.38, 0], "L_Hip", "L_Knee", [-0.115, 0.2, 0]],
  ["l_shin", 8, [-0.115, 0.2, 0], "L_Knee", "L_Ankle", [-0.115, 0.055, 0.045]],
  ["r_thigh", 0, [0.115, 0.38, 0], "R_Hip", "R_Knee", [0.115, 0.2, 0]],
  ["r_shin", 10, [0.115, 0.2, 0], "R_Knee", "R_Ankle", [0.115, 0.055, 0.045]],
  ["coat_l", 1, [-0.12, 0.46, -0.14]],
  ["coat_r", 1, [0.12, 0.46, -0.14]],
  ["bow", 7, [-0.32, 0.3, 0.08]],
  ["bow_string", 14, [-0.32, 0.3, -0.05]],
  ["nocked_arrow", 15, [-0.32, 0.3, -0.05]],
];
export const hunterMotionProfile = {
  joints: definitions.map(
    ([name, parent, position, source, sourceTip, tip]) => ({
      name,
      parent,
      position,
      source,
      sourceTip,
      tip,
      aimWeapon: name === "sword",
    }),
  ),
  bow: { handJoint: 3, handPosition: [0.33, 0.33, 0.08] },
  soles: [9, 11].flatMap((joint) =>
    [-0.1, 0.19].map((z) => ({
      joint,
      position: [joint === 9 ? -0.115 : 0.115, 0, z],
    })),
  ),
};
