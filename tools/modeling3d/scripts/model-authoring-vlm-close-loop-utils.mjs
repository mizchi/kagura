import { join, resolve } from "node:path";

export function extractJsonDocument(stdout) {
  const normalized = typeof stdout === "string" ? stdout : String(stdout ?? "");
  const start = normalized.indexOf("{\n");
  const fallbackStart = normalized.trimStart().startsWith("{")
    ? normalized.indexOf("{")
    : -1;
  const jsonStart = start >= 0 ? start : fallbackStart;
  if (jsonStart < 0) {
    throw new Error("JSON payload was not found in command output");
  }
  return JSON.parse(normalized.slice(jsonStart).trim());
}

export function summarizeBundlePatchPayload(bundle) {
  return {
    auto_actions: bundle?.patch_payload?.auto_actions?.length ?? 0,
    manual_actions: bundle?.patch_payload?.manual_actions?.length ?? 0,
    opt_in_remove_source_ids: bundle?.patch_payload?.opt_in_remove_source_ids ?? [],
    opt_in_append_source_ids: bundle?.patch_payload?.opt_in_append_source_ids ?? [],
    issues: (bundle?.patch_payload?.manual_issue_details ?? []).map((issue) => ({
      source_id: issue?.source_id ?? "",
      issue_kind: issue?.action_kind ?? issue?.issue_kind ?? "",
    })),
  };
}

export function shouldApplyBundlePatch(summary) {
  return (
    (summary?.auto_actions ?? 0) > 0 ||
    (summary?.opt_in_remove_source_ids?.length ?? 0) > 0 ||
    (summary?.opt_in_append_source_ids?.length ?? 0) > 0
  );
}

export function buildVlmCloseLoopPlan({
  cwd = process.cwd(),
  example = "model_authoring",
  editProfile = null,
  importGlb = null,
  provider = "openrouter",
  port = 8113,
  outDir = null,
  write = false,
} = {}) {
  const rootDir = resolve(cwd);
  if ((editProfile == null) === (importGlb == null)) {
    throw new Error("exactly one of editProfile or importGlb is required");
  }
  const exampleStem = example.replace(/_/g, "-");
  const resolvedOutDir = resolve(
    rootDir,
    outDir ?? `output/playwright/${exampleStem}-close-loop`,
  );
  return {
    cwd: rootDir,
    example,
    provider,
    port,
    residualPort: port + 1,
    write,
    initialArgs:
      editProfile != null
        ? [
            "--example",
            example,
            "--edit-profile",
            editProfile,
            "--provider",
            provider,
            "--serve",
            "--port",
            String(port),
            "--out-dir",
            join(resolvedOutDir, "initial"),
            "--execute",
          ]
        : [
            "--example",
            example,
            "--import-glb",
            importGlb,
            "--provider",
            provider,
            "--serve",
            "--port",
            String(port),
            "--out-dir",
            join(resolvedOutDir, "initial"),
            "--execute",
          ],
    feedbackOutDir: join(resolvedOutDir, "feedback"),
    residualOutDir: join(resolvedOutDir, "residual"),
    exampleDir: join(rootDir, "tools", "modeling3d", "examples", example),
  };
}
