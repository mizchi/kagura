import { defaults, validSizes, clamp, columnGeometry, rowGeometry, resizeColumns } from './layout-state.mjs';

const STORAGE = 'kagura.studio.pane-sizes.v1';
export function createWorkspaceLayout(workspace) {
  const columns = [...workspace.querySelectorAll('[data-column]')];
  const handles = [...workspace.querySelectorAll('[data-split]')];
  let layouts = { scene: defaults('scene'), action: defaults('action') };
  try {
    const saved = JSON.parse(localStorage.getItem(STORAGE));
    for (const name of ['scene', 'action']) if (validSizes(saved?.[name])) layouts[name] = saved[name];
  } catch { /* Unavailable or invalid storage uses the default arrangement. */ }
  let layout = 'scene', active;
  const state = () => layouts[layout];
  const geometry = () => columnGeometry(state().columns, workspace.clientWidth);
  const row = index => rowGeometry(state().rows[index], columns[index].clientHeight);
  function render() {
    const { widths, total, minimums } = geometry();
    workspace.style.setProperty('--column-left', `${widths[0]}px`);
    workspace.style.setProperty('--column-center', `${widths[1]}px`);
    workspace.style.setProperty('--column-right', `${widths[2]}px`);
    for (const [i, column] of columns.entries()) column.style.setProperty('--pane-top', `${row(i).top}px`);
    for (const handle of handles) {
      const [axis, number] = handle.dataset.split.split('-');
      const i = Number(number);
      let min, max, value;
      if (axis === 'column') {
        const prefix = i === 0 ? 0 : widths[0];
        value = (prefix + widths[i]) / total * 100;
        min = (prefix + minimums[i]) / total * 100;
        max = (prefix + widths[i] + widths[i + 1] - minimums[i + 1]) / total * 100;
      } else {
        const r = row(i);
        value = r.top / r.total * 100;
        min = r.minimum / r.total * 100;
        max = 100 - min;
      }
      handle.setAttribute('aria-valuemin', String(Math.round(min)));
      handle.setAttribute('aria-valuemax', String(Math.round(max)));
      handle.setAttribute('aria-valuenow', String(Math.round(value)));
    }
  }
  function save() {
    try { localStorage.setItem(STORAGE, JSON.stringify(layouts)); } catch { /* Resizing still works without persistence. */ }
  }
  function start(handle) {
    const [axis, number] = handle.dataset.split.split('-');
    const index = Number(number);
    return { handle, axis, index, original: structuredClone(state()), columns: geometry(), row: row(index) };
  }
  function apply(drag, delta) {
    if (drag.axis === 'column') state().columns = resizeColumns(drag.columns, drag.index, delta);
    else state().rows[drag.index] = clamp(drag.row.top + delta, drag.row.minimum, drag.row.total - drag.row.minimum) / drag.row.total;
    render();
  }
  function finish(cancel = false) {
    if (!active) return;
    const drag = active;
    active = undefined;
    if (cancel) { layouts[layout] = drag.original; render(); }
    else save();
    if (drag.handle.hasPointerCapture(drag.pointerId)) drag.handle.releasePointerCapture(drag.pointerId);
    workspace.classList.remove('resizing-columns', 'resizing-rows');
  }
  function down(event) {
    if (event.button !== 0 || active) return;
    event.preventDefault();
    const handle = event.currentTarget;
    handle.focus({ preventScroll: true });
    active = { ...start(handle), pointerId: event.pointerId, x: event.clientX, y: event.clientY };
    handle.setPointerCapture(event.pointerId);
    workspace.classList.add(active.axis === 'column' ? 'resizing-columns' : 'resizing-rows');
  }
  function move(event) {
    if (!active || active.pointerId !== event.pointerId) return;
    apply(active, active.axis === 'column' ? event.clientX - active.x : event.clientY - active.y);
  }
  function up(event) { if (event.pointerId === active?.pointerId) finish(); }
  function cancel() { finish(true); }
  function key(event) {
    if (event.key === 'Escape' && active) { event.preventDefault(); finish(true); return; }
    if (active) return;
    const handle = event.target.closest('[data-split]');
    if (!handle) return;
    const drag = start(handle);
    const backward = drag.axis === 'column' ? 'ArrowLeft' : 'ArrowUp';
    const forward = drag.axis === 'column' ? 'ArrowRight' : 'ArrowDown';
    const delta = event.key === backward ? -16 : event.key === forward ? 16 :
      event.key === 'Home' ? -Infinity : event.key === 'End' ? Infinity : null;
    if (delta === null) return;
    event.preventDefault();
    apply(drag, delta); save();
  }
  for (const handle of handles) {
    handle.addEventListener('pointerdown', down);
    handle.addEventListener('pointermove', move);
    handle.addEventListener('pointerup', up);
    handle.addEventListener('pointercancel', cancel);
    handle.addEventListener('lostpointercapture', cancel);
  }
  workspace.addEventListener('keydown', key);
  window.addEventListener('blur', cancel);
  const observer = new ResizeObserver(() => { finish(true); render(); });
  observer.observe(workspace);
  render();
  return {
    setLayout(name) {
      if (!['scene', 'action'].includes(name)) return;
      finish(true); layout = name; render();
    },
    dispose() {
      finish(true); observer.disconnect();
      workspace.removeEventListener('keydown', key);
      window.removeEventListener('blur', cancel);
      for (const handle of handles) {
        handle.removeEventListener('pointerdown', down);
        handle.removeEventListener('pointermove', move);
        handle.removeEventListener('pointerup', up);
        handle.removeEventListener('pointercancel', cancel);
        handle.removeEventListener('lostpointercapture', cancel);
      }
    },
  };
}
