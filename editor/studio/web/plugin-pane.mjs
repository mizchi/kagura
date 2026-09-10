/** Portable plugins get a usable default pane even when the guest has no DOM runtime. */
export function pluginPane(manifest, plugins, editor) {
  return ({ element, signal }) => {
    const heading = document.createElement('h2'); heading.textContent = manifest.title;
    const select = document.createElement('select'); select.setAttribute('aria-label', 'Plugin tool');
    for (const tool of manifest.tools) { const option = document.createElement('option'); option.value = tool.name; option.textContent = tool.name; select.append(option); }
    const description = document.createElement('p');
    const argumentsInput = document.createElement('textarea'); argumentsInput.setAttribute('aria-label', 'Plugin arguments JSON'); argumentsInput.rows = 6; argumentsInput.value = '{}';
    const schema = document.createElement('pre'), output = document.createElement('pre'); output.setAttribute('aria-label', 'Plugin result');
    const run = document.createElement('button'); run.textContent = 'Run plugin tool'; run.disabled = manifest.tools.length === 0;
    const refresh = () => { const tool = manifest.tools.find(tool => tool.name === select.value); description.textContent = tool?.description ?? 'No tools'; schema.textContent = JSON.stringify(tool?.inputSchema ?? {}, null, 2); };
    select.addEventListener('change', refresh, { signal }); refresh();
    run.addEventListener('click', async () => {
      run.disabled = true;
      try {
        const result = await plugins.invoke(manifest.id, select.value, JSON.parse(argumentsInput.value), { expectedRevision: editor.snapshot().revision, signal });
        if (!signal.aborted) output.textContent = JSON.stringify(result, null, 2);
      } catch (error) { if (!signal.aborted) output.textContent = error.message; }
      finally { run.disabled = false; }
    }, { signal });
    element.append(heading, select, description, schema, argumentsInput, run, output);
  };
}
