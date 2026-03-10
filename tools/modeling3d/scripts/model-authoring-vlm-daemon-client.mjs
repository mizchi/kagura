#!/usr/bin/env node

import { createConnection } from "node:net";

function usage() {
  console.error(
    [
      "Usage: node tools/modeling3d/scripts/model-authoring-vlm-daemon-client.mjs \\",
      "  [--host 127.0.0.1] [--port 9123] (--run | --shutdown) \\",
      "  [--cycle 1] [--out-dir output/playwright/daemon-run] [--binarize-review]",
    ].join("\n"),
  );
}

function parseArgs(argv) {
  const options = {
    host: "127.0.0.1",
    port: 9123,
    cycle: 1,
    op: null,
    outDir: null,
    reviewBinarize: false,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    switch (arg) {
      case "--host":
        options.host = argv[index + 1];
        index += 1;
        break;
      case "--port":
        options.port = Number(argv[index + 1]);
        index += 1;
        break;
      case "--run":
        options.op = "run";
        break;
      case "--shutdown":
        options.op = "shutdown";
        break;
      case "--cycle":
        options.cycle = Number(argv[index + 1]);
        index += 1;
        break;
      case "--out-dir":
        options.outDir = argv[index + 1];
        index += 1;
        break;
      case "--binarize-review":
        options.reviewBinarize = true;
        break;
      default:
        throw new Error(`unknown argument: ${arg}`);
    }
  }
  if (options.op == null) {
    throw new Error("either --run or --shutdown is required");
  }
  if (!Number.isFinite(options.port) || options.port <= 0) {
    throw new Error("--port must be > 0");
  }
  if (!Number.isFinite(options.cycle) || options.cycle <= 0) {
    throw new Error("--cycle must be > 0");
  }
  return options;
}

function buildCommand(options) {
  if (options.op === "shutdown") {
    return { op: "shutdown" };
  }
  return {
    op: "run",
    cycle: options.cycle,
    outDir: options.outDir,
    reviewBinarize: options.reviewBinarize,
  };
}

async function requestDaemon({ host, port, command }) {
  return new Promise((resolve, reject) => {
    const socket = createConnection({ host, port });
    let buffer = "";
    socket.setEncoding("utf8");
    socket.once("connect", () => {
      socket.write(`${JSON.stringify(command)}\n`);
    });
    socket.on("data", (chunk) => {
      buffer += chunk;
      const newlineIndex = buffer.indexOf("\n");
      if (newlineIndex < 0) {
        return;
      }
      const line = buffer.slice(0, newlineIndex);
      try {
        resolve(JSON.parse(line));
      } catch (error) {
        reject(error);
      }
      socket.end();
    });
    socket.once("error", reject);
  });
}

async function main() {
  let options;
  try {
    options = parseArgs(process.argv.slice(2));
  } catch (error) {
    usage();
    console.error(String(error.message ?? error));
    process.exit(1);
  }
  const response = await requestDaemon({
    host: options.host,
    port: options.port,
    command: buildCommand(options),
  });
  console.log(JSON.stringify(response, null, 2));
}

main().catch((error) => {
  console.error(String(error.stack ?? error));
  process.exit(1);
});
