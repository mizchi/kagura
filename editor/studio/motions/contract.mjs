import { projectPath } from "../projects/project.mjs";
const check = (ok, message) => {
  if (!ok) throw Error("Motion asset: " + message);
};
const finite = (n) =>
  typeof n === "number" && Number.isFinite(n) && Math.abs(n) <= 1e6;
const integer = (n, max) => Number.isInteger(n) && n >= 0 && n < max;
function record(value, keys) {
  check(
    value && typeof value === "object" && !Array.isArray(value),
    "expected an object",
  );
  check(
    Object.keys(value).length === keys.length &&
      Object.keys(value).every((k) => keys.includes(k)),
    "unknown or missing fields: " + keys.join(", "),
  );
}
function array(value, min, max) {
  check(
    Array.isArray(value) && value.length >= min && value.length <= max,
    "invalid array length",
  );
}
function text(value) {
  check(
    typeof value === "string" && value.length > 0 && value.length <= 160,
    "invalid name",
  );
}
function numbers(value, size) {
  array(value, size, size);
  check(value.every(finite), "nonfinite or excessive number");
}
function quaternion(values) {
  check(
    Math.abs(Math.hypot(...values) - 1) < 0.001,
    "rotation must be normalized XYZW",
  );
}
function unique(items, key) {
  const seen = new Set();
  for (const item of items) {
    text(item[key]);
    check(!seen.has(item[key]), "duplicate " + key);
    seen.add(item[key]);
  }
  return seen;
}
export const motionFormat = (path) =>
  typeof path === "string" && /\.kgrmotion$/i.test(path);

/** Portable bind geometry + local TRS channels. No executable code, renderer types or network URLs. */
export function validateMotionAsset(input) {
  record(input, ["format", "version", "name", "skeleton", "models", "clips"]);
  check(
    input.format === "kagura.motion" && input.version === 1,
    "unsupported format/version",
  );
  text(input.name);
  array(input.skeleton, 1, 64);
  unique(input.skeleton, "name");
  input.skeleton.forEach((bone, i) => {
    record(bone, ["name", "parent", "position", "rotation", "scale"]);
    check(
      bone.parent === -1 || integer(bone.parent, i),
      "parents must precede children",
    );
    numbers(bone.position, 3);
    numbers(bone.rotation, 4);
    quaternion(bone.rotation);
    numbers(bone.scale, 3);
    check(
      bone.scale.every((s) => s > 0),
      "bind scale must be positive",
    );
  });
  array(input.clips, 1, 128);
  const clips = unique(input.clips, "id");
  for (const clip of input.clips) {
    record(clip, ["id", "name", "duration", "fps", "events", "channels"]);
    text(clip.name);
    check(
      finite(clip.duration) && clip.duration > 0 && clip.duration <= 600,
      "invalid duration",
    );
    check(
      Number.isInteger(clip.fps) && clip.fps >= 1 && clip.fps <= 240,
      "invalid frame rate",
    );
    array(clip.events, 0, 128);
    for (const event of clip.events) {
      record(event, ["name", "time"]);
      text(event.name);
      check(
        finite(event.time) && event.time >= 0 && event.time <= clip.duration,
        "event outside clip",
      );
    }
    array(clip.channels, 1, input.skeleton.length * 3);
    const targets = new Set();
    for (const channel of clip.channels) {
      record(channel, ["joint", "target", "interpolation", "times", "values"]);
      check(
        integer(channel.joint, input.skeleton.length),
        "invalid channel joint",
      );
      check(
        ["translation", "rotation", "scale"].includes(channel.target),
        "unknown channel target",
      );
      check(
        ["linear", "step"].includes(channel.interpolation),
        "unsupported interpolation",
      );
      const key = channel.joint + ":" + channel.target;
      check(!targets.has(key), "duplicate channel target");
      targets.add(key);
      array(channel.times, 1, 144001);
      check(
        channel.times.every(
          (v, i) =>
            finite(v) &&
            v >= 0 &&
            v <= clip.duration + 1e-6 &&
            (!i || v > channel.times[i - 1]),
        ),
        "invalid keyframe times",
      );
      const stride = channel.target === "rotation" ? 4 : 3;
      numbers(channel.values, channel.times.length * stride);
      if (stride === 4)
        for (let i = 0; i < channel.values.length; i += 4)
          quaternion(channel.values.slice(i, i + 4));
    }
  }
  array(input.models, 1, 64);
  unique(input.models, "id");
  let vertices = 0;
  for (const model of input.models) {
    record(model, ["id", "name", "defaultClip", "parts"]);
    text(model.name);
    check(clips.has(model.defaultClip), "missing default clip");
    array(model.parts, 1, 64);
    for (const part of model.parts) {
      record(part, [
        "name",
        "color",
        "vertices",
        "indices",
        "joints",
        "weights",
      ]);
      text(part.name);
      numbers(part.color, 4);
      check(
        part.color.every((v) => v >= 0 && v <= 1),
        "color must be linear RGBA in 0..1",
      );
      array(part.vertices, 24, 8e6);
      check(part.vertices.length % 8 === 0, "vertices must use PNU stride 8");
      check(part.vertices.every(finite), "invalid vertex");
      const count = part.vertices.length / 8;
      vertices += count;
      check(vertices <= 1e6, "too many vertices");
      array(part.indices, 3, 6e6);
      check(
        part.indices.length % 3 === 0 &&
          part.indices.every((i) => integer(i, count)),
        "invalid triangle indices",
      );
      numbers(part.joints, count * 4);
      check(
        part.joints.every((i) => integer(i, input.skeleton.length)),
        "invalid skin joint",
      );
      numbers(part.weights, count * 4);
      check(
        part.weights.every((w) => w >= 0 && w <= 1),
        "invalid skin weight",
      );
      for (let i = 0; i < part.weights.length; i += 4)
        check(
          Math.abs(
            part.weights.slice(i, i + 4).reduce((a, b) => a + b, 0) - 1,
          ) < 0.001,
          "weights must sum to 1",
        );
    }
  }
  return structuredClone(input);
}
export async function prepareMotionAsset(resources, path) {
  projectPath(path);
  check(motionFormat(path), "expected .kgrmotion");
  const blob = await resources.read(path);
  check(blob.size <= 64 * 1024 * 1024, "exceeds 64 MiB");
  return validateMotionAsset(JSON.parse(await blob.text()));
}
