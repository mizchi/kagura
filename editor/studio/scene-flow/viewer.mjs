import {inspectSceneFlow, inspectSceneDocuments} from '../../../game/scene_flow/inspect.mjs';
import {downloadBlob} from '../web/storage.mjs';
import './style.css';

const descriptions = {
  'invalid-scene':'シーンIDが空です',
  'duplicate-scene':'シーンIDが重複しています',
  'invalid-entry':'開始シーンが未定義です',
  'unknown-terminal':'終端シーンが未定義です',
  'duplicate-terminal':'終端シーンが重複しています',
  'unknown-source':'未定義の遷移元です',
  'unknown-target':'未定義の遷移先です',
  'invalid-event':'イベント名が空です',
  'terminal-transition':'終端からの遷移があります',
  'ambiguous-event':'同じシーンのイベントが競合しています',
  'unreachable-scene':'開始シーンから到達不能です',
  'dead-end':'終端ではないシーンが行き止まりです',
  'no-terminal-path':'終端へ到達できません',
  'dead-transition':'実行できない遷移です',
};
const node = (tag, text, className) => {
  const e = document.createElement(tag);
  if (text !== undefined) e.textContent = text;
  if (className) e.className = className;
  return e;
};
const button = (text, action) => {
  const e = node('button',text);
  e.type = 'button';
  e.addEventListener('click',action);
  return e;
};
const svgNode = (tag, attrs = {}, text) => {
  const e = document.createElementNS('http://www.w3.org/2000/svg',tag);
  for (const [k,v] of Object.entries(attrs)) e.setAttribute(k,String(v));
  if (text !== undefined) e.textContent = text;
  return e;
};

/** UI state only. The same MoonBit analyzer supplies CLI and runtime contracts. */
export function installSceneFlowViewer({host, setStatus} = {}) {
  let inspection, selected, generation = 0, disposed = false, background = [];
  const opener = button('シーン遷移',open);
  document.querySelector('.toolbar').append(opener);
  const dialog = node('dialog',undefined,'scene-flow-dialog');
  dialog.setAttribute('aria-labelledby','scene-flow-title');
  const restoreBackground = () => {
    for (const [element, hidden, inert] of background) {
      if (hidden === null) element.removeAttribute('aria-hidden');
      else element.setAttribute('aria-hidden',hidden);
      element.inert = inert;
    }
    background = [];
  };
  dialog.addEventListener('close',restoreBackground);
  dialog.addEventListener('keydown',event => event.stopPropagation());
  dialog.addEventListener('keydown',event => {
    if (event.key === 'Escape') {
      event.preventDefault();
      dialog.close();
    }
  },true);
  const header = node('header'), heading = node('div'), title = node('h2','シーン遷移');
  title.id = 'scene-flow-title';
  heading.append(title,node('p','シーンとイベントを定義して、到達不能や不正な遷移を確かめる。'));
  header.append(heading,button('閉じる',() => dialog.close()));
  const actions = node('div',undefined,'scene-flow-actions');
  const file = node('input');
  file.type = 'file';
  file.accept = '.json,application/json';
  file.hidden = true;
  file.setAttribute('aria-label','シーン遷移定義JSON');
  file.addEventListener('change',async () => {
    const chosen = file.files[0], ticket = ++generation;
    if (!chosen) return;
    try {
      if (chosen.size > 4 * 1024 * 1024) throw Error('定義は4 MiB以下にしてください');
      const data = JSON.parse(await chosen.text());
      if (!disposed && ticket === generation) apply(inspectSceneFlow(data));
    } catch (error) {
      if (ticket === generation) showError(error);
    } finally {
      file.value = '';
    }
  });
  const fromProject = button('プロジェクトから読込',async () => {
    const ticket = ++generation, project = host?.project();
    try {
      if (project?.manifest.sceneFlow) {
        const {blob} = await project.readResource(project.manifest.sceneFlow.resource);
        if (blob.size > 4 * 1024 * 1024) throw Error('定義は4 MiB以下にしてください');
        const data = JSON.parse(await blob.text());
        if (disposed || ticket !== generation || host.project() !== project) return;
        apply(inspectSceneFlow(data));
        source.textContent = 'ゲームの遷移定義から生成した状態機械です。変更後は再生成して読み込んでください。';
        return;
      }
      if (!project?.manifest.scenes) throw Error('名前付きシーンを持つプロジェクトを開いてください');
      const manifest = project.manifest;
      const scenes = await Promise.all(Object.keys(manifest.scenes).map(async id => ({
        id, data:await host.readScene(id),
      })));
      if (disposed || ticket !== generation || host.project() !== project) return;
      const game = scenes[0]?.data.resources?.find(r => r.id === 'kagura.scene')?.data.game;
      if (!game) throw Error('このプロジェクトにはポータルのシーン定義がありません。遷移定義JSONを読み込んでください');
      apply(inspectSceneDocuments({entry:manifest.entryScene,game,scenes}));
      source.textContent = '現在の編集内容のポータルから生成しました。ポータルのないシーンを終端として扱います。再読込で更新します。';
    } catch (error) {
      if (ticket === generation) showError(error);
    }
  });
  fromProject.disabled = !host;
  const mermaid = button('Mermaidを書出',() => downloadBlob(
    new Blob([inspection.mermaid],{type:'text/plain'}),'scene-flow.mmd'));
  const json = button('定義を書出',() => downloadBlob(
    new Blob([JSON.stringify(inspection.definition,null,2)+'\n'],{type:'application/json'}),'scene-flow.json'));
  actions.append(button('定義JSONを読込',() => file.click()),fromProject,mermaid,json,file);
  const summary = node('p','遷移定義JSONを読み込むか、プロジェクトのポータルを読み込んでください。','scene-flow-summary');
  summary.setAttribute('role','status');
  const errorBox = node('p','','scene-flow-error');
  errorBox.setAttribute('role','alert');
  const source = node('p','','scene-flow-note');
  const content = node('div',undefined,'scene-flow-content');
  dialog.append(header,actions,summary,errorBox,source,content,
    node('p','検証は定義上の到達可能性を調べます。ゲーム内の条件が成立するか、実際に全遷移を通ったかは判定しません。','scene-flow-note'));
  document.body.append(dialog);

  function open() {
    if (!disposed && !dialog.open) {
      dialog.showModal();
      // Mirror the native modal's inactive background in the DOM a11y contract.
      background = [...document.body.children].filter(e => e !== dialog).map(e => [e,e.getAttribute('aria-hidden'),e.inert]);
      for (const [element] of background) {
        element.inert = true;
        element.setAttribute('aria-hidden','true');
      }
    }
  }
  function showError(error) {
    if (disposed) return;
    errorBox.textContent = '読込エラー · '+error.message+(inspection ? '。表示中の定義を保持しました。' : '');
    setStatus?.('Error · '+error.message);
  }
  function apply(result) {
    inspection = result;
    selected = undefined;
    errorBox.textContent = '';
    source.textContent = '';
    render();
    return result;
  }
  function load(data) {
    ++generation;
    return apply(inspectSceneFlow(data));
  }
  function select(id) {
    selected = id;
    render();
    const scene = [...content.querySelectorAll('[data-scene]')].find(e => e.dataset.scene === id);
    scene?.scrollIntoView({block:'nearest',inline:'nearest'});
  }
  function render() {
    mermaid.disabled = json.disabled = !inspection;
    content.replaceChildren();
    if (!inspection) return;
    const {definition:d,report} = inspection, issues = report.issues;
    const errors = issues.filter(i => i.severity === 'error').length;
    summary.textContent = `${d.scenes.length}シーン / ${d.transitions.length}遷移 · `+
      (issues.length ? `エラー ${errors}件 / 警告 ${issues.length-errors}件` : '問題なし')+
      (selected === undefined ? '' : ` · 選択: ${selected}`);
    const ids = [...new Set(d.scenes)];
    // Give every outgoing edge its own row, including reciprocal edges and loops.
    const boxes = new Map(), ports = new Map();
    let graphHeight = 36;
    for (const id of ids) {
      const outgoing = d.transitions.filter(edge => edge.from === id).length;
      const height = Math.max(64, outgoing * 22 + 20);
      boxes.set(id, {y:graphHeight,height});
      graphHeight += height + 48;
    }
    const graphScroll = node('div',undefined,'scene-flow-graph-scroll');
    graphScroll.tabIndex = 0;
    graphScroll.setAttribute('role','region');
    graphScroll.setAttribute('aria-label','遷移図のスクロール領域');
    const width = 720;
    const graph = svgNode('svg',{viewBox:`0 0 ${width} ${Math.max(140,graphHeight)}`,role:'img','aria-label':'シーンの状態遷移図'});
    graph.append(svgNode('title',{},'シーンの状態遷移図'));
    const defs = svgNode('defs'), marker = svgNode('marker',{id:'scene-flow-arrow',viewBox:'0 0 10 10',refX:9,refY:5,markerWidth:7,markerHeight:7,orient:'auto-start-reverse'});
    marker.append(svgNode('path',{d:'M 0 0 L 10 5 L 0 10 z',fill:'#91a4bf'}));
    defs.append(marker);
    graph.append(defs);
    for (const [i,edge] of d.transitions.entries()) {
      const a = boxes.get(edge.from), b = boxes.get(edge.to);
      if (!a || !b) continue;
      const port = ports.get(edge.from) ?? 0;
      ports.set(edge.from,port+1);
      const y1 = a.y+22+port*22, y2 = b.y+b.height/2, lane = 300+(i%12)*14;
      const path = svgNode('path',{
        d:`M 242 ${y1} H ${lane} V ${y2} H 242`,
        fill:'none',stroke:issues.some(issue => issue.transition === i) ? '#f6bd7c' : '#91a4bf',
        'stroke-width':2,'marker-end':'url(#scene-flow-arrow)',
      });
      path.append(svgNode('title',{},`#${i+1} ${edge.from} → ${edge.to} / ${edge.event}`));
      // Reserve a label column beyond every edge lane, so lines cannot cross text.
      graph.append(path,
        svgNode('path',{d:`M ${lane} ${y1} H 458`,fill:'none',stroke:'#91a4bf','stroke-width':1,'stroke-dasharray':'3 4'}),
        svgNode('text',{x:470,y:y1+4,class:'scene-flow-edge-label'},`#${i+1} ${edge.event.length > 20 ? edge.event.slice(0,19)+'…' : edge.event}`));
    }
    for (const id of ids) {
      const dead = !report.reachable.includes(id), {y,height} = boxes.get(id);
      const g = svgNode('g',{'data-scene':id,class:`scene-flow-node${dead ? ' is-unreachable' : ''}${selected === id ? ' is-selected' : ''}`});
      g.append(svgNode('rect',{x:30,y,width:212,height,rx:10}),
        svgNode('text',{x:44,y:y+25},id.length > 21 ? id.slice(0,20)+'…' : id),
        svgNode('text',{x:44,y:y+48,class:'scene-flow-node-meta'},[
          id === d.entry ? '開始' : '',d.terminal.includes(id) ? '終端' : '',dead ? '到達不能' : '',
        ].filter(Boolean).join(' · ') || 'シーン'));
      g.append(svgNode('title',{},id));
      graph.append(g);
    }
    graphScroll.append(graph);
    const choices = node('div',undefined,'scene-flow-scenes');
    choices.setAttribute('role','group');
    choices.setAttribute('aria-label','シーンを選択');
    for (const id of ids) {
      const b = button(id,() => select(id));
      b.setAttribute('aria-pressed',String(selected === id));
      choices.append(b);
    }
    content.append(node('p','図と表は横にスクロールできます。矢印の番号は遷移一覧に対応します。','scene-flow-scroll-hint'),graphScroll,choices,node('h3','検証結果'));
    if (!issues.length) content.append(node('p','到達不能なシーンや不正な遷移は見つかりませんでした。'));
    else {
      const list = node('ul',undefined,'scene-flow-issues');
      list.setAttribute('aria-label','検証結果');
      for (const issue of issues) {
        const li = node('li');
        li.append(button(`${issue.severity === 'error' ? 'エラー' : '警告'} · ${issue.scene || '(空)'} · ${descriptions[issue.code]}${issue.transition < 0 ? '' : ` (#${issue.transition+1})`}`,() => select(issue.scene)));
        list.append(li);
      }
      content.append(list);
    }
    const scroll = node('div',undefined,'scene-flow-table-scroll'), table = node('table');
    table.setAttribute('aria-label','遷移一覧');
    const head = node('thead'), row = node('tr');
    for (const label of ['番号','遷移元','イベント','遷移先','状態']) {
      const th = node('th',label); th.scope = 'col'; row.append(th);
    }
    head.append(row);
    const body = node('tbody');
    for (const [i,edge] of d.transitions.entries()) {
      const row = node('tr');
      if (edge.from === selected || edge.to === selected) row.className = 'is-selected';
      const codes = issues.filter(issue => issue.transition === i).map(issue => descriptions[issue.code]);
      for (const value of [`#${i+1}`,edge.from,edge.event,edge.to,codes.join(' / ') || '有効']) row.append(node('td',value));
      body.append(row);
    }
    table.append(head,body); scroll.append(table); content.append(node('h3','遷移一覧'),scroll);
  }
  render();
  return {open,load,dispose() {
    disposed = true;
    ++generation;
    restoreBackground();
    dialog.close(); dialog.remove(); opener.remove();
  }};
}
