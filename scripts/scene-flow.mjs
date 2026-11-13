import {readFileSync} from 'node:fs';
import {inspectSceneFlow} from '../game/scene_flow/inspect.mjs';

const args = process.argv.slice(2);
const format = args.includes('--mermaid') ? 'mermaid' : args.includes('--json') ? 'json' : 'text';
const files = args.filter(a => a !== '--mermaid' && a !== '--json');
try {
  if (files.length !== 1 || (files[0].startsWith('-') && files[0] !== '-'))
    throw Error('Usage: node scripts/scene-flow.mjs [--json | --mermaid] <definition.json | ->');
  const result = inspectSceneFlow(JSON.parse(readFileSync(files[0] === '-' ? 0 : files[0], 'utf8')));
  if (format === 'mermaid') process.stdout.write(result.mermaid);
  else if (format === 'json') console.log(JSON.stringify(result, null, 2));
  else {
    console.log(`${result.definition.scenes.length} scenes / ${result.definition.transitions.length} transitions / ${result.report.issues.length} issues`);
    for (const issue of result.report.issues)
      console.log(`${issue.severity}: ${issue.code} · ${issue.scene}${issue.transition >= 0 ? ` · transition #${issue.transition}` : ''}`);
  }
  process.exitCode = result.report.issues.length ? 1 : 0;
} catch (error) {
  console.error(error.message);
  process.exitCode = 2;
}
