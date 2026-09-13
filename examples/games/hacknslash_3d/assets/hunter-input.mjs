// Game-specific bridge over Kagura's generic input intents.
// Injecting the input keeps this adapter independent of browser/module resolution.
export function createHunterInput(controls) {
  const selectionCommand = 65536;
  let selection = -1;
  const inventoryCommand = 65537;
  let inventoryMove = null;
  const targetCommand = 65538;
  let target = null;
  let targetConfirmed = false;
  let whirlwindPressed = false;
  let pointer = null,stick=null,groundStick=null,gamepadActive=false;
  return {
    ...controls,
    aimPointer(x,y) { stick=null;groundStick=null;gamepadActive=false;pointer=Number.isFinite(x)&&Number.isFinite(y)&&x>=0&&x<=1&&y>=0&&y<=1 ? {x,y} : null; },
    pointerAim() { return pointer; },
    useAutoAim() { pointer=null;stick=null;groundStick=null;gamepadActive=false; },
    useGamepad() { pointer=null;gamepadActive=true; },
    gamepadActive() { return gamepadActive; },
    aimStick(x,y) { stick=Number.isFinite(x)&&Number.isFinite(y)&&(x*x+y*y>0)?{x,y}:null; },
    stickAim() { return stick; },
    aimGroundStick(value) { groundStick=value; },
    groundStick() { return groundStick; },
    hold(id,action) {
      if(action==='whirlwind'&&!controls.snapshot().actions.includes(action))whirlwindPressed=true;
      controls.hold(id,action);
    },
    isHeld(action) { return controls.snapshot().actions.includes(action); },
    consumeWhirlwindPress() { const pressed=whirlwindPressed;whirlwindPressed=false;return pressed; },
    tap(key, selected = -1) { return controls.tap(key, {selection: selected}); },
    select(selected) { return controls.tap(selectionCommand, {selection: selected}); },
    moveItem(move) { return controls.tap(inventoryCommand, {inventoryMove: {...move}}); },
    inventoryMove() { return inventoryMove; },
    pickupItem(id=0) { if(Number.isSafeInteger(id)&&id>=0) return controls.tap(204,{selection:id}); },
    aimAt(x,y) { gamepadActive=false;groundStick=null;target = {x:Math.max(0,Math.min(1,x)),y:Math.max(0,Math.min(1,y))}; },
    confirmTarget(x,y) { gamepadActive=false;groundStick=null;controls.tap(targetCommand,{target:{x,y}}); },
    targetPoint() { return target; },
    targetConfirmed() { return targetConfirmed; },
    consumeKey() {
      const command = controls.consumeCommand();
      targetConfirmed = command?.key === targetCommand;
      if(targetConfirmed) target = command.payload.target;
      selection = command?.payload?.selection ?? -1;
      inventoryMove = command?.payload?.inventoryMove ?? null;
      return [selectionCommand, inventoryCommand, targetCommand].includes(command?.key) ? 0 : command?.key ?? 0;
    },
    selection() { return selection; },
    snapshot() {
      const {x, y, actions} = controls.snapshot();
      return {x, y, attack: actions.includes('attack'), guard: actions.includes('guard'), whirlwind: actions.includes('whirlwind')};
    },
    clear() { controls.clear(); pointer=null;stick=null;groundStick=null; whirlwindPressed=false; selection = -1; inventoryMove = null; target = null; targetConfirmed = false; },
  };
}

export function skillStatus({level,remaining,total}) {
  if (level<=0) return {disabled:true,label:'未習得',progress:0};
  if (remaining>0) return {disabled:true,label:`${(remaining/60).toFixed(1)}s`,progress:Math.min(1,remaining/Math.max(1,total))};
  return {disabled:false,label:'使用可能',progress:0};
}
