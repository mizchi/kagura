import { resolve } from "node:path";

export const NATIVE_CAPTURE_CONFIG_FILENAME = "kagura_native_capture_config.txt";

export function buildNativeCaptureConfig({
  screenshotPath,
  contextPath,
  summaryPath,
  binarize = false,
}) {
  return [
    `screenshot_path=${resolve(screenshotPath)}`,
    `context_path=${resolve(contextPath)}`,
    `summary_path=${resolve(summaryPath)}`,
    `binarize=${binarize ? "1" : "0"}`,
    "",
  ].join("\n");
}

export function resolveNativeExampleDir({ cwd = process.cwd(), example }) {
  return resolve(cwd, "tools", "modeling3d", "examples", example);
}

export function resolveNativeCaptureStagePath({
  cwd = process.cwd(),
  example,
}) {
  return resolve(
    resolveNativeExampleDir({ cwd, example }),
    NATIVE_CAPTURE_CONFIG_FILENAME,
  );
}
