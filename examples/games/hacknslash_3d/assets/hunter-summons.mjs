export function createSummonStatus(root, icon) {
  let signature = '';
  return hud => {
    const army = hud.summons;
    root.hidden = !army || hud.mode !== 'playing' ||
      (!army.zombies.length && !army.skulls.length && !hud.skills.some(s => s.key === 48 || s.key === 57));
    if (root.hidden) return;
    const key = `${army.zombies.length}:${army.skulls.length}`;
    if (key !== signature) {
      signature = key;
      root.innerHTML = `<div class="summon-zombies">${icon('zombie')}<span>ゾンビ <b>${army.zombies.length}/${army.zombie_limit}</b></span><div class="summon-meters">${army.zombies.map(() => '<i><i></i></i>').join('')}</div></div>
        <div class="summon-skulls">${icon('skull')}<span>頭蓋 <b>${army.skulls.length}/${army.skull_limit}</b></span><div class="summon-meters">${army.skulls.map(() => '<i><i></i></i>').join('')}</div></div>`;
    }
    army.zombies.forEach((z, i) => {
      const bar = root.querySelector('.summon-zombies .summon-meters').children[i];
      bar.firstElementChild.style.width = `${100 * z.hp / z.max_hp}%`;
      bar.setAttribute('aria-label', `ゾンビ ${i + 1} 体力 ${z.hp}/${z.max_hp}`);
    });
    army.skulls.forEach((s, i) => {
      const bar = root.querySelector('.summon-skulls .summon-meters').children[i];
      bar.firstElementChild.style.width = `${100 * s.remaining / army.lifetime}%`;
      bar.setAttribute('aria-label', `頭蓋 ${i + 1} 残り ${(s.remaining / 60).toFixed(1)}秒`);
    });
  };
}
