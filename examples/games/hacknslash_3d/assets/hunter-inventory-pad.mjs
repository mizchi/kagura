import {rotatedCells} from './hunter-inventory-grid.mjs';
const directions={left:[-1,0],right:[1,0],up:[0,-1],down:[0,1]};

// Cursor/carry state is local UI state; moves are validated atomically by the game.
export function createInventoryGamepad(panel,{getView,select,moveTo,equip,rotate,drop,showPreview,clearPreview,showArea,pageDetail}) {
  let active=false,carrying=false,area='bag',x=0,y=0,slot=0,overflowIndex=0;
  let syncedContent=null;
  const overflow=()=>getView()?.items.filter(item=>item.x<0)??[];
  function itemAtCursor(){
    const view=getView();if(!view)return null;
    if(area==='equipment')return view.equipment.find(entry=>entry.id===slot)?.item??null;
    if(area==='overflow')return overflow()[overflowIndex]??null;
    return view.items.find(item=>item.x>=0&&rotatedCells(item).some(([cx,cy])=>item.x+cx===x&&item.y+cy===y))??null;
  }
  const target=()=>area==='equipment'?{target:slot,x:0,y:0}:area==='bag'?{target:-1,x,y}:null;
  function sync(focusCursor=false){
    if(!active||!getView())return;
    const content=panel.querySelector('.inv-layout');
    if(!focusCursor&&content===syncedContent)return;
    syncedContent=content;
    panel.querySelectorAll('.inv-pad-cursor').forEach(el=>el.classList.remove('inv-pad-cursor'));
    const selector=area==='equipment'?`[data-equip-slot="${slot}"]`:area==='overflow'?`[data-inv-item="${itemAtCursor()?.source}"]`:`[data-cell-x="${x}"][data-cell-y="${y}"]`;
    const cursor=panel.querySelector(selector);cursor?.classList.add('inv-pad-cursor');
    const focus=area==='bag'&&!carrying&&itemAtCursor()?panel.querySelector(`[data-inv-item="${itemAtCursor().source}"]`):cursor;
    if(focusCursor)focus?.focus({preventScroll:true});
    const help=panel.querySelector('.inv-pad-state');
    if(help){const text=carrying?'品を持っています · × 置く / ○ 取消':'× 持つ / □ 装備・外す';if(help.textContent!==text)help.textContent=text;}
    if(carrying)showPreview(target());else clearPreview();
  }
  function selectCursor(){showArea(area);if(!carrying)select(itemAtCursor()?.source??null);sync(true);}
  function open(){
    const first=getView()?.items.find(item=>item.x>=0);
    area='bag';x=first?.x??0;y=first?.y??0;slot=0;overflowIndex=0;active=true;carrying=false;selectCursor();
  }
  function navigate(direction){
    const [dx,dy]=directions[direction],view=getView();
    if(area==='bag'){x=Math.max(0,Math.min(view.width-1,x+dx));y=Math.max(0,Math.min(view.height-1,y+dy));}
    else if(area==='overflow')overflowIndex=Math.max(0,Math.min(overflow().length-1,overflowIndex+(dx||dy)));
    else {
      const positions=[...panel.querySelectorAll('[data-equip-slot]')].map(el=>{
        const r=el.getBoundingClientRect();return {id:Number(el.dataset.equipSlot),x:r.x+r.width/2,y:r.y+r.height/2};
      });
      const {x:sx,y:sy}=positions.find(p=>p.id===slot);
      const next=positions.map(({id,x:px,y:py})=>({id,forward:(px-sx)*dx+(py-sy)*dy,side:Math.abs((px-sx)*dy-(py-sy)*dx)})).filter(p=>p.forward>0).sort((a,b)=>(a.forward+a.side*2)-(b.forward+b.side*2))[0];
      if(next)slot=next.id;
    }
    selectCursor();
  }
  return {
    get carrying(){return carrying;},
    reset(){active=false;carrying=false;syncedContent=null;panel.querySelectorAll('.inv-pad-cursor').forEach(el=>el.classList.remove('inv-pad-cursor'));clearPreview();},
    handle(action,value=0){
      if(!getView())return false;
      if(action==='scroll'){pageDetail(value);return true;}
      if(action==='open'){open();return true;}
      if(action==='sync'){sync();return true;}
      if(!active)open();
      if(directions[action]){navigate(action);return true;}
      if(action==='previous'||action==='next'){
        const areas=['bag','equipment',...(overflow().length?['overflow']:[])];
        area=areas[(areas.indexOf(area)+(action==='next'?1:areas.length-1))%areas.length];selectCursor();return true;
      }
      if(action==='cancel'){
        if(!carrying)return false;
        carrying=false;selectCursor();return true;
      }
      if(action==='confirm'){
        if(carrying){if(moveTo(target()))carrying=false;sync(true);}
        else if(itemAtCursor()){select(itemAtCursor().source);carrying=true;sync(true);}
        return true;
      }
      if(action==='equip'){equip();carrying=false;sync(true);return true;}
      if(action==='rotate'){if(itemAtCursor()||carrying){rotate();carrying=true;sync(true);}return true;}
      if(action==='drop'){drop();carrying=false;sync(true);return true;}
      return false;
    },
  };
}
