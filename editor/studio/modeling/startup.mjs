/** URL decoding belongs to the browser host. Unrelated workspace modes are ignored. */
export function readModelingStartup(url) {
  const params = new URL(url).searchParams;
  if (!params.getAll("mode").includes("modeling")) return null;
  for (const key of ["mode", "model"]) {
    if (params.getAll(key).length > 1)
      throw new Error("Duplicate modeling parameter: " + key);
  }
  const requestedModel = params.get("model");
  // Preserve previously shared links using the old spelling.
  const model = requestedModel === "kawaiiko" ? "kawaiko" : requestedModel;
  // The current built-in model is the MoonBit editor's initial kawaiko document.
  if (model !== null && model !== "kawaiko")
    throw new Error("Unknown modeling model: " + model);
  return { model };
}
