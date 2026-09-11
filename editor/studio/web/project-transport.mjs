/** Shell-owned controls. Game extensions expose behavior without inserting toolbar DOM. */
export function installProjectTransport(host, setStatus) {
  const group = document.createElement('div');
  group.className = 'project-transport';
  group.setAttribute('role', 'group');
  group.setAttribute('aria-label', 'Project controls');
  let busy = false,
    disposed = false;
  const button = (label, action) => {
    const node = document.createElement('button');
    node.type = 'button';
    node.textContent = label;
    node.addEventListener('click', async () => {
      busy = true;
      render();
      try {
        await action();
      } catch (error) {
        setStatus('Error · ' + error.message);
      } finally {
        busy = false;
        if (!disposed) render();
      }
    });
    return node;
  };
  const edit = button('Edit', () => host.edit());
  const play = button('Play', () => host.play());
  const stop = button('Stop', () => host.stop());
  const pause = button('Pause', () =>
    host.transport().paused ? host.debug('resume', host.debug('snapshot')) : host.debug('pause'),
  );
  const step = button('Step', () => host.debug('step', host.debug('snapshot')));
  play.className = 'primary';
  group.append(edit, play, pause, step, stop);
  const toolbar = document.querySelector('.viewport-toolbar');
  toolbar.prepend(group);
  function render() {
    const state = host.transport();
    group.hidden = !state.available;
    edit.disabled = busy;
    play.disabled = busy || !state.canPlay || state.playing;
    stop.disabled = busy || !state.playing;
    pause.hidden = step.hidden = !state.debugging;
    pause.textContent = state.paused ? 'Resume' : 'Pause';
    pause.disabled = busy;
    step.disabled = busy || !state.paused;
    toolbar.classList.toggle('showing-game', state.playing);
  }
  const unsubscribe = host.subscribe(render);
  render();
  return {
    dispose() {
      disposed = true;
      unsubscribe();
      group.remove();
      toolbar.classList.remove('showing-game');
    },
  };
}
