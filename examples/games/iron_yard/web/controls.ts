import type { PilotInput } from './types.ts';
import type { CombatInput } from './types.ts';

/** DOM owns input capture only; no movement or render state lives here. */
export class PilotControls {
  active=false;
  locked=false;
  yaw=0;
  pitch=.25;
  private keys=new Set<string>();
  private dragging=false;
  private firing=false;
  private element:HTMLElement|null=null;
  private notify:(active:boolean)=>void=()=>{};

  attach(element:HTMLElement,notify:(active:boolean)=>void) {
    this.element=element;this.notify=notify;
    const down=(event:KeyboardEvent)=>{
      if(event.code==='Escape'){this.pause();return;}
      if(!this.active||!['KeyW','KeyA','KeyS','KeyD','ShiftLeft','ShiftRight','KeyE','Space'].includes(event.code))return;
      event.preventDefault();this.keys.add(event.code);
    };
    const up=(event:KeyboardEvent)=>{this.keys.delete(event.code);};
    const look=(event:MouseEvent)=>{
      if(!this.active||(!this.locked&&!this.dragging))return;
      this.yaw-=event.movementX*.0024;
      this.pitch=Math.max(-.2,Math.min(1.05,this.pitch+event.movementY*.0024));
    };
    const lock=()=>{
      this.locked=document.pointerLockElement===element;
      if(this.locked){this.active=true;notify(true);}else this.pause();
    };
    const blur=()=>this.pause();
    const visibility=()=>{if(document.hidden)this.pause();};
    const drag=(event:MouseEvent)=>{
      if(!this.active)return;
      if(event.button===2)this.dragging=true;
      if(event.button===0){this.firing=true;event.preventDefault();}
    };
    const drop=(event:MouseEvent)=>{if(event.button===2)this.dragging=false;if(event.button===0)this.firing=false;};
    const menu=(event:Event)=>event.preventDefault();
    window.addEventListener('keydown',down);window.addEventListener('keyup',up);
    window.addEventListener('mousemove',look);window.addEventListener('mouseup',drop);window.addEventListener('blur',blur);
    document.addEventListener('pointerlockchange',lock);document.addEventListener('visibilitychange',visibility);
    element.addEventListener('mousedown',drag);element.addEventListener('contextmenu',menu);
    return ()=>{
      this.pause();this.element=null;
      window.removeEventListener('keydown',down);window.removeEventListener('keyup',up);
      window.removeEventListener('mousemove',look);window.removeEventListener('mouseup',drop);window.removeEventListener('blur',blur);
      document.removeEventListener('pointerlockchange',lock);document.removeEventListener('visibilitychange',visibility);
      element.removeEventListener('mousedown',drag);element.removeEventListener('contextmenu',menu);
    };
  }
  async start() {
    this.keys.clear();this.firing=false;
    try {
      if(!this.element?.requestPointerLock)throw new Error('Pointer lock unavailable');
      await this.element.requestPointerLock();
    } catch {
      // Embedded previews may deny pointer lock. RMB drag remains usable.
      this.active=true;this.locked=false;this.notify(true);
    }
  }
  /** Editor transport can run without taking pointer lock away from the workspace. */
  play() {
    this.keys.clear();this.firing=false;this.active=true;this.notify(true);
  }
  pause() {
    this.keys.clear();this.dragging=false;this.firing=false;this.active=false;this.notify(false);
    if(document.pointerLockElement===this.element)document.exitPointerLock();
    this.locked=false;
  }
  snapshot():PilotInput {
    const key=(name:string)=>this.active&&this.keys.has(name)?1:0;
    return {forward:key('KeyW')-key('KeyS'),strafe:key('KeyD')-key('KeyA'),
      boost:Boolean(key('ShiftLeft')||key('ShiftRight')),jump:Boolean(key('Space')),yaw:this.yaw,pitch:this.pitch};
  }
  weapons():CombatInput {return {fire:this.active&&this.firing,lock:this.active&&this.keys.has('KeyE')};}
}
