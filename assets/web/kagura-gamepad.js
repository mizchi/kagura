
/**
 * @typedef {{x:number,y:number}} Stick
 * @typedef {'up'|'down'|'left'|'right'} MenuDirection
 * @typedef {{index:number,id:string,mapping:string,connected?:boolean,
 * axes:ArrayLike<number>,buttons:ArrayLike<{pressed:boolean,value:number}>}} PadSnapshot
 * @typedef {{connected:boolean,supported:boolean,ready:boolean,index:number,id:string,
 * profile:string|null,
 * move:Stick,look:Stick,down:number[],pressed:number[],released:number[],
 * activity:boolean,navigation:MenuDirection|null,dt:number}} PadFrame
 */

export {createGamepadReader} from './kagura-runtime.generated.js';

/** Spatial focus navigation for DOM menus; ranges and selects adjust in place. */
export function navigateGamepadMenu(root,direction) {
  if(!root)return;
  const doc=root.ownerDocument;
  const nodes=[...root.querySelectorAll('button:not(:disabled),input:not(:disabled),select:not(:disabled),a[href]')]
    .filter(node=>node.getClientRects().length&&!node.closest('[hidden]'));
  const current=nodes.includes(doc.activeElement)?doc.activeElement:null;
  if(current&&['left','right'].includes(direction)){
    const delta=direction==='right'?1:-1;
    if(current.matches('input[type=range],input[type=number]')){
      const step=Number(current.step)||1,value=Number(current.value)||0;
      const min=current.min===''?-Infinity:Number(current.min),max=current.max===''?Infinity:Number(current.max);
      current.value=String(Math.max(min,Math.min(max,Number((value+step*delta).toFixed(6)))));
      current.dispatchEvent(new doc.defaultView.Event('input',{bubbles:true}));return;
    }
    if(current.tagName==='SELECT'){
      current.selectedIndex=Math.max(0,Math.min(current.options.length-1,current.selectedIndex+delta));
      current.dispatchEvent(new doc.defaultView.Event('change',{bubbles:true}));return;
    }
  }
  let next=nodes[0];
  if(current){
    const r=current.getBoundingClientRect(),cx=r.x+r.width/2,cy=r.y+r.height/2;
    const vertical=direction==='up'||direction==='down',sign=direction==='up'||direction==='left'?-1:1;
    let best=Infinity;next=null;
    for(const node of nodes){
      if(node===current)continue;
      const b=node.getBoundingClientRect(),dx=b.x+b.width/2-cx,dy=b.y+b.height/2-cy;
      const forward=(vertical?dy:dx)*sign,cross=Math.abs(vertical?dx:dy);
      if(forward<=1)continue;
      const score=forward+cross*3;
      if(score<best){best=score;next=node;}
    }
  }
  next?.focus({preventScroll:true});next?.scrollIntoView({block:'nearest',inline:'nearest'});
}
