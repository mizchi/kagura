///|
pub fn project_slug(name : String) -> String {
  let text = StringBuilder()
  let mut separator = false
  let mut numeric_start = false
  for ch in name.to_lower() {
    if (ch >= 'a' && ch <= 'z') || (ch >= '0' && ch <= '9') {
      if text.is_empty() {
        numeric_start = ch >= '0' && ch <= '9'
      } else if separator {
        text.write_char('_')
      }
      separator = false
      text.write_char(ch)
    } else {
      separator = true
    }
  }
  if text.is_empty() {
    "game"
  } else if numeric_start {
    "game_" + text.to_string()
  } else {
    text.to_string()
  }
}

///|
/// Derive a module-safe name from a lexically resolved destination on either host.
pub fn project_name(directory : String, current_dir : String) -> String {
  let directory = directory.replace_all(old="\\", new="/")
  let path = if directory.has_prefix("/") || directory.contains(":") {
    directory
  } else {
    current_dir.replace_all(old="\\", new="/") + "/" + directory
  }
  let parts : Array[String] = []
  for part in path.split("/") {
    if part == ".." {
      let _ = parts.pop()
    } else if part != "" && part != "." {
      parts.push(part.to_owned())
    }
  }
  project_slug(parts.last().unwrap_or("game"))
}

///|
/// Template selection and substitutions stay in the portable command layer.
pub fn scaffold_files(name : String) -> String {
  let name = project_slug(name)
  let files : Map[String, Json] = Map([])
  for (path, content) in web_template_files {
    files[path] = content
      .replace_all(old="__PROJECT_NAME__", new=name)
      .to_json()
  }
  files.to_json().stringify()
}
