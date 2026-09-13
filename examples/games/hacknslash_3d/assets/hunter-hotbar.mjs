// One slot contract for keyboard, touch and pad. Action IDs remain game-owned.
export function hunterSlot(hud,index){
  const skill=hud?.skills?.[index];
  return skill?.key!==undefined?skill:{key:[74,50,86,70][index],hold:['attack','whirlwind','','guard'][index]};
}

export function hunterDigitSlot(code){
  return /^Digit[1-4]$/.test(code)?Number(code.slice(-1))-1:-1;
}

export function pressHunterSlot(input,hud,index,owner){
  const slot=hunterSlot(hud,index);
  if(slot.hold){
    // Preserve a short click between simulation frames; held actions then repeat.
    if(slot.hold!=='whirlwind')input.tap(slot.key);
    input.hold(owner,slot.hold);
  }
  else input.tap(slot.key);
}

// Mouse owns only combat clicks on the game surface, never UI or ground confirmation.
export function bindHunterMouse({stage,hud,input,view}){
  const document=stage.ownerDocument,window=document.defaultView;
  const owners=[-2000,-2001];
  const release=e=>{if(e.pointerType==='mouse')for(const [i,mask] of [[0,1],[1,2]])if(!(e.buttons&mask))input.release(owners[i]);};
  const clear=()=>owners.forEach(id=>input.release(id));
  const down=e=>{
    const state=view();
    if(e.pointerType!=='mouse'||![0,2].includes(e.button)||!stage.contains(e.target)||hud.contains(e.target)||
      state?.mode!=='playing'||state.paused||state.menu!=='none'||state.arts?.targeting)return;
    e.preventDefault();
    const slot=e.button===0?0:1;
    pressHunterSlot(input,state,slot,owners[slot]);
  };
  document.addEventListener('pointerdown',down,true);
  document.addEventListener('pointerup',release,true);
  document.addEventListener('pointermove',release,true);
  document.addEventListener('pointercancel',clear,true);
  window.addEventListener('blur',clear);
  stage.addEventListener('pointerleave',clear);
  return clear;
}
