///|
let tripo_base_url : String = "https://api.tripo3d.ai/v2/openapi"

///|
fn tripo_headers(api_key : String) -> String {
  let obj : Json = {
    "Content-Type": "application/json".to_json(),
    "Authorization": ("Bearer " + api_key).to_json(),
  }
  obj.stringify()
}

///|
/// Submit a text-to-model task.
/// Returns (task_id, error_message).
fn tripo_text_to_model(api_key : String, prompt : String) -> (String, String) {
  let body : Json = {
    "type": "text_to_model".to_json(),
    "prompt": prompt.to_json(),
  }
  let result = js_http_post(
    tripo_base_url + "/task",
    tripo_headers(api_key),
    body.stringify(),
  )
  if result.has_prefix("ERROR:") {
    return ("", result)
  }
  parse_task_id(result)
}

///|
/// Submit a rig_model task (Mixamo-compatible skeleton).
fn tripo_rig_model(
  api_key : String,
  original_task_id : String,
) -> (String, String) {
  let body : Json = {
    "type": "rig_model".to_json(),
    "original_model_task_id": original_task_id.to_json(),
    "out_format": "glb".to_json(),
  }
  let result = js_http_post(
    tripo_base_url + "/task",
    tripo_headers(api_key),
    body.stringify(),
  )
  if result.has_prefix("ERROR:") {
    return ("", result)
  }
  parse_task_id(result)
}

///|
/// Submit a retarget_animation task.
fn tripo_retarget_animation(
  api_key : String,
  original_task_id : String,
  animation : String,
) -> (String, String) {
  let anim_entry : Json = { "animation": animation.to_json() }
  let body : Json = {
    "type": "retarget_animation".to_json(),
    "original_model_task_id": original_task_id.to_json(),
    "out_format": "glb".to_json(),
    "animations": [anim_entry].to_json(),
  }
  let result = js_http_post(
    tripo_base_url + "/task",
    tripo_headers(api_key),
    body.stringify(),
  )
  if result.has_prefix("ERROR:") {
    return ("", result)
  }
  parse_task_id(result)
}

///|
/// Poll a task until it reaches "success" or "failed".
/// Returns (status, model_url, error_message).
fn tripo_poll_task(
  api_key : String,
  task_id : String,
  max_polls : Int,
  interval_sec : Int,
) -> (String, String, String) {
  for i = 0; i < max_polls; i = i + 1 {
    let result = js_http_get(
      tripo_base_url + "/task/" + task_id,
      tripo_headers(api_key),
    )
    if result.has_prefix("ERROR:") {
      return ("error", "", result)
    }
    let (status, model_url) = parse_task_status(result)
    if status == "success" {
      return ("success", model_url, "")
    }
    if status == "failed" {
      return ("failed", "", "Task failed")
    }
    let msg = "  [" + (i + 1).to_string() + "/" + max_polls.to_string() + "] status: " + status
    println(msg)
    js_sleep(interval_sec)
  }
  (
    "timeout",
    "",
    "Polling timeout after " + max_polls.to_string() + " attempts",
  )
}

///|
/// Download a file from URL to local path.
fn tripo_download(
  api_key : String,
  url : String,
  output_path : String,
) -> String {
  js_download_file(url, tripo_headers(api_key), output_path)
}

///|
/// Parse task_id from Tripo API response.
fn parse_task_id(json_str : String) -> (String, String) {
  let json = try {
    @json.parse(json_str)
  } catch {
    _ => return ("", "Failed to parse JSON: " + json_str)
  }
  match json {
    {
      "code": Number(code, ..),
      "data": { "task_id": String(task_id), .. },
      ..
    } =>
      if code == 0.0 {
        (task_id, "")
      } else {
        ("", "API error code: " + code.to_string())
      }
    _ => ("", "Unexpected response format: " + json_str)
  }
}

///|
/// Parse task status and model URL from poll response.
fn parse_task_status(json_str : String) -> (String, String) {
  let json = try {
    @json.parse(json_str)
  } catch {
    _ => return ("error", "")
  }
  match json {
    { "data": { "status": String(status), "output": output, .. }, .. } => {
      let model_url = match output {
        { "model": String(url), .. } => url
        _ => ""
      }
      (status, model_url)
    }
    _ => ("error", "")
  }
}
