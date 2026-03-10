import { buildModelAuthoringVlmHandoffPlan } from "./model-authoring-vlm-handoff-utils.mjs";

export function parseVlmDaemonCommand(line) {
  let parsed;
  try {
    parsed = JSON.parse(line);
  } catch (error) {
    throw new Error(`invalid daemon command JSON: ${String(error.message ?? error)}`);
  }
  if (parsed == null || typeof parsed !== "object") {
    throw new Error("daemon command must be an object");
  }
  if (parsed.op === "shutdown") {
    return { op: "shutdown" };
  }
  if (parsed.op === "run") {
    return {
      op: "run",
      cycle:
        Number.isFinite(parsed.cycle) && parsed.cycle > 0
          ? parsed.cycle
          : null,
      outDir:
        typeof parsed.outDir === "string" && parsed.outDir.length > 0
          ? parsed.outDir
          : null,
      reviewBinarize: parsed.reviewBinarize === true,
    };
  }
  throw new Error(`unknown daemon op: ${String(parsed.op)}`);
}

export function buildDaemonCyclePlan(basePlan, command) {
  if (command.op !== "run") {
    throw new Error("buildDaemonCyclePlan expects a run command");
  }
  return buildModelAuthoringVlmHandoffPlan({
    cwd: process.cwd(),
    example: basePlan.example,
    liveReview: true,
    renderer: basePlan.renderer,
    serve: false,
    url: basePlan.url,
    port: basePlan.port,
    outDir: command.outDir ?? basePlan.outDir,
    provider: basePlan.provider,
    preset: basePlan.preset,
    model: basePlan.model,
    apiUrl: basePlan.apiUrl,
    apiKeyEnv: basePlan.apiKeyEnv,
    execute: basePlan.execute,
    headed: basePlan.headed,
    interactive: false,
    cycles: 1,
    reviewBinarize: command.reviewBinarize ?? basePlan.reviewBinarize,
    timeoutMs: basePlan.timeoutMs,
  });
}
