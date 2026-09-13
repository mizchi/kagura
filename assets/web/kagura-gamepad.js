import {stickVector} from './kagura-controls.js';
import {normalizeGamepad} from './kagura-gamepad-mappings.js';

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

/** A standard-layout snapshot reader. Polling belongs to the engine frame;
 * device ownership, radial dead zones, edges and menu repeat are reusable here.
 * Call step with fresh Gamepad objects, including sparse/null entries.
 * @returns {{step:(pads:ArrayLike<PadSnapshot|null>,options?:{enabled?:boolean,now?:number})=>PadFrame}}
 */
export function createGamepadReader({deadZone=.18}={}) {
  stickVector(0,0,1,{deadZone});
  let identity=null,armed=false,previous=[],previousAxes=[0,0,0,0],direction=null,nextRepeat=0,lastTime=null;
  const axis=value=>Number.isFinite(value)?Math.max(-1,Math.min(1,value)):0;
  return {step(pads,{enabled=true,now=0}={}) {
    const connected=Array.from(pads??[]).filter(p=>p&&p.connected!==false);
    const candidates=connected.map(normalizeGamepad).filter(Boolean);
    const deviceKey=p=>`${p.index}:${p.id}:${p.profile??p.mapping}`;
    const pad=candidates.find(p=>deviceKey(p)===identity)??candidates[0];
    const nextIdentity=pad?deviceKey(pad):null;
    const changed=nextIdentity!==identity;
    const dt=lastTime===null?0:Math.max(0,Math.min(.05,(now-lastTime)/1000));lastTime=now;
    const oldButtons=previous;
    if(changed||!enabled){identity=nextIdentity;armed=false;previous=[];previousAxes=[0,0,0,0];direction=null;}
    const axes=[0,1,2,3].map(i=>axis(pad?.axes?.[i]));
    const move=stickVector(axes[0],axes[1],1,{deadZone});
    const look=stickVector(axes[2],axes[3],1,{deadZone});
    const buttons=Array.from(pad?.buttons??[],b=>!!b?.pressed||(Number.isFinite(b?.value)&&b.value>=.55));
    const neutral=!buttons.some(Boolean)&&!move.x&&!move.y&&!look.x&&!look.y;
    if(pad&&enabled&&neutral)armed=true;
    const ready=!!pad&&enabled&&armed;
    const down=ready?buttons.flatMap((v,i)=>v?[i]:[]):[];
    const pressed=down.filter(i=>!previous.includes(i));
    const released=oldButtons.filter(i=>!down.includes(i));
    const vectors=[move.x,move.y,look.x,look.y];
    const activity=ready&&(pressed.length>0||released.length>0||vectors.some((v,i)=>Math.abs(v-previousAxes[i])>.025));
    const horizontal=down.includes(15)?1:down.includes(14)?-1:Math.abs(move.x)>.5?Math.sign(move.x):0;
    const vertical=down.includes(13)?1:down.includes(12)?-1:Math.abs(move.y)>.5?Math.sign(move.y):0;
    const nextDirection=!ready?null:vertical?(vertical>0?'down':'up'):horizontal?(horizontal>0?'right':'left'):null;
    let navigation=null;
    if(nextDirection!==direction){direction=nextDirection;navigation=direction;nextRepeat=now+400;}
    else if(direction&&now>=nextRepeat){navigation=direction;nextRepeat=now+140;}
    previous=down;
    // Compare with the last meaningful change, so slow motion can accumulate.
    if(activity||!ready)previousAxes=vectors;
    return {connected:connected.length>0,supported:!!pad,ready,index:pad?.index??-1,id:pad?.id??connected[0]?.id??'',
      profile:pad?(pad.profile??'standard'):null,
      move:ready?move:{x:0,y:0},look:ready?look:{x:0,y:0},down,pressed,released,activity,navigation,dt};
  }};
}

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
