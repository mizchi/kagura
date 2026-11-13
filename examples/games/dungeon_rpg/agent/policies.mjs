// Explicit deterministic evaluation policies. Never used as a Jev fallback.
export function policyDecision(o,policy="tactical"){
  if(!["tactical","attack"].includes(policy))throw Error("unknown policy");
  const cs=o.choices,s=o.state,find=id=>cs.find(c=>c.id===id);
  let choice;
  if(o.phase==='town')choice=find('rest')??find('enter');
  else if(o.phase==='battle'){
    if(policy==='attack'){choice=find('all-attack')??cs.find(c=>c.action.kind==='attack')??cs[0];}
    else {
      const b=s.battle,h=s.party[b.actor];
      const injured=s.party.map((h,i)=>({...h,i})).filter(h=>h.hp>0&&h.maxHp-h.hp>=8).sort((a,b)=>a.hp-b.hp)[0];
      choice=injured&&h?.jobCode===3?find(`heal:${injured.i}`):undefined;
      if(!choice&&h?.jobCode===4&&(b.enemies.filter(e=>e.hp>0).length>=2||b.boss))choice=find('flame');
      if(!choice&&injured?.hp<8)choice=find(`potion:${injured.i}`);
      if(!choice){const enemy=b.enemies.map((e,i)=>({...e,i})).filter(e=>e.hp>0).sort((a,b)=>a.hp-b.hp)[0];choice=find(`attack:${enemy?.i}`)??cs[0];}
    }
  }else if(o.phase==='chest')choice=find('loot:0')??find('loot:1');
  else if(o.phase==='warning')choice=find('challenge');
  else if(o.phase==='explore'){
    if(s.hasSeal)choice=find('recall');
    const injured=s.party.map((h,i)=>({...h,i})).filter(h=>h.hp>0&&h.maxHp-h.hp>=8).sort((a,b)=>a.hp-b.hp)[0];
    if(policy==='tactical'&&!choice&&injured)choice=find(`field-heal:${injured.i}`)??(injured.hp<8?find(`field-potion:${injured.i}`):null);
    const here=s.map.known.find(c=>c.floor===s.floor&&c.x===s.x&&c.z===s.z);
    if(!choice&&['chest','shrine','down'].includes(here?.kind))choice=find('interact');
    const routes=cs.filter(c=>c.action.kind==='navigate').map(c=>({...c,cell:s.map.known.find(k=>k.floor===s.floor&&k.x===c.action.x&&k.z===c.action.z)}));
    const priority=c=>({guardian:100,shrine:90,chest:80,down:70}[c.cell.kind]??(!c.cell.visited?30:0))+(c.action.x+c.action.z)/100;
    if(!choice)choice=routes.sort((a,b)=>priority(b)-priority(a))[0]??cs[0];
  }
  choice??=cs[0];
  return {choiceId:choice.id,confidence:1,probabilities:Object.fromEntries(cs.map(c=>[c.id,c.id===choice.id?1:0])),model:`policy:${policy}`,usage:{inputTokens:0,outputTokens:0},elapsedMs:0,attempts:0};
}
