// Movement and aim have independent owners: WASD must not cancel a mouse aim.
export function bindHunterAim({stage,hud,input,enabled}) {
  const document=stage.ownerDocument,window=document.defaultView;
  let mouseHeld=false;
  function pointer(event){
    if(event.pointerType!=='mouse') { mouseHeld=false;input.useAutoAim();return; }
    mouseHeld=(event.buttons&1)!==0;
    const targetSurface=event.target.id==='target-surface';
    if(!enabled() || (!targetSurface&&(hud.contains(event.target)||!stage.contains(event.target)))){
      input.useAutoAim();return;
    }
    if(event.buttons&2)return; // Right drag orbits without retargeting the cursor.
    const rect=stage.getBoundingClientRect();
    input.aimPointer((event.clientX-rect.left)/rect.width,(event.clientY-rect.top)/rect.height);
  }
  function key(event){if(event.code==='KeyJ'&&!mouseHeld)input.useAutoAim();}
  function clear(){mouseHeld=false;input.useAutoAim();}
  function release(event){if(event.pointerType==='mouse')mouseHeld=(event.buttons&1)!==0;}
  document.addEventListener('pointermove',pointer,true);
  document.addEventListener('pointerdown',pointer,true);
  document.addEventListener('pointerup',release,true);
  document.addEventListener('pointercancel',clear,true);
  window.addEventListener('keydown',key,true);
  window.addEventListener('blur',clear);
  stage.addEventListener('pointerleave',clear);
  return ()=>{
    document.removeEventListener('pointermove',pointer,true);
    document.removeEventListener('pointerdown',pointer,true);
    document.removeEventListener('pointerup',release,true);
    document.removeEventListener('pointercancel',clear,true);
    window.removeEventListener('keydown',key,true);
    window.removeEventListener('blur',clear);
    stage.removeEventListener('pointerleave',clear);
    clear();
  };
}
