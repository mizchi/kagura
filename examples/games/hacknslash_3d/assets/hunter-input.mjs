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
  return {
    ...controls,
    tap(key, selected = -1) { return controls.tap(key, {selection: selected}); },
    select(selected) { return controls.tap(selectionCommand, {selection: selected}); },
    moveItem(move) { return controls.tap(inventoryCommand, {inventoryMove: {...move}}); },
    inventoryMove() { return inventoryMove; },
    aimAt(x,y) { target = {x:Math.max(0,Math.min(1,x)),y:Math.max(0,Math.min(1,y))}; },
    confirmTarget(x,y) { controls.tap(targetCommand,{target:{x,y}}); },
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
      return {x, y, attack: actions.includes('attack'), guard: actions.includes('guard')};
    },
    clear() { controls.clear(); selection = -1; inventoryMove = null; target = null; targetConfirmed = false; },
  };
}

export function skillStatus({level,remaining,total}) {
  if (level<=0) return {disabled:true,label:'未習得',progress:0};
  if (remaining>0) return {disabled:true,label:`${(remaining/60).toFixed(1)}s`,progress:Math.min(1,remaining/Math.max(1,total))};
  return {disabled:false,label:'使用可能',progress:0};
}
