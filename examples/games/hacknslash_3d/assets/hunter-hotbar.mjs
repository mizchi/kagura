// One slot contract for keyboard, touch and pad. Action IDs remain game-owned.
export function hunterSlot(hud,index){
  const skill=hud?.skills?.[index];
  return skill?.key!==undefined?skill:{key:49+index,hold:index===1?'whirlwind':''};
}

export function hunterDigitSlot(code){
  return /^Digit[1-4]$/.test(code)?Number(code.slice(-1))-1:-1;
}
