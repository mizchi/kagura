import {comparisonRows} from '#kagura-web/kagura-runtime.generated.js';
export {comparisonRows};
const number=value=>Number(value.toFixed(1));
export function comparisonMarkup(view,item,escape,{page=0,pageSize=Infinity}={}) {
  const equipped=view.equipment.find(slot=>slot.id===item.slot)?.item;
  const rows=comparisonRows(view,item);
  const pages=Math.ceil(rows.length/pageSize),current=Math.max(0,Math.min(page,pages-1));
  const shown=Number.isFinite(pageSize)?rows.slice(current*pageSize,(current+1)*pageSize):rows;
  return `<p class="inv-comparison">${item.source<0?'装備中':`比較：${escape(equipped?.name??'未装備')}`}</p><table class="inv-stat-comparison"><thead><tr><th>補正</th><th>この品</th><th>装備中</th><th>差</th></tr></thead><tbody>${shown.map(({label,value,before,delta})=>`<tr><th>${escape(label)}</th><td>${number(value)}</td><td>${number(before)}</td><td class="${delta>0?'better':delta<0?'worse':''}">${delta>0?'+':''}${number(delta)}</td></tr>`).join('')||'<tr><td colspan="4">追加補正なし</td></tr>'}</tbody></table>${pages>1?`<nav class="inv-pages" aria-label="比較のページ"><button data-inv-action="detail-prev" data-focus="inv-detail-prev" aria-label="前の比較" ${current===0?'disabled':''}>←</button><span>補正 ${current+1} / ${pages}</span><button data-inv-action="detail-next" data-focus="inv-detail-next" aria-label="次の比較" ${current+1===pages?'disabled':''}>→</button></nav>`:''}`;
}

// Read-only hover overlay: never selects or replaces the bag underneath the pointer.
export function createInventoryTooltip(panel,{getView,findItem,escape}) {
  const tip=document.createElement('aside');tip.className='inv-hover';tip.hidden=true;
  tip.id='inventory-comparison';tip.setAttribute('role','tooltip');
  tip.setAttribute('aria-label','装備との比較');
  let anchor=null;
  function hide(){tip.hidden=true;anchor?.removeAttribute('aria-describedby');anchor=null;}
  panel.addEventListener('pointerover',e=>{
    if(e.pointerType!=='mouse'||e.buttons)return;
    const target=e.target.closest('[data-inv-item]'),view=getView();
    if(!target||!view||target===anchor)return;
    const item=findItem(Number(target.dataset.invItem));if(!item)return;
    hide();anchor=target;target.setAttribute('aria-describedby',tip.id);
    tip.className=`inv-hover rarity-${item.rarity}`;
    tip.innerHTML=`<small>${escape(item.slot_name)}</small><h3>${escape(item.name)}</h3>${comparisonMarkup(view,item,escape)}`;
    if(!tip.isConnected)panel.append(tip);
    tip.hidden=false;
    const r=target.getBoundingClientRect(),box=tip.getBoundingClientRect();
    const x=r.right+12+box.width<=innerWidth?r.right+12:r.left-box.width-12;
    tip.style.left=`${Math.max(8,Math.min(innerWidth-box.width-8,x))}px`;
    tip.style.top=`${Math.max(8,Math.min(innerHeight-box.height-8,r.top))}px`;
  });
  panel.addEventListener('pointerout',e=>{if(anchor&&!anchor.contains(e.relatedTarget))hide();});
  panel.addEventListener('pointerdown',hide);
  panel.addEventListener('scroll',hide,true);
  window.addEventListener('resize',hide);
  return {hide};
}
