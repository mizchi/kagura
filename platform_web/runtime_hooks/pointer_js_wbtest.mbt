///|
extern "js" fn setup_pointer_test() -> Unit =
  #| () => {
  #|   const saved={document:globalThis.document,window:globalThis.window};
  #|   const target=(left=0)=>{
  #|     const listeners=new Map();
  #|     return {listeners,captures:new Set(),
  #|       getBoundingClientRect:()=>({left,top:20,width:200,height:100}),focus(){},
  #|       addEventListener(type,fn){if(!listeners.has(type))listeners.set(type,new Set());listeners.get(type).add(fn);},
  #|       removeEventListener(type,fn){listeners.get(type)?.delete(fn);},
  #|       emit(type,event={}){for(const fn of [...listeners.get(type)||[]])fn(event);},
  #|       setPointerCapture(id){this.captures.add(id);},
  #|       releasePointerCapture(id){this.captures.delete(id);this.emit('lostpointercapture',{pointerId:id});},
  #|       hasPointerCapture(id){return this.captures.has(id);}
  #|     };
  #|   };
  #|   const a=target(10),b=target(310),doc=target(),win=target();
  #|   doc.hidden=false;doc.querySelector=s=>s==='#a'?a:s==='#b'?b:null;
  #|   globalThis.document=doc;globalThis.window=win;
  #|   globalThis.__kaguraPointerTest={saved,a,b,doc,win};
  #| }

///|
extern "js" fn teardown_pointer_test() -> Unit =
  #| () => {
  #|   const t=globalThis.__kaguraPointerTest;
  #|   globalThis.document=t.saved.document;globalThis.window=t.saved.window;
  #|   delete globalThis.__kaguraPointerTest;
  #| }

///|
extern "js" fn emit_pointer_test(
  canvas : String,
  event : String,
  id : Int32,
  x : Double,
  y : Double,
  touch : Bool,
) -> Unit =
  #| (canvas,event,id,x,y,touch) => globalThis.__kaguraPointerTest[canvas].emit(event,
  #|   {pointerId:id,clientX:x,clientY:y,pointerType:touch?'touch':'mouse',button:0,preventDefault(){}})

///|
extern "js" fn blur_pointer_test() -> Unit =
  #| () => globalThis.__kaguraPointerTest.win.emit('blur')

///|
extern "js" fn hide_pointer_test() -> Unit =
  #| () => {const t=globalThis.__kaguraPointerTest;t.doc.hidden=true;t.doc.emit('visibilitychange');}

///|
extern "js" fn pointer_test_listener_count(canvas : String) -> Int32 =
  #| canvas => [...globalThis.__kaguraPointerTest[canvas].listeners.values()].reduce((n,s)=>n+s.size,0)

///|
test "pointer input preserves complete short taps and transforms CSS coordinates" {
  setup_pointer_test()
  let input = WebPointerInput::new(selector="#a")
  emit_pointer_test("a", "pointerdown", 7, 60.0, 45.0, true)
  emit_pointer_test("a", "pointerup", 7, 80.0, 55.0, true)
  let down = input.poll(width=400.0, height=200.0).unwrap()
  assert_true(down.pressed && down.down)
  assert_eq(down.pointer, @ui.Touch(7))
  assert_eq(down.x, 100.0)
  assert_eq(down.y, 50.0)
  let up = input.poll(width=400.0, height=200.0).unwrap()
  assert_true(up.released && !up.down && !up.cancelled)
  assert_eq(up.x, 140.0)
  assert_eq(up.y, 70.0)
  let idle = input.poll(width=400.0, height=200.0).unwrap()
  assert_false(idle.pressed || idle.released)
  input.dispose()
  teardown_pointer_test()
}

///|
test "pointer input keeps primary ownership and follows latest fractional coordinates" {
  setup_pointer_test()
  let input = WebPointerInput::new(selector="#a")
  emit_pointer_test("a", "pointerdown", 7, 30.0, 40.0, true)
  let _ = input.poll(width=200.0, height=100.0)
  emit_pointer_test("a", "pointerdown", 8, 90.0, 90.0, true)
  emit_pointer_test("a", "pointermove", 8, 100.0, 100.0, true)
  emit_pointer_test("a", "pointermove", 7, 70.25, 55.75, true)
  let moved = input.poll(width=200.0, height=100.0).unwrap()
  assert_eq(moved.pointer, @ui.Touch(7))
  assert_eq(moved.x, 60.25)
  assert_eq(moved.y, 35.75)
  emit_pointer_test("a", "pointerup", 7, 70.25, 55.75, true)
  let up = input.poll(width=200.0, height=100.0).unwrap()
  assert_true(up.released && !up.cancelled)
  input.dispose()
  teardown_pointer_test()
}

///|
test "rapid pointer taps stay ordered and hiding the document cancels pending input" {
  setup_pointer_test()
  let input = WebPointerInput::new(selector="#a")
  for x in [30.0, 50.0] {
    emit_pointer_test("a", "pointerdown", 1, x, 40.0, false)
    emit_pointer_test("a", "pointerup", 1, x, 40.0, false)
  }
  for x in [20.0, 40.0] {
    let down = input.poll(width=200.0, height=100.0).unwrap()
    let up = input.poll(width=200.0, height=100.0).unwrap()
    assert_true(down.pressed && up.released)
    assert_eq(down.x, x)
    assert_eq(up.x, x)
  }
  emit_pointer_test("a", "pointerdown", 1, 30.0, 40.0, false)
  hide_pointer_test()
  assert_true(input.poll(width=200.0, height=100.0).unwrap().cancelled)
  clear_pointer_inputs()
  assert_true(input.poll(width=200.0, height=100.0) is None)
  assert_eq(pointer_test_listener_count("a"), 0)
  assert_true(
    WebPointerInput::new(selector="#missing").poll(width=200.0, height=100.0)
    is None,
  )
  teardown_pointer_test()
}

///|
test "blur and lost capture cancel gestures without replaying queued clicks" {
  setup_pointer_test()
  let input = WebPointerInput::new(selector="#a")
  emit_pointer_test("a", "pointerdown", 1, 50.0, 50.0, false)
  blur_pointer_test()
  let cancelled = input.poll(width=200.0, height=100.0).unwrap()
  assert_true(cancelled.cancelled && !cancelled.down && !cancelled.pressed)
  assert_false(input.poll(width=200.0, height=100.0).unwrap().cancelled)
  emit_pointer_test("a", "pointerdown", 2, 50.0, 50.0, false)
  let _ = input.poll(width=200.0, height=100.0)
  emit_pointer_test("a", "lostpointercapture", 2, 50.0, 50.0, false)
  assert_true(input.poll(width=200.0, height=100.0).unwrap().cancelled)
  input.dispose()
  teardown_pointer_test()
}

///|
test "pointer installation is idempotent per canvas and dispose removes listeners" {
  setup_pointer_test()
  let a = WebPointerInput::new(selector="#a")
  let n = pointer_test_listener_count("a")
  let again = WebPointerInput::new(selector="#a")
  assert_eq(pointer_test_listener_count("a"), n)
  let b = WebPointerInput::new(selector="#b")
  emit_pointer_test("a", "pointerdown", 1, 50.0, 50.0, false)
  assert_false(b.poll(width=200.0, height=100.0).unwrap().pressed)
  assert_true(again.poll(width=200.0, height=100.0).unwrap().pressed)
  a.dispose()
  assert_eq(pointer_test_listener_count("a"), 0)
  assert_true(again.poll(width=200.0, height=100.0) is None)
  let replacement = WebPointerInput::new(selector="#a")
  assert_eq(pointer_test_listener_count("a"), n)
  replacement.dispose()
  b.dispose()
  teardown_pointer_test()
}

///|
test "runtime shutdown releases pointer listeners and invalidates shared handles" {
  setup_pointer_test()
  let input = WebPointerInput::new(selector="#a")
  assert_true(pointer_test_listener_count("a") > 0)
  shutdown()
  assert_eq(pointer_test_listener_count("a"), 0)
  assert_true(input.poll(width=200.0, height=100.0) is None)
  teardown_pointer_test()
}
