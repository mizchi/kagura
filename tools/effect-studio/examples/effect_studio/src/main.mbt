///|
extern "js" fn js_publish_effect_studio_context(
  context_json : String,
  summary : String,
) -> Unit =
  #| (contextJson, summary) => {
  #|   let parsed = null;
  #|   try {
  #|     parsed = JSON.parse(contextJson);
  #|   } catch (_err) {}
  #|   globalThis.__kaguraEffectStudioContext = {
  #|     json: contextJson,
  #|     summary,
  #|     parsed,
  #|   };
  #|   console.log("[kagura:effect-studio]\\n" + summary);
  #| };

///|
extern "js" fn js_download_text_file(filename : String, text : String) -> Unit =
  #| (filename, text) => {
  #|   globalThis.__kaguraEffectStudioDownload = { filename, text };
  #|   const blob = new Blob([text], { type: "text/plain;charset=utf-8" });
  #|   const url = URL.createObjectURL(blob);
  #|   const anchor = document.createElement("a");
  #|   anchor.href = url;
  #|   anchor.download = filename;
  #|   anchor.style.display = "none";
  #|   document.body.appendChild(anchor);
  #|   anchor.click();
  #|   anchor.remove();
  #|   setTimeout(() => URL.revokeObjectURL(url), 0);
  #| };

///|
extern "js" fn js_publish_effect_studio_exports(
  bundle_filename : String,
  bundle_text : String,
  review_filename : String,
  review_text : String,
) -> Unit =
  #| (bundleFilename, bundleText, reviewFilename, reviewText) => {
  #|   globalThis.__kaguraEffectStudioExports = {
  #|     downloadBundle() {
  #|       globalThis.__kaguraEffectStudioDownload = { filename: bundleFilename, text: bundleText };
  #|       const blob = new Blob([bundleText], { type: "application/json;charset=utf-8" });
  #|       const url = URL.createObjectURL(blob);
  #|       const anchor = document.createElement("a");
  #|       anchor.href = url;
  #|       anchor.download = bundleFilename;
  #|       anchor.style.display = "none";
  #|       document.body.appendChild(anchor);
  #|       anchor.click();
  #|       anchor.remove();
  #|       setTimeout(() => URL.revokeObjectURL(url), 0);
  #|     },
  #|     downloadReview() {
  #|       globalThis.__kaguraEffectStudioDownload = { filename: reviewFilename, text: reviewText };
  #|       const blob = new Blob([reviewText], { type: "text/markdown;charset=utf-8" });
  #|       const url = URL.createObjectURL(blob);
  #|       const anchor = document.createElement("a");
  #|       anchor.href = url;
  #|       anchor.download = reviewFilename;
  #|       anchor.style.display = "none";
  #|       document.body.appendChild(anchor);
  #|       anchor.click();
  #|       anchor.remove();
  #|       setTimeout(() => URL.revokeObjectURL(url), 0);
  #|     },
  #|   };
  #| };

///|
fn main {
  let state = EffectStudioState::new()
  @engine.run(
    update=fn(input) {
      state.update(input)
      js_publish_effect_studio_exports(
        state.patch_bundle_filename(),
        state.patch_bundle_json(),
        state.review_prompt_filename(),
        state.review_prompt_markdown(),
      )
      if state.bundle_download_requested() {
        js_download_text_file(
          state.patch_bundle_filename(),
          state.patch_bundle_json(),
        )
      }
      if state.review_download_requested() {
        js_download_text_file(
          state.review_prompt_filename(),
          state.review_prompt_markdown(),
        )
      }
      js_publish_effect_studio_context(
        state.context_json(),
        state.context_summary(),
      )
    },
    draw=fn(ctx) { state.draw(ctx) },
    width=screen_w,
    height=screen_h,
    title="Effect Studio",
    canvas="#app",
  )
}
