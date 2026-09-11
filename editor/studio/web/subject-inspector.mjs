/** Generic form generated from game-owned descriptors; selection is only a logical ID. */
export function createSubjectInspector(host, setStatus) {
  const panel = document.createElement('section');
  panel.setAttribute('aria-label', 'Selected runtime subject');
  let selected, session;
  function render() {
    panel.replaceChildren();
    const inspection = host.debug('inspect');
    if (session && session !== inspection.session) selected = undefined;
    session = inspection.session;
    const subject = inspection.subjects.find((value) => value.id === selected);
    const heading = document.createElement('h3');
    heading.textContent = subject?.name ?? 'Hierarchy で対象を選択';
    panel.append(heading);
    if (!subject) return;
    for (const field of subject.fields) {
      const form = document.createElement('form');
      const label = document.createElement('label');
      label.textContent = field.label + (field.unit ? ' · ' + field.unit : '');
      const input = document.createElement('input');
      input.setAttribute('aria-label', subject.name + ' ' + field.label);
      input.type =
        field.kind === 'number' ? 'number' : field.kind === 'boolean' ? 'checkbox' : 'text';
      input.step = 'any';
      if (field.kind === 'boolean') input.checked = field.value;
      else input.value = String(field.value);
      input.disabled = field.access !== 'runtime' || !inspection.paused;
      label.append(input);
      form.append(label);
      if (field.access === 'runtime') {
        const button = document.createElement('button');
        button.textContent = 'Apply ' + field.label;
        button.disabled = !inspection.paused;
        form.append(button);
      } else {
        const note = document.createElement('span');
        note.textContent = 'Read only';
        form.append(note);
      }
      form.addEventListener('submit', (event) => {
        event.preventDefault();
        try {
          const value =
            field.kind === 'number'
              ? input.valueAsNumber
              : field.kind === 'boolean'
                ? input.checked
                : input.value;
          host.debug('edit', { subject: subject.id, field: field.id, value }, inspection);
          setStatus('Runtime field applied · ' + subject.name + ' / ' + field.label);
        } catch (error) {
          setStatus('Error · ' + error.message);
        }
      });
      panel.append(form);
    }
  }
  return {
    panel,
    render,
    select(subject) {
      selected = subject;
      render();
    },
  };
}
