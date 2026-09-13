// The game owns levels, prerequisites and purchase decisions. This module only
// renders that contract; selecting a node and allocating it are separate intents.
const branches = [
  {
    name: "刃術",
    subtitle: "THE BLADE",
    description: "一撃を研ぎ、群れを断つ。",
  },
  {
    name: "生存・召喚",
    subtitle: "THE BLOOD",
    description: "傷を越え、狩りを続ける。",
  },
  { name: "呪術", subtitle: "THE ARCANE", description: "夜の力を、その手に。" },
];
const statusNames = {
  available: "取得可能",
  prerequisite: "前提スキルが必要",
  points: "SP不足",
  maxed: "習得完了",
  class: "別の誓いが必要",
};

export function renderSkillTree(hud, { icon, escape }) {
  const nodes = hud.nodes;
  const selected = nodes[hud.cursor] ?? nodes[0];
  const byId = new Map(nodes.map((node) => [node.id, node]));
  const coord = (node) => [node.branch * 280 + node.x * 280, 38 + node.y * 410];
  const lines = nodes
    .flatMap((node) =>
      node.prereqs.map((id) => {
        const parent = byId.get(id);
        if (!parent) return "";
        const [x1, y1] = coord(parent),
          [x2, y2] = coord(node);
        return `<path data-from="${id}" data-to="${node.id}" class="${parent.level > 0 ? "path-open" : ""} ${parent.level > 0 && node.level > 0 ? "path-learned" : ""}" d="M${x1} ${y1} C${x1} ${(y1 + y2) / 2} ${x2} ${(y1 + y2) / 2} ${x2} ${y2}"/>`;
      }),
    )
    .join("");
  const select = (node) => `data-key="0" data-selection="${node.index}"`;
  const required = selected.prereqs.map((id) => byId.get(id)).filter(Boolean);
  return `<div class="tree-heading"><div><p class="eyebrow">THE HUNTER'S LEGACY</p><h2>技と成長</h2><p>狩りの記憶を、力に変える。</p></div><div class="tree-points" aria-label="使用可能なスキルポイント"><strong>${hud.skill_points}</strong><span>SP</span><small>レベルアップで +1</small></div></div>
    <div class="tree-layout">
      <section class="tree-map" aria-label="スキルツリー">
        <div class="tree-branches" aria-label="スキルの系統">${branches.map((branch, i) => `<button ${select(nodes.find((node) => node.branch === i))} data-focus="branch-${i}" aria-pressed="${selected.branch === i}"><small>${branch.subtitle}</small><strong>${branch.name}</strong><span>${branch.description}</span></button>`).join("")}</div>
        <div class="tree-window" data-branch="${selected.branch}">
          <div class="tree-board">
            <svg class="tree-connections" viewBox="0 0 840 490" preserveAspectRatio="none" aria-hidden="true">${lines}</svg>
            ${nodes
              .map((node) => {
                const [x, y] = coord(node);
                return `<button class="tree-node ${node.level > 0 ? "learned" : ""} ${node.status}" data-tree-node="${node.id}" data-focus="node-${node.id}" ${select(node)} style="--node-x:${(x / 840) * 100}%;--node-y:${y}px" aria-label="${escape(node.name)} Lv ${node.level}/${node.max_level} · ${statusNames[node.status]}" aria-pressed="${node.id === selected.id}" tabindex="${node.id === selected.id ? 0 : -1}"><span class="tree-node-ring">${icon(node.glyph)}</span><strong>${escape(node.name)}</strong><span class="tree-ranks" aria-hidden="true">${Array.from({ length: node.max_level }, (_, i) => `<i class="${i < node.level ? "filled" : ""}"></i>`).join("")}</span><small>${node.level}/${node.max_level}</small></button>`;
              })
              .join("")}
          </div>
        </div>
        <div class="tree-legend"><span><i class="learned"></i>習得済み</span><span><i class="available"></i>取得可能</span><span><i></i>未解放</span><small>ノードを選んで詳細を確認</small></div>
      </section>
      <aside class="tree-detail" aria-label="選択したスキルの詳細"><button class="tree-return" data-tree-return>↑ ツリーに戻る</button>
        <div class="tree-detail-caption"><span>${branches[selected.branch].name} / ${selected.kind}</span><b>Lv ${selected.level} / ${selected.max_level}</b></div>
        <div class="tree-detail-title">${icon(selected.glyph)}<h3>${escape(selected.name)}</h3></div>
        <p class="tree-description">${escape(selected.description)}</p>
        <dl class="tree-effects"><div><dt>現在</dt><dd>${escape(selected.effect)}</dd></div>${selected.level < selected.max_level ? `<div class="next-effect"><dt>次のレベル</dt><dd>${escape(selected.next_effect)}</dd></div>` : ""}</dl>
        <div class="tree-requirements"><h4>取得条件</h4>${required.length ? required.map((node) => `<button ${select(node)} data-focus="requirement-${node.id}" class="${node.level > 0 ? "met" : ""}"><span>${node.level > 0 ? "✓" : "◇"}</span>${escape(node.name)} <small>Lv 1</small></button>`).join("") : "<p>前提スキルなし</p>"}</div>
        <button class="tree-allocate" data-key="13" data-selection="${selected.index}" data-focus="allocate" ${selected.available ? "" : "disabled"}>${selected.status === "maxed" ? "習得完了" : `${selected.level ? "強化する" : "習得する"} <strong>${selected.cost} SP</strong>`}</button>
        <p class="tree-availability" role="status">${selected.available ? `取得後の残り ${hud.skill_points - selected.cost} SP` : statusNames[selected.status]}</p>
      </aside>
    </div>`;
}
