/** Read explicit simulation controls independently of writable debug snapshots. */
export function readRuntimeControl(realm, game) {
  const runtime = realm?.kaguraSceneRuntime;
  if (runtime?.apiVersion !== 1) return null;
  if (runtime.game !== game) throw Error("Runtime control game mismatch");
  if (
    typeof runtime.pause !== "function" ||
    typeof runtime.paused !== "function"
  )
    return null;
  return Object.freeze({
    pause: () => runtime.pause(true),
    resume: () => runtime.pause(false),
    paused() {
      const value = runtime.paused();
      if (typeof value !== "boolean")
        throw Error("Invalid runtime pause state");
      return value;
    },
  });
}
