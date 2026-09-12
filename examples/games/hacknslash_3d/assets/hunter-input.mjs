// Game-specific bridge over Kagura's generic input intents.
// Injecting the input keeps this adapter independent of browser/module resolution.
export function createHunterInput(controls) {
  let selection = -1;
  return {
    ...controls,
    tap(key, selected = -1) { return controls.tap(key, {selection: selected}); },
    consumeKey() {
      const command = controls.consumeCommand();
      selection = command?.payload?.selection ?? -1;
      return command?.key ?? 0;
    },
    selection() { return selection; },
    snapshot() {
      const {x, y, actions} = controls.snapshot();
      return {x, y, attack: actions.includes('attack')};
    },
    clear() { controls.clear(); selection = -1; },
  };
}

export function skillStatus({level,remaining,total}) {
  if (level<=0) return {disabled:true,label:'未習得',progress:0};
  if (remaining>0) return {disabled:true,label:`${(remaining/60).toFixed(1)}s`,progress:Math.min(1,remaining/Math.max(1,total))};
  return {disabled:false,label:'使用可能',progress:0};
}
