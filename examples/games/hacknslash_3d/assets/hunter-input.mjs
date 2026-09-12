// Input intent only. The MoonBit simulation owns damage, cooldowns and movement.
export function stickVector(dx, dy, radius) {
  const length=Math.hypot(dx,dy);
  if (length < radius*.14) return {x:0,y:0};
  const magnitude=Math.min(1,(length/radius-.14)/.86);
  return {x:dx/length*magnitude,y:dy/length*magnitude};
}

export function createHunterInput() {
  const held=new Map();
  const keys=[];
  let stick=null;
  let x=0,y=0;
  let keyReleased=true;
  let selection=-1;
  return {
    version:1,
    move(id,dx,dy) { if (stick!==null && stick!==id) return; stick=id; x=dx; y=dy; },
    hold(id,action) { held.set(id,action); },
    release(id) { held.delete(id); if (stick===id) {stick=null;x=0;y=0;} },
    tap(key, selected=-1) { if (keys.length<8) keys.push({key,selected}); },
    // Insert a release tick so two consecutive taps of one key remain two presses.
    consumeKey() { selection=-1; if (!keyReleased) {keyReleased=true;return 0;} const command=keys.shift(); const key=command?.key??0; selection=command?.selected??-1; keyReleased=key===0; return key; },
    selection() { return selection; },
    snapshot() { return {x,y,attack:[...held.values()].includes('attack')}; },
    clear() { held.clear();keys.length=0;stick=null;x=0;y=0;keyReleased=true;selection=-1; },
  };
}

export function skillStatus({level,remaining,total}) {
  if (level<=0) return {disabled:true,label:'未習得',progress:0};
  if (remaining>0) return {disabled:true,label:`${(remaining/60).toFixed(1)}s`,progress:Math.min(1,remaining/Math.max(1,total))};
  return {disabled:false,label:'使用可能',progress:0};
}
