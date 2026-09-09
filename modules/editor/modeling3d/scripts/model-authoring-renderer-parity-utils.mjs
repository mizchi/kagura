import { join, resolve } from "node:path";

export function buildRendererParityArtifacts({
  cwd = process.cwd(),
  outDir = null,
  example = "model_authoring",
} = {}) {
  const rootDir = resolve(
    cwd,
    outDir ?? `output/playwright/${example.replace(/_/g, "-")}-renderer-parity`,
  );
  return {
    rootDir,
    webDir: join(rootDir, "web"),
    nativeDir: join(rootDir, "native"),
    webBinarizedDir: join(rootDir, "web-binarized"),
    nativeBinarizedDir: join(rootDir, "native-binarized"),
    reportPath: join(rootDir, "parity-report.json"),
  };
}

export function summarizeRendererParity({
  sameCurrentDocument,
  sameSummary,
  silhouetteDiffRatio,
  silhouetteDiffThreshold,
  visualMeanAbsRgbDiff,
  visualMeanAbsRgbThreshold,
}) {
  const issues = [];
  const visualIssues = [];
  if (!sameCurrentDocument) {
    issues.push("current_document mismatch");
  }
  if (!sameSummary) {
    issues.push("workbench_summary mismatch");
  }
  if (silhouetteDiffRatio > silhouetteDiffThreshold) {
    issues.push(
      `silhouette diff ratio ${silhouetteDiffRatio.toFixed(4)} exceeds threshold ${silhouetteDiffThreshold.toFixed(4)}`,
    );
  }
  if (visualMeanAbsRgbDiff > visualMeanAbsRgbThreshold) {
    visualIssues.push(
      `visual mean abs rgb diff ${visualMeanAbsRgbDiff.toFixed(4)} exceeds threshold ${visualMeanAbsRgbThreshold.toFixed(4)}`,
    );
  }
  return {
    ok: issues.length === 0 && visualIssues.length === 0,
    silhouetteOk: issues.length === 0,
    visualOk: visualIssues.length === 0,
    issues,
    visualIssues,
  };
}
