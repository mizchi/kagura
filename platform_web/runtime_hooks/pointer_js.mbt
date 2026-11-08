///|
extern "js" fn create_pointer_input(selector : String) -> Int32 =
  #| selector => {
  #|   const doc=globalThis.document, canvas=doc?.querySelector(selector);
  #|   if(!canvas)return 0;
  #|   const registry=globalThis.__kaguraPointerInputs??= {next:1,canvases:new WeakMap(),inputs:new Map()};
  #|   if(registry.canvases.has(canvas))return registry.canvases.get(canvas);
  #|   const id=registry.next++, listeners=[];
  #|   const state={canvas,queue:[],owner:null,current:[-1,-1,0,0,0,0,0,0],listeners};
  #|   const listen=(target,type,fn)=>{target?.addEventListener(type,fn);if(target)listeners.push([target,type,fn]);};
  #|   const frame=(event,pressed,released,down,cancelled)=>{
  #|     const r=canvas.getBoundingClientRect();
  #|     return [event.clientX-r.left,event.clientY-r.top,pressed,released,down,cancelled,event.pointerType==='mouse'?0:1,event.pointerId];
  #|   };
  #|   const release=id=>{if(id!==null && canvas.hasPointerCapture?.(id))canvas.releasePointerCapture(id);};
  #|   const cancel=()=>{
  #|     if(state.owner===null && state.queue.length===0)return;
  #|     const owner=state.owner;state.owner=null;state.queue.length=0;
  #|     state.queue.push([state.current[0],state.current[1],0,0,0,1,state.current[6],state.current[7]]);
  #|     state.current=[...state.current];state.current[2]=state.current[3]=state.current[4]=state.current[5]=0;
  #|     release(owner);
  #|   };
  #|   listen(canvas,'keydown',event=>{
  #|     if(['Tab','Space','ArrowLeft','ArrowRight','ArrowUp','ArrowDown'].includes(event.code))event.preventDefault();
  #|     if(event.code==='Escape')cancel();
  #|   });
  #|   listen(canvas,'pointerdown',event=>{
  #|     if(event.button!==0){if(state.owner!==null)cancel();return;}
  #|     if(state.owner!==null)return;
  #|     event.preventDefault();canvas.focus();state.owner=event.pointerId;
  #|     canvas.setPointerCapture?.(event.pointerId);
  #|     state.current=frame(event,0,0,1,0);state.queue.push(frame(event,1,0,1,0));
  #|   });
  #|   listen(canvas,'pointermove',event=>{
  #|     if(state.owner!==null?state.owner!==event.pointerId:event.pointerType!=='mouse')return;
  #|     state.current=frame(event,0,0,state.owner===event.pointerId?1:0,0);
  #|   });
  #|   listen(canvas,'pointerup',event=>{
  #|     if(state.owner!==event.pointerId)return;
  #|     state.owner=null;state.queue.push(frame(event,0,1,0,0));state.current=frame(event,0,0,0,0);
  #|     release(event.pointerId);
  #|   });
  #|   for(const type of ['pointercancel','lostpointercapture'])listen(canvas,type,event=>{
  #|     if(state.owner===event.pointerId)cancel();
  #|   });
  #|   listen(globalThis.window,'blur',cancel);
  #|   listen(doc,'visibilitychange',()=>{if(doc.hidden)cancel();});
  #|   state.dispose=()=>{
  #|     cancel();state.queue.length=0;
  #|     for(const [target,type,fn] of listeners)target.removeEventListener(type,fn);
  #|     registry.inputs.delete(id);registry.canvases.delete(canvas);
  #|   };
  #|   registry.canvases.set(canvas,id);registry.inputs.set(id,state);return id;
  #| }

///|
extern "js" fn poll_pointer_input(
  handle : Int32,
  width : Double,
  height : Double,
) -> FixedArray[Double] =
  #| (id,width,height) => {
  #|   const state=globalThis.__kaguraPointerInputs?.inputs.get(id);
  #|   if(!state)return [];
  #|   const r=state.canvas.getBoundingClientRect(),frame=[...(state.queue.shift()||state.current)];
  #|   if(!(r.width>0 && r.height>0 && width>0 && height>0))return [];
  #|   frame[0]*=width/r.width;frame[1]*=height/r.height;return frame;
  #| }

///|
extern "js" fn dispose_pointer_input(handle : Int32) -> Unit =
  #| id => globalThis.__kaguraPointerInputs?.inputs.get(id)?.dispose()

///|
fn clear_pointer_inputs() -> Unit {
  clear_pointer_inputs_js()
}

///|
extern "js" fn clear_pointer_inputs_js() -> Unit =
  #| () => {for(const state of [...globalThis.__kaguraPointerInputs?.inputs.values()||[]])state.dispose();}
