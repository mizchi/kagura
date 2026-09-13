// Reuse at most 32 label nodes. World positions are projected by the active game camera.
export function createLootLabels(layer,{input,enabled=()=>true}) {
  const labels=[];
  return entries=>{
    const count=Math.min(32,entries.length),placed=[];
    while(labels.length<count){
      const el=document.createElement('button');el.type='button';
      let pressedId=null;
      el.addEventListener('pointerdown',e=>{if(e.button===0)pressedId=Number(el.dataset.lootId);});
      el.addEventListener('pointercancel',()=>{pressedId=null;});
      el.addEventListener('click',e=>{
        e.preventDefault();e.stopPropagation();
        const id=pressedId??Number(el.dataset.lootId);pressedId=null;
        if(!enabled()||el.disabled||id<=0||id!==Number(el.dataset.lootId))return;
        input.pickupItem(id);
      });
      layer.append(el);labels.push(el);
    }
    for(let i=0;i<labels.length;i++){
      const el=labels[i],item=entries[i];el.hidden=i>=count;if(el.hidden)continue;
      if(el.textContent!==item.name)el.textContent=item.name;
      const name=`ground-loot-label rarity-${item.rarity}`;if(el.className!==name)el.className=name;
      el.dataset.blocked=String(item.blocked);
      el.dataset.lootId=String(item.id);
      el.dataset.nearest=String(item.nearest);
      el.disabled=!enabled()||!item.reachable||item.id<=0;
      el.title=item.reachable?'クリック / × で拾う':'近づくと拾えます';
      el.setAttribute('aria-label',`${item.name}を拾う`);
      // Stack nearby names without measuring layout on every simulation frame.
      let offset=0;
      for(const previous of placed)if(Math.abs(item.x-previous.x)<14&&Math.abs(item.y-previous.y)<4)offset=Math.max(offset,previous.offset+32);
      placed.push({...item,offset});
      el.style.left=`${Math.max(8,Math.min(92,item.x))}%`;
      el.style.top=`${Math.max(8,Math.min(90,item.y))}%`;
      el.style.transform=`translate(-50%,calc(-100% - ${offset}px))`;
    }
  };
}
