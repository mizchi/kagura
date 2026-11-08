import fs from "node:fs"
import path from "node:path"
import process from "node:process"
import { spawnSync } from "node:child_process"
import { pathToFileURL } from "node:url"

function read_stdin() {
  return new Promise((resolve, reject) => {
    let text = ""
    process.stdin.setEncoding("utf8")
    process.stdin.on("data", (chunk) => {
      text += chunk
    })
    process.stdin.on("end", () => resolve(text))
    process.stdin.on("error", reject)
  })
}

export function resolveV8ModuleRoot(module_root) {
  let root = path.resolve(module_root)
  for (;;) {
    const candidate = path.join(root, ".mooncakes", "mizchi", "v8")
    if (["moon.mod", "moon.mod.json"].some(name => fs.existsSync(path.join(candidate, name)))) {
      return candidate
    }
    const parent = path.dirname(root)
    if (parent === root) break
    root = parent
  }
  throw new Error("failed to locate mizchi/v8 in the workspace dependency cache")
}

function platform_link_flags(platform, module_root) {
  const archive_path = path.join(
    module_root,
    "target",
    "rusty_v8_bridge",
    "release",
    "librusty_v8_bridge.a",
  )
  switch (platform) {
    case "darwin":
      return `${archive_path} -lc++ -pthread -framework CoreFoundation`
    case "linux":
      return `${archive_path} -lstdc++ -ldl -pthread`
    default:
      throw new Error(
        `mizchi/v8 consumer setup does not support host platform ${platform}`,
      )
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(path.resolve(process.argv[1])).href) {
const raw_input = await read_stdin()
const input = raw_input.trim() === "" ? {} : JSON.parse(raw_input)
const module_root = input.paths?.module_root ?? process.cwd()
const v8_root = resolveV8ModuleRoot(module_root)
const build_script = path.join(v8_root, "src", "scripts", "build-rusty-v8.sh")
const stamp_path = path.join(v8_root, "src", "build-stamps", "rusty_v8_build.stamp")

const result = spawnSync("bash", [build_script, stamp_path], {
  cwd: v8_root,
  env: process.env,
  stdio: "inherit",
})

if (result.status !== 0) {
  process.exit(result.status ?? 1)
}

process.stdout.write(
  JSON.stringify({
    vars: {
      MIZCHI_V8_CC_LINK_FLAGS: platform_link_flags(process.platform, v8_root),
    },
  }),
)

}
