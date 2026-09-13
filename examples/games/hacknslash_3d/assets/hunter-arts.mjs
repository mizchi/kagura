// Browser input carries normalized viewport points; the game resolves the ground ray.
export function bindHunterArts({root,input}) {
  const $=id=>root.querySelector('#'+id);
  const surface=$('target-surface');
  const point=e=>{const r=surface.getBoundingClientRect();return {x:(e.clientX-r.left)/r.width,y:(e.clientY-r.top)/r.height};};
  surface.addEventListener('pointerdown',e=>{
    if(e.button!==0)return;
    e.preventDefault();e.stopPropagation();
    const p=point(e);input.aimAt(p.x,p.y);surface.setPointerCapture(e.pointerId);
  });
  surface.addEventListener('pointermove',e=>{const p=point(e);input.aimAt(p.x,p.y);});
  surface.addEventListener('pointerup',e=>{
    if(!surface.hasPointerCapture(e.pointerId))return;
    e.preventDefault();e.stopPropagation();
    const p=point(e);input.confirmTarget(p.x,p.y);surface.releasePointerCapture(e.pointerId);
  });
  surface.addEventListener('pointercancel',()=>input.tap(84));
  const label=(id,text)=>{if($(id).textContent!==text)$(id).textContent=text;};
  return hud=>{
    const art=hud.arts;if(!art)return;
    $('combat-feedback').hidden=!art.feedback||hud.menu!=='none';
    label('combat-feedback',art.feedback);
    const blocked=hud.mode!=='playing'||hud.paused||hud.menu!=='none';
    const locked=hud.weapon_locked||hud.attack_remaining>0;
    const cooldown=(frames,key)=>frames>0?`${(frames/60).toFixed(1)}s`:key;
    $('guard-button').disabled=blocked||art.targeting||art.guard_recovery>0||(locked&&!art.guarding);
    $('guard-button').setAttribute('aria-pressed',String(art.guarding));
    label('guard-status',art.guard_recovery>0?'体勢を立て直す':art.guarding?`防御中 ${art.guard_energy}`:'F / 長押し');
    $('guard-reserve-fill').style.width=art.guard_energy+'%';
    $('astral-button').disabled=blocked||(!art.targeting&&(locked||art.ground_remaining>0));
    $('astral-button').setAttribute('aria-pressed',String(art.targeting));
    label('astral-status',art.targeting?'照準中 / 取消':cooldown(art.ground_remaining,'T / 位置指定'));
    $('dash-strike-button').disabled=blocked||locked||art.targeting||art.dash_remaining>0;
    label('dash-strike-status',cooldown(art.dash_remaining,'V'));
    surface.hidden=blocked||!art.targeting;
    $('target-hint').hidden=surface.hidden;
    surface.dataset.valid=String(art.target_valid);
    $('target-hint').querySelector('span').textContent=art.target_valid?'地面をクリック／タップして発動':'遮蔽物のない地面を指定';
  };
}
