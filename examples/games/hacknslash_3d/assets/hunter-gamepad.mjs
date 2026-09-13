// Standard physical layout; labels use Xbox / PlayStation equivalents in the HUD.
import {hunterSlot} from './hunter-hotbar.mjs';
// Reader owns device state, this adapter owns gameplay bindings. No synthetic keys.
export function createHunterGamepad({reader,input,camera,view,navigate,confirm,inventory=()=>false,status=()=>{},
  getPads=()=>globalThis.__kaguraWebRuntime?.gamepadFrame??[],
  enabled=()=>!document.hidden&&document.hasFocus(),now=()=>performance.now()}) {
  const moveId=-1000,attackId=-1001,guardId=-1002,slotIds=[-1003,-1004,-1005,-1006];
  let context=null,previousDown=[],suppressed=new Set(),ready=false,blockMove=false,blockLook=false;
  const release=()=>{for(const id of [moveId,attackId,guardId,...slotIds])input.release(id);input.aimStick(0,0);input.aimGroundStick(null);};
  function poll(active=enabled()){
    const frame=reader.step(getPads(),{enabled:active,now:now()});
    const hud=view();
    if(!hud){release();return;}
    const nextContext=hud.save_delete_slot>=0?'save_delete':hud.mode!=='playing'?hud.mode:hud.camera?.editing?'camera':hud.terrain?.editing?'terrain':hud.menu!=='none'?hud.menu:hud.paused?'pause':hud.arts?.targeting?'target':'play';
    const changed=context!==nextContext;
    if(changed){for(const i of previousDown)suppressed.add(i);blockMove=!!(frame.move.x||frame.move.y);blockLook=!!(frame.look.x||frame.look.y);context=nextContext;}
    if(!frame.move.x&&!frame.move.y)blockMove=false;
    if(!frame.look.x&&!frame.look.y)blockLook=false;
    for(const i of suppressed)if(!frame.down.includes(i))suppressed.delete(i);
    const pressed=frame.pressed.filter(i=>!suppressed.has(i)),down=frame.down.filter(i=>!suppressed.has(i));
    previousDown=frame.down;
    if(frame.activity)input.useGamepad();
    if(!frame.ready){
      const owned=input.gamepadActive();release();
      if(owned)input.useAutoAim();
      if(ready&&owned&&hud.mode==='playing'&&!hud.paused)input.tap(80);
      ready=false;status(frame,false);return;
    }
    ready=true;
    const press=(button,key)=>{if(pressed.includes(button))input.tap(key);};
    const hold=(id,button,action)=>{if(down.includes(button))input.hold(id,action);else input.release(id);};
    if(pressed.includes(9)){
      release();if(hud.mode==='playing')input.tap(80);else confirm();
    } else if(context==='play'){
      if(!blockMove&&(frame.move.x||frame.move.y))input.move(moveId,frame.move.x,frame.move.y);else input.release(moveId);
      hold(attackId,2,'attack');hold(guardId,5,'guard');
      const slotButton=(index,button,allowed=true)=>{
        const slot=hunterSlot(hud,index),id=slotIds[index];
        if(slot.hold&&allowed)hold(id,button,slot.hold);
        else {input.release(id);if(allowed)press(button,slot.key);}
      };
      slotButton(0,3);slotButton(1,7);slotButton(2,4);slotButton(3,13,down.includes(6));
      if(pressed.includes(0))input.pickupItem();
      press(1,32);press(8,73);press(10,67);press(11,90);
      // L2 modifies only the d-pad; basic combat buttons retain their actions.
      for(const [button,key] of (down.includes(6)?[[12,53],[14,54],[15,56]]:[[12,66],[13,84],[14,88],[15,86]]))press(button,key);
      if(input.gamepadActive()){
        input.aimStick(blockLook?0:frame.look.x,blockLook?0:frame.look.y);
        // The target command is consumed this tick, before the HUD changes context.
        input.aimGroundStick({x:0,y:0});
        if(!blockLook&&hud.camera?.mode===1&&(frame.look.x||frame.look.y))camera.look(frame.look.x*frame.dt*2.3,frame.look.y*frame.dt*1.6);
      }
    } else if(context==='inventory'){
      release();
      if(changed&&input.gamepadActive())inventory('open');
      if(frame.navigation)inventory(frame.navigation);
      if(!blockLook&&frame.look.y)inventory('scroll',frame.look.y*frame.dt*600);
      for(const [button,action] of [[0,'confirm'],[2,'equip'],[3,'rotate'],[4,'previous'],[5,'next'],[11,'drop']])if(pressed.includes(button))inventory(action);
      if(pressed.includes(1)&&!inventory('cancel'))input.tap(27);
      if(pressed.includes(8))input.tap(73);
      if(input.gamepadActive())inventory('sync');
    } else if(context==='target'){
      release();
      if(input.gamepadActive())input.aimGroundStick(blockLook?{x:0,y:0}:{...frame.look});
      if(pressed.includes(0))input.tap(13);
      if(pressed.includes(1)||pressed.includes(13))input.tap(84);
    } else {
      release();
      if(frame.navigation)navigate(frame.navigation);
      if(pressed.includes(0))confirm();
      press(1,27);
    }
    status(frame,input.gamepadActive());
  }
  return {poll,reset:()=>poll(false)};
}
