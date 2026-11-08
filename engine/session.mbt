///|
fn default_run_error(error : RunFailure) -> Unit {
  println("[engine] \{error.stage}: \{error.message}")
}

///|
pub fn RunSession::new(
  clock~ : () -> Double = @runtime.capture_clock(),
  on_error~ : (RunFailure) -> Unit = default_run_error,
) -> RunSession {
  {
    state: Starting,
    clock,
    report: on_error,
    disposers: [],
    cancel_frame: None,
    frame: None,
    frame_generation: 0,
  }
}

///|
pub fn RunSession::status(self : RunSession) -> RunStatus {
  self.state
}

///|
pub fn RunSession::is_active(self : RunSession) -> Bool {
  self.state is Starting || self.state is Running
}

///|
pub fn RunSession::now_ms(self : RunSession) -> Double {
  (self.clock)()
}

///|
pub fn RunSession::own(self : RunSession, dispose : () -> Unit) -> Unit {
  if self.is_active() {
    self.disposers.push(dispose)
  } else {
    dispose()
  }
}

///|
fn RunSession::dispose(self : RunSession) -> Unit {
  self.frame_generation += 1
  self.frame = None
  match self.cancel_frame {
    Some(cancel) => {
      self.cancel_frame = None
      cancel()
    }
    None => ()
  }
  while self.disposers.length() > 0 {
    let dispose = self.disposers.pop().unwrap()
    dispose()
  }
}

///|
pub fn RunSession::stop(self : RunSession) -> Unit {
  if self.is_active() {
    self.state = Stopped
    self.dispose()
  }
}

///|
pub fn RunSession::fail(
  self : RunSession,
  stage : RunStage,
  message : String,
) -> Unit {
  if !self.is_active() {
    return
  }
  let failure = { stage, message, }
  self.state = Failed(failure)
  self.dispose()
  (self.report)(failure)
}

///|
fn RunSession::ready(self : RunSession) -> Unit {
  if self.state is Starting {
    self.state = Running
  }
}

///|
fn RunSession::set_frame(self : RunSession, frame : () -> Unit) -> Unit {
  if self.is_active() {
    self.frame = Some(frame)
  }
}

///|
pub fn RunSession::step(self : RunSession) -> Unit {
  if self.is_active() {
    match self.frame {
      Some(frame) => frame()
      None => ()
    }
  }
}

///|
pub fn RunSession::schedule(
  self : RunSession,
  host : @services.FrameHost,
  frame : () -> Unit,
) -> Unit {
  if !self.is_active() {
    return
  }
  self.frame_generation += 1
  let generation = self.frame_generation
  match self.cancel_frame {
    Some(cancel) => {
      self.cancel_frame = None
      cancel()
    }
    None => ()
  }
  let cancel = (host.request_frame)(fn() {
    if self.frame_generation != generation {
      return
    }
    self.cancel_frame = None
    if self.is_active() {
      frame()
    }
  })
  if self.is_active() {
    self.cancel_frame = Some(cancel)
  } else {
    cancel()
  }
}

///|
pub fn RunSession::watch_exit(
  self : RunSession,
  host : @services.FrameHost,
) -> Unit {
  self.own((host.on_exit)(fn() { self.stop() }))
}

///|
// Current graphics hooks own one GPU runtime per realm. Reject concurrent
// starts before invoking installers; independent hosts can own independent sessions.
let backend_claimed : Ref[Bool] = Ref(false)

///|
fn RunSession::claim_backend(self : RunSession) -> Bool {
  if backend_claimed.val {
    self.fail(
      Backend,
      "A graphics session is already running; stop it before starting another",
    )
    false
  } else {
    backend_claimed.val = true
    self.own(fn() { backend_claimed.val = false })
    true
  }
}
