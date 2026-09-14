#!/usr/bin/env node
// Portable command logic is generated from MoonBit; Node owns host I/O.
import {resolve} from 'node:path';
import {parseCli, helpText, scaffoldFiles, projectName} from './cli.generated.js';
import {executeRequest} from './host.mjs';

try {
  const request = JSON.parse(parseCli(process.argv.slice(2)));
  if (request.ok && request.command === 'help') {
    console.log(helpText());
  } else {
    const options = {checkoutRoot: resolve(import.meta.dirname, '../..')};
    if (request.ok && request.command === 'new') {
      const {runtimeFiles} = await import('./generate.mjs');
      options.files = JSON.parse(scaffoldFiles(projectName(request.directory, process.cwd())));
      options.runtime = runtimeFiles();
    }
    process.exitCode = await executeRequest(request, options);
  }
} catch (error) {
  console.error(`kagura: ${error.message ?? error}`);
  process.exitCode = error.exitCode ?? 1;
}
