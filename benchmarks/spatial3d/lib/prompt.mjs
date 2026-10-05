// The one prompt every model sees. Changing this text changes the benchmark:
// bump PROMPT_VERSION and do not compare scores across versions.

export const PROMPT_VERSION = "spatial3d-prompt-v1";

export const SHAPE_DEFINITIONS = `All shapes are SOLID (filled), in a right-handed 3D coordinate system, same units on every axis.
- point: {position}. A single point.
- sphere: {center, radius}.
- aabb: axis-aligned box, {min, max} corners.
- obb: oriented box, {center, half_extents, axes}. axes[i] is the (unit) direction of the box's local axis i in world space; the box is every center + s0*axes[0] + s1*axes[1] + s2*axes[2] with |si| <= half_extents[i].
- segment: line segment {a, b}.
- capsule: every point within radius of segment {a, b}.
- cylinder: {a, b, radius}. a and b are the centers of the two flat circular caps.
- cone: {apex, base_center, radius}. A right circular cone; the flat circular base of the given radius is centered at base_center and perpendicular to the apex-base axis.
- triangle: flat triangle {vertices: [v0, v1, v2]} (zero thickness, interior included).
- tetrahedron: {vertices: [v0, v1, v2, v3]}, the solid convex hull of the four points.
- torus: {center, axis, major_radius, minor_radius}. Every point within minor_radius of the circle of radius major_radius around center that lies in the plane perpendicular to axis. The hole is empty.
Two shapes intersect when they share at least one point (overlap or containment both count). No pair merely touches: every answer is decided by a nonzero margin.`;

const PAIR_INSTRUCTIONS = `Decide whether objects A and B intersect.
End your reply with exactly one line:
ANSWER: YES
or
ANSWER: NO`;

const SCENE_INSTRUCTIONS = `List every pair of objects that intersect.
End your reply with exactly one line, pairs separated by commas, each pair written as two ids joined by "-" (e.g. "ANSWER: A-C, B-D"), or "ANSWER: NONE" if no pair intersects.`;

export function buildPrompt(problem) {
  const task = problem.task === "scene" ? SCENE_INSTRUCTIONS : PAIR_INSTRUCTIONS;
  return [
    "You are given 3D objects as exact coordinates. Reason about them geometrically.",
    "Do not use code execution or any other tools.",
    "",
    SHAPE_DEFINITIONS,
    "",
    "Objects:",
    ...problem.objects.map((o) => JSON.stringify(o)),
    "",
    task,
  ].join("\n");
}

// Several problems of the same task in one prompt, for chat interfaces and
// agent harnesses without an API. Replies are read back by import.mjs.
// Batching is a different condition from one-prompt-per-problem: record it.
export function buildBatchPrompt(task, problems) {
  const ask =
    task === "scene"
      ? "For EACH problem below, list every pair of objects that intersect. Problems are independent."
      : "For EACH problem below, decide whether objects A and B intersect. Problems are independent.";
  const format =
    task === "scene"
      ? "End your reply with one line per problem, in order: `<id>: A-C, B-D` or `<id>: NONE`."
      : "End your reply with one line per problem, in order: `<id>: YES` or `<id>: NO`.";
  return [
    "You are given 3D objects as exact coordinates. Reason about them geometrically.",
    "",
    SHAPE_DEFINITIONS,
    "",
    ask,
    "",
    ...problems.map((p) => `### ${p.id}\n` + p.objects.map((o) => JSON.stringify(o)).join("\n") + "\n"),
    format,
  ].join("\n");
}

// Returns true/false for pair tasks, a sorted array of "X-Y" for scene tasks,
// or null when the reply has no parsable answer line.
export function parseAnswer(task, text) {
  if (typeof text !== "string") return null;
  const lines = text.split(/\r?\n/).filter((l) => /ANSWER\s*:/i.test(l));
  if (lines.length === 0) return null;
  const body = lines[lines.length - 1]
    .replace(/^.*ANSWER\s*:/i, "")
    .replace(/[*`_]/g, "")
    .trim();
  if (task === "pair") {
    if (/^YES\b/i.test(body)) return true;
    if (/^NO\b/i.test(body)) return false;
    return null;
  }
  if (/^NONE\b/i.test(body)) return [];
  const pairs = [];
  for (const m of body.matchAll(/([A-Z])\s*[-–&/]\s*([A-Z])/g)) {
    const [x, y] = [m[1], m[2]].sort();
    if (x !== y) pairs.push(`${x}-${y}`);
  }
  return pairs.length > 0 ? [...new Set(pairs)].sort() : null;
}
