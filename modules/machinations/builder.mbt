// Type-safe builder DSL for authoring diagrams in MoonBit code.
//
//   let dg = Diagram::new()
//   let src = dg.source("mine", flow=Push, rate_out=...)   // see connect()
//   let gold = dg.pool("gold", initial=0, x=120.0, y=40.0)
//   let sink = dg.drain("upkeep")
//   dg.connect(src, gold, rate=Fixed(2))
//   dg.connect(gold, sink, rate=Fixed(1))

///|
/// An empty diagram.
pub fn Diagram::new() -> Diagram {
  { nodes: [], resources: [], states: [] }
}

///|
fn Diagram::add(self : Diagram, node : Node) -> Int {
  self.nodes.push(node)
  self.nodes.length() - 1
}

///|
/// Add a node of any kind. Returns the node id (index into `nodes`).
pub fn Diagram::node(
  self : Diagram,
  kind : NodeKind,
  label : String,
  initial? : Int = 0,
  capacity? : Int? = None,
  flow? : Flow = Pull,
  activation? : Activation = Passive,
  gate_mode? : GateMode = Deterministic,
  param? : Int = 0,
  x? : Double = 0.0,
  y? : Double = 0.0,
) -> Int {
  self.add({
    kind,
    label,
    activation,
    flow,
    capacity,
    initial,
    gate_mode,
    param,
    x,
    y,
  })
}

///|
/// A storage pool. Default: passive, pull.
pub fn Diagram::pool(
  self : Diagram,
  label : String,
  initial? : Int = 0,
  capacity? : Int? = None,
  flow? : Flow = Pull,
  activation? : Activation = Passive,
  x? : Double = 0.0,
  y? : Double = 0.0,
) -> Int {
  self.node(Pool, label, initial~, capacity~, flow~, activation~, x~, y~)
}

///|
/// An infinite source. Default: automatic, push.
pub fn Diagram::source(
  self : Diagram,
  label : String,
  flow? : Flow = Push,
  activation? : Activation = Automatic,
  x? : Double = 0.0,
  y? : Double = 0.0,
) -> Int {
  self.node(Source, label, flow~, activation~, x~, y~)
}

///|
/// A drain. Default: automatic, pull.
pub fn Diagram::drain(
  self : Diagram,
  label : String,
  flow? : Flow = Pull,
  activation? : Activation = Automatic,
  x? : Double = 0.0,
  y? : Double = 0.0,
) -> Int {
  self.node(Drain, label, flow~, activation~, x~, y~)
}

///|
/// A gate (non-storing router). Default: automatic, pull, deterministic split.
pub fn Diagram::gate(
  self : Diagram,
  label : String,
  flow? : Flow = Pull,
  activation? : Activation = Automatic,
  gate_mode? : GateMode = Deterministic,
  x? : Double = 0.0,
  y? : Double = 0.0,
) -> Int {
  self.node(Gate, label, flow~, activation~, gate_mode~, x~, y~)
}

///|
/// A converter (atomically turns inputs into outputs). Default: automatic.
pub fn Diagram::converter(
  self : Diagram,
  label : String,
  activation? : Activation = Automatic,
  x? : Double = 0.0,
  y? : Double = 0.0,
) -> Int {
  self.node(Converter, label, activation~, x~, y~)
}

///|
/// A trader (atomic resource exchange). Same resolution as a converter.
pub fn Diagram::trader(
  self : Diagram,
  label : String,
  activation? : Activation = Automatic,
  x? : Double = 0.0,
  y? : Double = 0.0,
) -> Int {
  self.node(Trader, label, activation~, x~, y~)
}

///|
/// A register: holds a numeric value that feeds state connections.
pub fn Diagram::register(
  self : Diagram,
  label : String,
  value? : Int = 0,
  x? : Double = 0.0,
  y? : Double = 0.0,
) -> Int {
  self.node(Register, label, initial=value, x~, y~)
}

///|
/// A delay: holds incoming resources for `steps` steps, then releases them.
pub fn Diagram::delay(
  self : Diagram,
  label : String,
  steps? : Int = 1,
  activation? : Activation = Automatic,
  x? : Double = 0.0,
  y? : Double = 0.0,
) -> Int {
  self.node(Delay, label, activation~, param=steps, x~, y~)
}

///|
/// A queue: stores incoming and releases up to `rate` per step (FIFO).
pub fn Diagram::queue(
  self : Diagram,
  label : String,
  rate? : Int = 1,
  activation? : Activation = Automatic,
  x? : Double = 0.0,
  y? : Double = 0.0,
) -> Int {
  self.node(Queue, label, activation~, param=rate, x~, y~)
}

///|
/// Connect two nodes with a resource flow. Returns the resource-edge id.
pub fn Diagram::connect(
  self : Diagram,
  from : Int,
  to : Int,
  rate? : Rate = Fixed(1),
  weight? : Double = 1.0,
) -> Int {
  self.resources.push({ from, to, rate, weight })
  self.resources.length() - 1
}

///|
/// Add a state connection targeting a node (Trigger / Activator).
pub fn Diagram::state_to_node(
  self : Diagram,
  from : Int,
  to : Int,
  kind : StateKind,
  factor? : Double = 1.0,
) -> Int {
  self.states.push({ from, to_node: Some(to), to_edge: None, kind, factor })
  self.states.length() - 1
}

///|
/// Add a state connection targeting a resource edge (Modifier / RateLabel).
pub fn Diagram::state_to_edge(
  self : Diagram,
  from : Int,
  edge : Int,
  kind : StateKind,
  factor? : Double = 1.0,
) -> Int {
  self.states.push({ from, to_node: None, to_edge: Some(edge), kind, factor })
  self.states.length() - 1
}
