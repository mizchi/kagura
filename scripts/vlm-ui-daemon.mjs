#!/usr/bin/env node

/**
 * Keep a prepared example bundle warm and accept review jobs over HTTP.
 *
 * The modeling3d daemon holds a browser page. Game UI has no page — the CPU
 * rasterizer is the capture path — so this holds the JS bundle instead.
 * Each POST /review is one state: render, deterministic gate, then VLM
 * unless `--dry-run` is on the daemon or the body.
 *
 *   just vlm-ui-daemon-start ui_demo
 *   curl -sS localhost:9124/health
 *   curl -sS -X POST localhost:9124/review -d '{"state":"idle.standard","dryRun":true}'
 */

import { createServer } from "node:http";
import { join } from "node:path";

import { prepareBundle } from "./render-frame.mjs";
import { matrixReviewJobs, reviewOne } from "./vlm-ui-review.mjs";

export function parseDaemonArgs(argv) {
  const options = { example: null, host: "127.0.0.1", port: 9124, dryRun: true, build: true, help: false };
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === "-h" || arg === "--help") options.help = true;
    else if (arg === "--dry-run") options.dryRun = true;
    else if (arg === "--execute") options.dryRun = false;
    else if (arg === "--no-build") options.build = false;
    else if (arg === "--host") options.host = argv[++i];
    else if (arg === "--port") options.port = Number(argv[++i]);
    else if (arg.startsWith("-")) throw new Error(`unknown option: ${arg}`);
    else if (options.example === null) options.example = arg;
    else throw new Error(`unexpected extra argument: ${arg}`);
  }
  if (!options.help && options.example === null) throw new Error("missing <example>");
  if (!options.help && (!Number.isInteger(options.port) || options.port <= 0)) {
    throw new Error("--port wants a positive integer");
  }
  return options;
}

export function daemonUsage() {
  return [
    "Usage: node scripts/vlm-ui-daemon.mjs <example> [options]",
    "",
    "Holds the example's JS bundle and serves review jobs.",
    "  GET  /health",
    "  POST /review   JSON body: {state, frames, width, height, dryRun, forceVlm}",
    "",
    "Options:",
    "  --host <addr>     Bind address (default 127.0.0.1)",
    "  --port <n>        Bind port (default 9124)",
    "  --dry-run         Default: do not call the VLM (the modeling loop's habit)",
    "  --execute         Call the VLM when the deterministic gate is clean",
    "  --no-build        Use the existing _build output",
  ].join("\n");
}

export async function createUiReviewDaemon(options) {
  const prepared = prepareBundle(options.example, { build: options.build });
  const { renderHeadlessFrame } = await import("../assets/web/kagura-headless-frame.js");
  const jobs = matrixReviewJobs(prepared.exampleDir);
  const server = createServer(async (req, res) => {
    try {
      if (req.method === "GET" && req.url === "/health") {
        json(res, 200, { ok: true, example: options.example, cells: jobs.map((job) => job.state) });
        return;
      }
      if (req.method === "POST" && req.url === "/review") {
        const body = JSON.parse(await readBody(req));
        const job = resolveJob(jobs, body);
        const code = await reviewOne({
          example: options.example,
          ...job,
          ...body,
          dryRun: body.dryRun ?? options.dryRun,
          forceVlm: body.forceVlm === true,
          notes: body.notes ?? [],
          provider: options.provider ?? "openrouter",
          model: options.model ?? null,
          compare: body.compare ?? null,
          bundlePath: prepared.bundlePath,
          renderHeadlessFrame,
          outDir: body.outDir ?? join(process.cwd(), "output", "ui-review", options.example),
        });
        json(res, 200, { ok: code === 0, state: job.state });
        return;
      }
      json(res, 404, { ok: false, error: "not found" });
    } catch (error) {
      json(res, 400, { ok: false, error: error.message });
    }
  });
  await new Promise((resolve, reject) => {
    server.listen(options.port, options.host, (error) => (error ? reject(error) : resolve()));
  });
  return { server, prepared, jobs };
}

function resolveJob(jobs, body) {
  if (typeof body.state === "string") {
    const match = jobs.find((job) => job.state === body.state);
    if (match) return match;
  }
  return {
    state: body.state ?? "default",
    frames: body.frames ?? 1,
    width: body.width ?? null,
    height: body.height ?? null,
    initialState: body.initialState,
    inputs: body.inputs,
    cursorX: body.cursorX ?? null,
    cursorY: body.cursorY ?? null,
    keys: body.keys ?? [],
  };
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    req.on("data", (chunk) => chunks.push(chunk));
    req.on("end", () => resolve(Buffer.concat(chunks).toString("utf8") || "{}"));
    req.on("error", reject);
  });
}

function json(res, status, body) {
  const payload = JSON.stringify(body);
  res.writeHead(status, { "content-type": "application/json", "content-length": Buffer.byteLength(payload) });
  res.end(payload);
}

async function main(argv) {
  const options = parseDaemonArgs(argv);
  if (options.help) {
    process.stdout.write(`${daemonUsage()}\n`);
    return 0;
  }
  const { server } = await createUiReviewDaemon(options);
  const addr = server.address();
  process.stdout.write(`vlm-ui-daemon ${options.example} on http://${options.host}:${addr.port}\n`);
  process.stdout.write("GET /health  POST /review\n");
  return 0;
}

if (process.argv[1] === new URL(import.meta.url).pathname) {
  main(process.argv.slice(2)).then(
    (code) => {
      process.exitCode = code;
    },
    (error) => {
      process.stderr.write(`${error.message}\n`);
      process.exitCode = 1;
    },
  );
}
