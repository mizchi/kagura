import {rotatedCells,dimensions,previewPlacement,isInventoryGroundDrop} from './hunter-inventory-grid.mjs';
export {rotatedCells,previewPlacement} from './hunter-inventory-grid.mjs';
import {comparisonRows,comparisonMarkup,createInventoryTooltip} from './hunter-item-comparison.mjs';
import {createInventoryGamepad} from './hunter-inventory-pad.mjs';
// Presentation only: the game validates and commits every inventory move.
const gearPaths={
  coat:'M12 4h10l8 6-4 10-5-3 6 14H7l6-14-5 3-4-10ZM17 7v22M13 4l4 8 4-8',
  hat:'M10 21 14 6l8-2 4 18M2 24q15-10 30 0-15 7-30 0ZM12 17l12 1',
  gloves:'M7 29 4 18l3-2 4 5V5q3-3 4 0v10-12q3-2 4 1v12-10q3-2 4 1v10-6q3-2 4 1v12l-5 6Z',
  boots:'M9 3h15l-2 18 6 5v5H5v-6l5-7ZM11 10h11M10 15h12M5 27h23',
  ring:'M12 8 17 2l5 6-5 6ZM12 11a11 11 0 1 0 10 0M13 17a6 6 0 1 0 8 0',
  amulet:'M6 3q0 16 11 19Q28 19 28 3M17 18l6 7-6 7-6-7Z',
};
const rarityNames={common:'一般',uncommon:'上質',rare:'希少',epic:'至宝'};

export function createInventoryPanel(panel,{input,icon,escape}) {
  let view=null,selected=null,rotated=false,drag=null,ghost=null,localNotice='',bagArea='bag',overflowPage=0,detailPage=0,lastDetailTurn=0;
  const overflowPageSize=3;
  const gearIcon=name=>gearPaths[name]?`<svg viewBox="0 0 34 34" aria-hidden="true"><path d="${gearPaths[name]}"/></svg>`:icon(name);
  const findItem=source=>view?.items.find(i=>i.source===source)??view?.equipment.find(s=>s.item?.source===source)?.item;
  const selectedItem=()=>findItem(selected);
  const glyph=item=>`<span class="inv-glyph">${gearIcon(item.glyph)}</span>`;
  function itemMarkup(item) {
    const [w,h]=dimensions(item);
    return `<button class="inv-item rarity-${item.rarity} ${item.rotated?'turned':''} ${item.cells.length<item.width*item.height?'irregular':''}" data-inv-item="${item.source}" data-focus="inv-${item.source}" aria-label="${escape(item.name)}・${item.slot_name}・${w}×${h}" aria-pressed="${selected===item.source}" style="left:${item.x/view.width*100}%;top:${item.y/view.height*100}%;width:${w/view.width*100}%;height:${h/view.height*100}%;--iw:${w};--ih:${h}">${rotatedCells(item).map(([x,y])=>`<span class="inv-item-cell" data-item-cell="${x},${y}" style="grid-column:${x+1};grid-row:${y+1}"></span>`).join('')}${glyph(item)}</button>`;
  }
  function detailMarkup() {
    const item=selectedItem();
    if(!item)return `<div class="inv-detail-empty">${gearIcon('bag')}<h3>次の狩りに備える</h3><p>品を選ぶと性能を比較できます。<br>ドラッグ、または品と移動先を順にタップ。</p></div>`;
    const [w,h]=dimensions(item,rotated);
    return `<div class="inv-detail-heading rarity-${item.rarity}">${glyph(item)}<div><small>${rarityNames[item.rarity]} · ${item.slot_name}${item.source<0?' · 装備中':''}</small><h3 title="${escape(item.name)}">${escape(item.name)}</h3><p>${w} × ${h} · ${item.cells.length}マス${item.cells.length<item.width*item.height?' · L字形':''}</p></div></div>${comparisonMarkup(view,item,escape,{page:detailPage,pageSize:4})}<div class="inv-detail-actions"><button data-inv-action="equip" data-focus="inv-equip">${item.source<0?'バッグへ外す':'装備する'}</button><button data-inv-action="rotate" data-focus="inv-rotate">↻ 回転 <kbd>R</kbd></button><button data-inv-action="drop" data-focus="inv-drop">地面に捨てる</button></div>`;
  }
  function equipmentMarkup() {
    return `<section class="inv-loadout" aria-label="装備部位">
      <div class="inv-section-title"><h3>装備</h3><dl class="inv-player-stats"><div><dt>攻撃</dt><dd>${view.atk}</dd></div><div><dt>防御</dt><dd>${view.def}</dd></div><div><dt>体力</dt><dd>${view.hp}</dd></div></dl></div>
      <div class="inv-body"><svg class="inv-silhouette" viewBox="0 0 150 240" aria-hidden="true"><path d="m51 39 8-30 27-3 11 34 33 10-55 12-56-12Zm8 30h34l14 23-12 33 27 61-38-5-9-28-9 28-38 5 26-61-14-33Zm-3 117h17l-4 45-26 3 8-14Zm25 0h17l4 34 8 14-27-3Z"/></svg>
      ${view.equipment.map(slot=>`<button class="inv-equip inv-slot-${slot.id} ${slot.item?'rarity-'+slot.item.rarity:''}" data-equip-slot="${slot.id}" ${slot.item?`data-inv-item="${slot.item.source}"`:''} data-focus="slot-${slot.id}" aria-label="${slot.label}スロット：${escape(slot.item?.name??'未装備')}" aria-pressed="${slot.item&&selected===slot.item.source?'true':'false'}"><small>${slot.label}</small>${gearIcon(slot.item?.glyph??slot.glyph)}<span>${escape(slot.item?.name??'未装備')}</span></button>`).join('')}</div>
    </section>`;
  }
  function bagMarkup() {
    const overflow=view.items.filter(item=>item.x<0),pages=Math.ceil(overflow.length/overflowPageSize);
    if(!overflow.length)bagArea='bag';
    overflowPage=Math.max(0,Math.min(overflowPage,pages-1));
    return `<section class="inv-bag-section" aria-label="所持品">
      <div class="inv-section-title"><h3>所持品</h3><span><b>${view.used}</b> / ${view.width*view.height}</span></div>
      ${overflow.length?`<nav class="inv-bag-tabs" aria-label="所持品の切り替え"><button data-inv-action="bag" data-focus="inv-bag" aria-pressed="${bagArea==='bag'}">バッグ</button><button data-inv-action="overflow" data-focus="inv-overflow" aria-pressed="${bagArea==='overflow'}">保管待ち ${overflow.length}</button></nav>`:''}
      <div class="inv-bag-frame" ${bagArea!=='bag'?'hidden':''} style="--cols:${view.width};--rows:${view.height}">
        <div class="inv-bag" aria-label="${view.width}列 ${view.height}行のバッグ">
          <div class="inv-cells">${Array.from({length:view.width*view.height},(_,i)=>`<button class="inv-cell" data-focus="cell-${i%view.width}-${Math.floor(i/view.width)}" data-cell-x="${i%view.width}" data-cell-y="${Math.floor(i/view.width)}" aria-label="バッグ ${i%view.width+1}列 ${Math.floor(i/view.width)+1}行"></button>`).join('')}</div>
          ${view.items.filter(item=>item.x>=0).map(itemMarkup).join('')}<div class="inv-preview" aria-hidden="true"></div>
        </div>
      </div>
      ${overflow.length?`<div class="inv-overflow" ${bagArea!=='overflow'?'hidden':''}><div class="inv-overflow-items">${overflow.slice(overflowPage*overflowPageSize,(overflowPage+1)*overflowPageSize).map(item=>`<button data-inv-item="${item.source}" data-focus="inv-${item.source}" aria-pressed="${selected===item.source}">${gearIcon(item.glyph)}<span>${escape(item.name)}</span><small>${item.width}×${item.height}</small></button>`).join('')}</div><nav class="inv-pages" aria-label="保管待ちのページ"><button data-inv-action="overflow-prev" data-focus="inv-overflow-prev" aria-label="前の保管待ち" ${overflowPage===0?'disabled':''}>←</button><span>${overflowPage+1} / ${pages}</span><button data-inv-action="overflow-next" data-focus="inv-overflow-next" aria-label="次の保管待ち" ${overflowPage+1===pages?'disabled':''}>→</button></nav></div>`:''}
    </section>`;
  }
  function contentMarkup() {
    return `<div class="inv-layout">${equipmentMarkup()}${bagMarkup()}<aside class="inv-detail" aria-label="選択したアイテムの詳細">${detailMarkup()}</aside></div>
    <footer class="inv-footer"><p class="inv-bag-help">ドラッグで移動・装備 <span>R 回転 · E 装備</span></p><p class="inv-pad-help"><strong class="inv-pad-state">× 持つ / □ 装備・外す</strong><span>十字 選択 · △ 回転 · L1/R1 切替 · 右スティック 比較 · R3 捨てる</span></p><p class="inv-notice" role="status">${escape(localNotice||view.notice||'装備袋を開いている間、狩場の時間は止まります。')}</p></footer>`;
  }
  function paint() {
    const content=panel.querySelector('[data-inventory-view]');
    if(!content||!view)return;
    const focus=panel.contains(document.activeElement)?document.activeElement.dataset.focus:null;
    tooltip.hide();
    content.innerHTML=contentMarkup();
    if(focus){
      let target=content.querySelector(`[data-focus="${focus}"]`);
      if(target?.disabled)target=target.closest('nav')?.querySelector('button:not(:disabled)');
      target?.focus({preventScroll:true});
    }
  }
  function render(next) {
    cancelDrag();tooltip.hide();
    view=next;
    if(!view)return '<p>インベントリを読み込んでいます</p>';
    if(!selectedItem())selected=null;
    if(selectedItem()&&!pad.carrying)rotated=selectedItem().rotated;
    localNotice='';
    return `<header class="inv-header"><p class="eyebrow">BELONGINGS</p><h2>装備袋</h2></header><div data-inventory-view>${contentMarkup()}</div>`;
  }
  function select(source) {
    if(selected!==source)detailPage=0;
    selected=source;rotated=selectedItem()?.rotated??false;localNotice='';
    const item=selectedItem();
    if(item?.source>=0){bagArea=item.x<0?'overflow':'bag';if(item.x<0)overflowPage=Math.floor(view.items.filter(i=>i.x<0).indexOf(item)/overflowPageSize);}
    paint();
  }
  function clearPreview() {
    panel.querySelector('.inv-preview')?.replaceChildren();
    delete panel.dataset.invGroundDrop;
    const hint=panel.querySelector('.inv-drop-zone');if(hint)hint.textContent='外側にドラッグして捨てる';
    panel.querySelectorAll('[data-drop-valid]').forEach(el=>el.removeAttribute('data-drop-valid'));
  }
  function cancelDrag() {
    if(drag&&panel.hasPointerCapture(drag.id))panel.releasePointerCapture(drag.id);
    drag=null;ghost?.remove();ghost=null;clearPreview();
  }
  function targetAt(x,y,offset={x:0,y:0}) {
    const slot=document.elementFromPoint(x,y)?.closest('[data-equip-slot]');
    if(slot&&panel.contains(slot))return {target:Number(slot.dataset.equipSlot),x:0,y:0};
    const bag=panel.querySelector('.inv-bag'),r=bag?.getBoundingClientRect();
    if(r&&x>=r.left&&y>=r.top&&x<r.right&&y<r.bottom)return {target:-1,x:Math.floor((x-r.left)/r.width*view.width)-offset.x,y:Math.floor((y-r.top)/r.height*view.height)-offset.y};
    if(isInventoryGroundDrop(x,y,panel.querySelector('.panel-inventory')?.getBoundingClientRect(),panel.getBoundingClientRect()))return {target:-2,x:0,y:0};
    return null;
  }
  function showPreview(target) {
    clearPreview();const item=selectedItem();if(!target||!item)return false;
    if(target.target===-2){panel.dataset.invGroundDrop='true';const hint=panel.querySelector('.inv-drop-zone');if(hint)hint.textContent='離して地面に捨てる';return true;}
    if(target.target>=0){
      const valid=target.target===item.slot;
      panel.querySelector(`[data-equip-slot="${target.target}"]`)?.setAttribute('data-drop-valid',String(valid));
      return valid;
    }
    const preview=previewPlacement(view,item,target.x,target.y,rotated);
    const layer=panel.querySelector('.inv-preview');
    if(layer)layer.innerHTML=preview.cells.filter(([x,y])=>x>=0&&y>=0&&x<view.width&&y<view.height).map(([x,y])=>`<i class="${preview.valid?'valid':'invalid'}" style="left:${x/view.width*100}%;top:${y/view.height*100}%;width:${100/view.width}%;height:${100/view.height}%"></i>`).join('');
    return preview.valid;
  }
  function moveTo(target) {
    const item=selectedItem();if(!item||!target)return false;
    if(target.target===-2){drop();return true;}
    if(target.target>=0&&target.target!==item.slot){localNotice=`この品は「${item.slot_name}」に装備できます`;paint();return false;}
    if(target.target===-1&&!previewPlacement(view,item,target.x,target.y,rotated).valid){localNotice='配置できません。空きマスを選んでください';paint();return false;}
    input.moveItem({source:selected,...target,rotated});
    selected=target.target>=0?-1-target.target:item.source>=0?item.source:null;
    localNotice='';
    return true;
  }
  function rotate() {
    const item=selectedItem();if(!item)return;
    const [,height]=dimensions(item,rotated);
    rotated=!rotated;
    if(drag){
      // Toggle between base and clockwise footprints, preserving the grabbed cell.
      drag.offset=rotated?{x:height-1-drag.offset.y,y:drag.offset.x}:{x:drag.offset.y,y:dimensions(item,rotated)[1]-1-drag.offset.x};
      updateDrag();
    }else{localNotice='回転しました。置くマスを選んでください';paint();}
  }
  function autoEquip() {
    const item=selectedItem();if(!item)return;
    if(item.source>=0)moveTo({target:item.slot,x:0,y:0});
    else {
      for(const orientation of [rotated,!rotated])for(let y=0;y<view.height;y++)for(let x=0;x<view.width;x++){
        const p=previewPlacement(view,item,x,y,orientation);
        if(p.valid&&!p.swap){rotated=orientation;moveTo({target:-1,x,y});return;}
      }
      localNotice='バッグに空きがありません。先に品を移動してください';paint();
    }
  }
  function drop() {
    if(!selectedItem())return;
    input.moveItem({source:selected,target:-2,x:0,y:0,rotated:false});
    selected=null;localNotice='';tooltip.hide();paint();
  }
  const tooltip=createInventoryTooltip(panel,{getView:()=>view,findItem,escape});
  function showArea(area) {
    if(!['bag','overflow'].includes(area)||bagArea===area)return;
    bagArea=area;paint();
  }
  function pageDetail(direction) {
    const item=selectedItem();if(!item)return;
    const next=Math.max(0,Math.min(Math.ceil(comparisonRows(view,item).length/4)-1,detailPage+direction));
    if(next!==detailPage){detailPage=next;paint();}
  }
  const pad=createInventoryGamepad(panel,{getView:()=>view,select,moveTo,equip:autoEquip,rotate,drop,showPreview,clearPreview,showArea,pageDetail(value){
    const now=performance.now();if(now-lastDetailTurn<300)return;
    lastDetailTurn=now;pageDetail(Math.sign(value));
  }});
  function updateDrag() {
    if(!drag?.active)return;
    const tab=document.elementFromPoint(drag.x,drag.y)?.closest('[data-inv-action="bag"]');
    if(tab&&panel.contains(tab))showArea('bag');
    const item=selectedItem(),[w,h]=dimensions(item,rotated);
    if(!ghost){ghost=document.createElement('div');ghost.className='inv-drag-ghost';ghost.setAttribute('aria-hidden','true');document.body.append(ghost);}
    const cell=Math.max(24,panel.querySelector('.inv-bag').getBoundingClientRect().width/view.width);
    ghost.style.cssText=`left:${drag.x-(drag.offset.x+.5)*cell}px;top:${drag.y-(drag.offset.y+.5)*cell}px;width:${w*cell}px;height:${h*cell}px`;
    ghost.innerHTML=itemMarkup({...item,x:0,y:0,rotated}).replace('width:'+w/view.width*100+'%','width:100%').replace('height:'+h/view.height*100+'%','height:100%');
    ghost.querySelector('button')?.setAttribute('tabindex','-1');
    showPreview(targetAt(drag.x,drag.y,drag.offset));
  }
  panel.addEventListener('pointerdown',e=>{
    if(e.button!==0||drag||!e.target.closest('[data-inventory-view]'))return;
    pad.reset();
    const element=e.target.closest('[data-inv-item]');if(!element)return;
    const source=Number(element.dataset.invItem),item=findItem(source);if(!item)return;
    // With a selection, clicking an equipment slot is a placement intent.
    if(selected!==null&&selected!==source&&element.hasAttribute('data-equip-slot'))return;
    if(selected!==source){selected=source;rotated=item.rotated;}
    const r=element.getBoundingClientRect(),[w,h]=dimensions(item);
    const offset=element.classList.contains('inv-item')&&rotated===item.rotated?{x:Math.min(w-1,Math.floor((e.clientX-r.left)/r.width*w)),y:Math.min(h-1,Math.floor((e.clientY-r.top)/r.height*h))}:{x:0,y:0};
    drag={id:e.pointerId,source,startX:e.clientX,startY:e.clientY,x:e.clientX,y:e.clientY,offset,active:false};
    panel.setPointerCapture(e.pointerId);e.preventDefault();e.stopPropagation();
  });
  panel.addEventListener('pointermove',e=>{
    if(!drag||drag.id!==e.pointerId)return;
    drag.x=e.clientX;drag.y=e.clientY;
    if(Math.hypot(drag.x-drag.startX,drag.y-drag.startY)>6)drag.active=true;
    updateDrag();e.preventDefault();e.stopPropagation();
  });
  panel.addEventListener('pointerup',e=>{
    if(!drag||drag.id!==e.pointerId)return;
    const {active,offset}=drag,target=active?targetAt(e.clientX,e.clientY,offset):null;
    const valid=active&&showPreview(target);cancelDrag();
    if(active&&valid)moveTo(target);
    else if(active){localNotice='配置を取り消しました';paint();}
    else paint();
    e.preventDefault();e.stopPropagation();
  });
  for(const type of ['pointercancel','lostpointercapture'])panel.addEventListener(type,e=>{if(drag?.id===e.pointerId)cancelDrag();});
  panel.addEventListener('click',e=>{
    if(!e.target.closest('[data-inventory-view]'))return;
    e.preventDefault();e.stopPropagation();
    const action=e.target.closest('[data-inv-action]')?.dataset.invAction;
    if(action==='bag'||action==='overflow'){showArea(action);return;}
    if(action==='overflow-prev'||action==='overflow-next'){overflowPage+=action==='overflow-next'?1:-1;paint();return;}
    if(action==='detail-prev'||action==='detail-next'){pageDetail(action==='detail-next'?1:-1);return;}
    if(action==='rotate'){rotate();return;}
    if(action==='equip'){autoEquip();return;}
    if(action==='drop'){drop();return;}
    const slot=e.target.closest('[data-equip-slot]');
    if(slot&&selectedItem()){moveTo({target:Number(slot.dataset.equipSlot),x:0,y:0});return;}
    const cell=e.target.closest('[data-cell-x]');
    if(cell&&selectedItem()){moveTo({target:-1,x:Number(cell.dataset.cellX),y:Number(cell.dataset.cellY)});return;}
    const item=e.target.closest('[data-inv-item]');
    if(item)select(Number(item.dataset.invItem));
  });
  return {
    render,
    close(){cancelDrag();tooltip.hide();pad.reset();view=null;selected=null;localNotice='';bagArea='bag';overflowPage=0;detailPage=0;},
    cancelDrag,
    handleGamepad(action,value){if(action!=='sync')tooltip.hide();return pad.handle(action,value);},
    handleKeyDown(e){
      if(!view||e.ctrlKey||e.metaKey||e.altKey)return false;
      if(e.code==='Escape'&&drag){cancelDrag();localNotice='配置を取り消しました';paint();return true;}
      if(e.code==='Escape'&&pad.carrying&&pad.handle('cancel'))return true;
      if(e.code==='KeyE'){if(!e.repeat)panel.querySelector('[data-inv-action="equip"]')?.click();return true;}
      if(e.code==='KeyR'){if(!e.repeat)rotate();return true;}
      return false;
    },
  };
}
