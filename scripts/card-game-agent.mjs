#!/usr/bin/env node
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { mkdir, open, readFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { AgentError, int32 } from '../examples/games/card_game/agent/errors.mjs';

const root = fileURLToPath(new URL('../', import.meta.url));
const help = `Ember Ascent — Jev headless player (Node 24+, no browser or renderer)

just card-game-agent [options]
  --seed N                 Deterministic signed 32-bit seed (default: 42)
  --model NAME             TypeSafe model (default: jev-latest)
  --max-decisions N        Stop after N choices (default: 500, maximum: 10000)
  --character NAME         ironclad | warden; supply together with --stage
  --stage NAME             ascent | act_two | guardian_trial
  --out FILE               JSONL decision log (default: output/card-game-agent/...)
  --profile FILE           Literal key assignment (default: ~/.profile)
  --dry-run                Print observation and choice request; no key or API needed
  --replay FILE            Verify a recorded run without API requests
  --no-build               Use the previously built agent_host module
  --quiet                  Print only the final JSON summary
  --help                   Show this help

Without character/stage options, Jev chooses from the title and menus.
TYPESAFE_API_KEY (or TYPESAFEAI_API_KEY) overrides ~/.profile. Keys are never
printed, sent to the game, or written to logs. A limit is an incomplete run.
`;

function parseArgs(args) {
  const options = { seed: 42, model: 'jev-latest', maxDecisions: 500 };
  const flags = new Map([['--seed', 'seed'], ['--model', 'model'], ['--max-decisions', 'maxDecisions'],
    ['--character', 'character'], ['--stage', 'stage'], ['--out', 'out'], ['--profile', 'profilePath'], ['--replay', 'replay']]);
  const switches = new Map([['--dry-run', 'dryRun'], ['--no-build', 'noBuild'], ['--quiet', 'quiet'], ['--help', 'help']]);
  for (let i = 0; i < args.length; i++) {
    if (switches.has(args[i])) { options[switches.get(args[i])] = true; continue; }
    const key = flags.get(args[i]);
    if (!key || !args[i + 1] || args[i + 1].startsWith('--')) throw new AgentError('invalid_input', `unknown or incomplete option: ${args[i]}`);
    options[key] = ['seed', 'maxDecisions'].includes(key) ? Number(args[++i]) : args[++i];
  }
  if (options.help) return options;
  int32(options.seed, 'seed');
  if (!Number.isInteger(options.maxDecisions) || options.maxDecisions < 1 || options.maxDecisions > 10000) {
    throw new AgentError('invalid_input', 'max-decisions must be in [1, 10000]');
  }
  if ((options.character === undefined) !== (options.stage === undefined)) throw new AgentError('invalid_input', 'character and stage must be supplied together');
  if (options.character !== undefined && !['ironclad', 'warden'].includes(options.character)) throw new AgentError('invalid_input', 'unknown character');
  if (options.stage !== undefined && !['ascent', 'act_two', 'guardian_trial'].includes(options.stage)) throw new AgentError('invalid_input', 'unknown stage');
  if (options.replay && options.dryRun) throw new AgentError('invalid_input', 'replay and dry-run cannot be combined');
  return options;
}

function resultJson(result, log) {
  return { status: result.status, decisions: result.decisions, phase: result.observation.phase,
    floor: result.observation.run?.floor ?? null, hp: result.observation.run?.hp ?? null,
    usage: result.usage, elapsedMs: result.elapsedMs, log, ...(result.replayed ? { replayed: true } : {}) };
}

async function main() {
  const options = parseArgs(process.argv.slice(2));
  if (options.help) { process.stdout.write(help); return; }
  if (!options.noBuild) {
    await promisify(execFile)('moon', ['-C', 'examples/games/card_game', 'build', 'agent_host', '--target', 'js', '--release'],
      { cwd: root, maxBuffer: 4 * 1024 * 1024 });
  }
  const { createHeadlessSession } = await import('../examples/games/card_game/agent/headless.mjs');
  const { runAgent, replayRecords } = await import('../examples/games/card_game/agent/runner.mjs');
  if (options.replay) {
    const records = (await readFile(options.replay, 'utf8')).split('\n').filter(line => line.trim()).map(line => JSON.parse(line));
    const result = replayRecords(records);
    process.stdout.write(`${JSON.stringify(resultJson(result, resolve(options.replay)))}\n`);
    return;
  }
  const { JevClient, makeJevRequest, loadApiKey } = await import('../examples/games/card_game/agent/jev.mjs');
  const session = createHeadlessSession(options);
  if (options.dryRun) {
    const observation = session.observe();
    process.stdout.write(`${JSON.stringify({ observation, request: makeJevRequest(observation, options.model) }, null, 2)}\n`);
    return;
  }
  const client = new JevClient({ apiKey: await loadApiKey({ profilePath: options.profilePath }), model: options.model });
  const log = resolve(options.out ?? `output/card-game-agent/seed-${options.seed}-${new Date().toISOString().replaceAll(':', '-')}.jsonl`);
  await mkdir(dirname(log), { recursive: true });
  // Existing evidence is never overwritten; the caller can choose a new path.
  const file = await open(log, 'wx', 0o600);
  try {
    const result = await runAgent({ ...options, session, choose: state => client.choose(state),
      onRecord: async record => {
        await file.write(`${JSON.stringify(record)}\n`);
        if (!options.quiet && record.type === 'decision') {
          const choice = record.before.choices.find(c => c.id === record.choiceId);
          process.stderr.write(`[${record.index}] ${record.before.phase} floor=${record.before.run?.floor ?? '-'} ` +
            `${choice.label} confidence=${record.decision.confidence.toFixed(2)} ${record.decision.elapsedMs}ms\n`);
        }
      } });
    process.stdout.write(`${JSON.stringify(resultJson(result, log))}\n`);
  } finally { await file.close(); }
}

main().catch(error => {
  // Only our bounded, redacted errors are printable. Never dump fetch objects,
  // profile contents, exception stacks, or provider response bodies.
  process.stderr.write(`${error instanceof AgentError ? error.message : 'agent_failed: see the decision log or check build/files'}\n`);
  process.exitCode = 1;
});
