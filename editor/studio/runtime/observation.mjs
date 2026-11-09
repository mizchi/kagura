import { validateInspection } from "./inspection.mjs";

/** Published observations are read-only. A render snapshot is not writable game state. */
export function readRuntimeObservation(realm, game) {
  const scene = realm?.kaguraSceneRuntime;
  let source, state, inspection;
  if (
    scene?.apiVersion === 1 &&
    (typeof scene.observe === "function" ||
      typeof scene.snapshot === "function")
  ) {
    if (scene.game !== game) throw Error("Runtime observation game mismatch");
    source = "scene";
    if (typeof scene.observe === "function") {
      const payload = scene.observe();
      if (!payload || !Object.hasOwn(payload, "state"))
        throw Error("Invalid runtime observation");
      ({ state, inspection } = payload);
    } else state = scene.snapshot();
  } else if (typeof realm?.kaguraGame?.snapshot === "function") {
    source = "game";
    state = realm.kaguraGame.snapshot();
    if (state == null) return null;
  } else if (realm?.__kaguraUISnapshot?.parsed) {
    source = "ui";
    state = realm.__kaguraUISnapshot.parsed;
  } else if (typeof realm?.__kaguraGfx?.lastRenderCpuMs === "function") {
    const graphics = realm.__kaguraGfx;
    source = "renderer";
    state = {
      renderCpuMs: graphics.lastRenderCpuMs(),
      completedFrameMs: graphics.lastCompletedFrameMs?.() ?? null,
      timingMethod: graphics.gpuTimingMethod?.() ?? null,
    };
  } else return null;
  if (["undefined", "function", "symbol", "bigint"].includes(typeof state))
    throw Error("Invalid runtime observation state");
  const result = { game, source, readonly: true, state };
  if (inspection !== undefined) result.inspection = inspection;
  const json = JSON.stringify(result, (_, value) => {
    if (typeof value === "number" && !Number.isFinite(value))
      throw Error("Invalid observation number");
    return value;
  });
  if (!json || new TextEncoder().encode(json).byteLength > 4 * 1024 * 1024)
    throw Error("Runtime observation exceeds 4 MiB");
  const detached = JSON.parse(json);
  if (detached.inspection !== undefined) {
    const value = detached.inspection;
    if (
      !value ||
      typeof value.scope !== "string" ||
      !value.scope.length ||
      value.scope.length > 256
    )
      throw Error("Invalid observation inspection scope");
    if (Object.keys(value).some((key) => !["scope", "subjects"].includes(key)))
      throw Error("Invalid observation inspection");
    validateInspection(value.subjects);
    if (
      value.subjects.some((subject) =>
        subject.fields.some((field) => field.access !== "readonly"),
      )
    )
      throw Error("Observed inspection fields must be read only");
  }
  return detached;
}
