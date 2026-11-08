///|
test "session stop cancels work and disposes in reverse order exactly once" {
  let events : Array[String] = []
  let session = RunSession::new()
  session.own(fn() { events.push("first") })
  session.own(fn() { events.push("second") })
  let queued : Array[() -> Unit] = []
  let host : @services.FrameHost = {
    request_frame: fn(callback) {
      queued.push(callback)
      fn() { events.push("cancel") }
    },
    on_exit: fn(_callback) { fn() { events.push("unsubscribe") } },
    publish_phases: fn(_a, _b, _c) { () },
  }
  session.watch_exit(host)
  session.schedule(host, fn() { events.push("frame") })
  session.stop()
  session.stop()
  queued[0]()
  assert_eq(events, ["cancel", "unsubscribe", "second", "first"])
  assert_true(session.status() is Stopped)
}

///|
test "failed session exposes its stage and never executes queued work" {
  let errors : Array[RunFailure] = []
  let disposed = Ref(0)
  let session = RunSession::new(on_error=fn(error) { errors.push(error) })
  session.own(fn() { disposed.val += 1 })
  session.fail(Shader, "invalid WGSL")
  session.fail(Render, "must not replace the first failure")
  session.stop()
  assert_eq(errors.length(), 1)
  assert_eq(errors[0].stage, Shader)
  assert_eq(errors[0].message, "invalid WGSL")
  assert_eq(disposed.val, 1)
  assert_true(session.status() is Failed(_))
}

///|
test "sessions own their clock and frame host independently" {
  let a = RunSession::new(clock=fn() { 10.0 })
  let b = RunSession::new(clock=fn() { 20.0 })
  let count = Ref(0)
  a.set_frame(fn() { count.val += 1 })
  b.set_frame(fn() { count.val += 10 })
  a.ready()
  b.ready()
  a.stop()
  a.step()
  b.step()
  assert_eq(count.val, 10)
  assert_eq(a.now_ms(), 10.0)
  assert_eq(b.now_ms(), 20.0)
  b.stop()
}

///|
test "late disposers are released and backend leases survive rejected starts" {
  let a = RunSession::new(on_error=fn(_) { () })
  let b = RunSession::new(on_error=fn(_) { () })
  assert_true(a.claim_backend())
  assert_false(b.claim_backend())
  assert_true(a.is_active())
  a.stop()
  let released = Ref(false)
  a.own(fn() { released.val = true })
  assert_true(released.val)
  let c = RunSession::new()
  assert_true(c.claim_backend())
  c.stop()
}

///|
test "session captures the installed clock and replaces stale frame reservations" {
  @services.set_clock(fn() { 10.0 })
  let session = RunSession::new()
  @services.set_clock(fn() { 20.0 })
  assert_eq(session.now_ms(), 10.0)
  let callbacks : Array[() -> Unit] = []
  let calls = Ref(0)
  let host : @services.FrameHost = {
    request_frame: fn(callback) {
      callbacks.push(callback)
      fn() { () }
    },
    on_exit: fn(_) { fn() { () } },
    publish_phases: fn(_, _, _) { () },
  }
  session.schedule(host, fn() { calls.val += 1 })
  session.schedule(host, fn() { calls.val += 10 })
  callbacks[0]()
  callbacks[1]()
  assert_eq(calls.val, 10)
  session.stop()
  @services.reset_clock()
}
