///|
/// Tripo AI → GLB pipeline PoC
///
/// Usage:
///   TRIPO_API_KEY=tsk_xxx moon run src/ --target js
///
/// Optional env vars:
///   TRIPO_PROMPT      - text prompt (default: "a simple humanoid character")
///   TRIPO_ANIMATION   - animation preset (default: "idle")
///   TRIPO_OUTPUT      - output path (default: "output.glb")
///   TRIPO_SKIP_RIG    - set to "1" to skip rigging step
///   TRIPO_SKIP_ANIM   - set to "1" to skip animation step
fn main {
  let api_key = js_get_env("TRIPO_API_KEY")
  if api_key.is_empty() {
    println("ERROR: TRIPO_API_KEY environment variable is required")
    println("Get your API key from: https://platform.tripo3d.ai/api-keys")
    return
  }
  let prompt = {
    let p = js_get_env("TRIPO_PROMPT")
    if p.is_empty() {
      "a simple humanoid character"
    } else {
      p
    }
  }
  let animation = {
    let a = js_get_env("TRIPO_ANIMATION")
    if a.is_empty() {
      "idle"
    } else {
      a
    }
  }
  let output_path = {
    let o = js_get_env("TRIPO_OUTPUT")
    if o.is_empty() {
      "output.glb"
    } else {
      o
    }
  }
  let skip_rig = js_get_env("TRIPO_SKIP_RIG") == "1"
  let skip_anim = js_get_env("TRIPO_SKIP_ANIM") == "1"

  // Step 1: Text to model
  println("=== Step 1: Text to Model ===")
  println("Prompt: " + prompt)
  let (model_task_id, err) = tripo_text_to_model(api_key, prompt)
  if not(err.is_empty()) {
    println("ERROR: " + err)
    return
  }
  println("Task ID: " + model_task_id)
  println("Polling for completion...")
  let (status, _model_url, err2) = tripo_poll_task(
    api_key,
    model_task_id,
    60,
    5,
  )
  if status != "success" {
    println("ERROR: Model generation " + status + ": " + err2)
    return
  }
  println("Model generation complete!")
  let mut current_task_id = model_task_id

  // Step 2: Rig model (optional)
  if not(skip_rig) {
    println("\n=== Step 2: Rig Model ===")
    let (rig_task_id, err3) = tripo_rig_model(api_key, current_task_id)
    if not(err3.is_empty()) {
      println("ERROR: " + err3)
      return
    }
    println("Rig Task ID: " + rig_task_id)
    println("Polling for completion...")
    let (rig_status, _rig_url, rig_err) = tripo_poll_task(
      api_key,
      rig_task_id,
      60,
      5,
    )
    if rig_status != "success" {
      println("ERROR: Rigging " + rig_status + ": " + rig_err)
      return
    }
    println("Rigging complete!")
    current_task_id = rig_task_id
  }

  // Step 3: Retarget animation (optional)
  if not(skip_anim) && not(skip_rig) {
    println("\n=== Step 3: Retarget Animation ===")
    println("Animation: " + animation)
    let (anim_task_id, err4) = tripo_retarget_animation(
      api_key,
      current_task_id,
      animation,
    )
    if not(err4.is_empty()) {
      println("ERROR: " + err4)
      return
    }
    println("Animation Task ID: " + anim_task_id)
    println("Polling for completion...")
    let (anim_status, _anim_url, anim_err) = tripo_poll_task(
      api_key,
      anim_task_id,
      60,
      5,
    )
    if anim_status != "success" {
      println("ERROR: Animation " + anim_status + ": " + anim_err)
      return
    }
    println("Animation retargeting complete!")
    current_task_id = anim_task_id
  }

  // Step 4: Download the final GLB
  println("\n=== Step 4: Download GLB ===")
  // Poll to get the download URL
  let (_, download_url, _) = tripo_poll_task(api_key, current_task_id, 1, 0)
  if download_url.is_empty() {
    println("ERROR: No download URL found for task " + current_task_id)
    return
  }
  println("Downloading from: " + download_url)
  let dl_result = tripo_download(api_key, download_url, output_path)
  if dl_result != "OK" {
    println("ERROR: Download failed: " + dl_result)
    return
  }
  println("Saved to: " + output_path)
  println("\n=== Pipeline Complete ===")
}
