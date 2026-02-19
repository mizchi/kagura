import { spawnSync } from "node:child_process";
import { expect, test, type Page } from "@playwright/test";

type SmokeResult = {
  status: string;
  output: string;
  payloadTextureSeed: number;
};

const runMoon = (args: string[]) => {
  const result = spawnSync("moon", args, {
    cwd: process.cwd(),
    encoding: "utf8",
    env: {
      ...process.env,
      NO_COLOR: "1",
    },
  });
  return {
    status: result.status ?? -1,
    stdout: result.stdout ?? "",
    stderr: result.stderr ?? "",
  };
};

const loadSmokeResult = async (page: Page, path: string) => {
  await page.goto(path);
  await page.waitForFunction(() => {
    return Boolean((window as { __wasmSmoke?: { status?: string } }).__wasmSmoke?.status);
  });
  const result = await page.evaluate(() => {
    return (window as { __wasmSmoke?: SmokeResult }).__wasmSmoke;
  });
  expect(result).toBeTruthy();
  return result as SmokeResult;
};

const WEB_PROBE_RE =
  /runtime_smoke_web_probe:\s*tex_seed=(\d+)\s+atlas_gen=(\d+)\s+atlas_rgb=(\d+),(\d+),(\d+)/;
const NATIVE_PROBE_RE =
  /runtime_smoke_native_probe:\s*tex_seed=(\d+)\s+source_gen=(\d+)\s+atlas_gen=(\d+)\s+atlas_rgb=(\d+),(\d+),(\d+)/;

test.describe("runtime smoke cross backend parity", () => {
  test.skip(process.platform !== "darwin", "native smoke is macOS-only");
  test.setTimeout(120_000);

  test("web/native probe metrics stay in sync", async ({ page }) => {
    const web = await loadSmokeResult(page, "/e2e/fixtures/runtime_smoke_wasm.html");
    expect(web.status).toBe("ok");
    const webProbe = web.output.match(WEB_PROBE_RE);
    expect(webProbe, web.output).not.toBeNull();
    if (webProbe == null) {
      return;
    }
    const webSeed = Number(webProbe[1]);
    const webAtlasGen = Number(webProbe[2]);
    const webR = Number(webProbe[3]);
    const webG = Number(webProbe[4]);
    const webB = Number(webProbe[5]);
    expect(webSeed).toBe(801);

    const native = runMoon(["run", "src/examples/runtime_smoke_native", "--target", "native"]);
    const nativeOutput = `${native.stdout}\n${native.stderr}`;
    expect(native.status, nativeOutput).toBe(0);
    const nativeProbe = nativeOutput.match(NATIVE_PROBE_RE);
    expect(nativeProbe, nativeOutput).not.toBeNull();
    if (nativeProbe == null) {
      return;
    }
    const nativeSeed = Number(nativeProbe[1]);
    const nativeAtlasGen = Number(nativeProbe[3]);
    const nativeR = Number(nativeProbe[4]);
    const nativeG = Number(nativeProbe[5]);
    const nativeB = Number(nativeProbe[6]);

    expect(webSeed).toBe(801);
    expect(nativeSeed).toBe(901);
    expect(webAtlasGen).toBe(nativeAtlasGen);
    expect(webR).toBe(nativeR);
    expect(webG).toBe(nativeG);
    expect(webB).toBe(nativeB);
  });
});
