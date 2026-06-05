// Contract layer for the Machinations economy model.
//
// This defines the full node/connection vocabulary (Pool, Source, Drain, Gate,
// Converter, Trader, Delay, Queue, Register; resource and state connections;
// activation modes; push/pull) so the type surface is stable. The simulation
// engine (step.mbt) fills in behaviour in phases — Phase 1 covers Pool / Source
// / Drain with fixed-rate pull/push; later phases add gates, state connections,
// converters/traders/delays, and the remaining activation modes.

///|
/// Node archetypes from the Machinations framework.
pub(all) enum NodeKind {
  Pool // stores resources
  Source // infinite generator
  Drain // consumes / destroys resources
  Gate // non-storing router (distributes incoming to outgoing)
  Converter // consumes inputs, atomically produces outputs
  Trader // exchanges resources between pools
  Delay // holds a resource for N steps, then releases
  Queue // FIFO release at a rate
  Register // holds a numeric value (no resource flow; feeds state edges)
} derive(Eq)

///|
/// When a node fires.
pub(all) enum Activation {
  Passive // only reacts when pulled/pushed by others
  Automatic // fires every step
  Interactive // fires on user interaction
  OnTrigger // fires when triggered via a state edge
  Start // fires once, on the first step
} derive(Eq)

///|
/// Direction a node drives resource flow.
pub(all) enum Flow {
  Pull // pulls resources along incoming edges
  PullAll // pulls only if every incoming edge is fully satisfiable (atomic)
  Push // pushes resources along outgoing edges
} derive(Eq)

///|
/// How a Gate distributes incoming resources across its outgoing edges.
pub(all) enum GateMode {
  Deterministic // split by edge weight ratios
  Probabilistic // pick an edge weighted-randomly
} derive(Eq)

///|
/// Flow-rate label on a resource connection.
pub(all) enum Rate {
  Fixed(Int) // a constant amount per activation
  Dice(Int, Int) // roll `count` dice of `sides` and sum
  Interval(Int) // emit 1 every N steps
  All // move everything available
} derive(Eq)

///|
/// Kind of a state (non-resource) connection.
pub(all) enum StateKind {
  Modifier // source value adjusts a target rate / value
  Trigger // a full flow on the source activates the target
  Activator // a condition on the source enables/disables the target
  RateLabel // source value overrides a connection's rate label
} derive(Eq)

///|
/// A diagram node. Position (x, y) is layout metadata; the engine ignores it.
pub(all) struct Node {
  kind : NodeKind
  label : String
  activation : Activation
  flow : Flow
  capacity : Int? // None = unlimited
  initial : Int // initial pool count / register value
  gate_mode : GateMode
  x : Double
  y : Double
}

///|
/// A resource connection: moves resources from `from` to `to` at `rate`.
/// `weight` is used for gate distribution (deterministic ratio / random weight).
pub(all) struct ResourceEdge {
  from : Int
  to : Int
  rate : Rate
  weight : Double
}

///|
/// A state connection: alters a target node or resource edge from a source
/// node's state. `to_node` / `to_edge` select the target (exactly one is set).
pub(all) struct StateEdge {
  from : Int
  to_node : Int?
  to_edge : Int?
  kind : StateKind
  factor : Double
}

///|
/// A complete economy diagram. Indices into `nodes` are the node ids; indices
/// into `resources` are the resource-edge ids referenced by state edges.
pub(all) struct Diagram {
  nodes : Array[Node]
  resources : Array[ResourceEdge]
  states : Array[StateEdge]
}

///|
/// Mutable simulation state, advanced one step at a time by `step`.
pub(all) struct SimState {
  mut values : Array[Int] // per-node resource count / register value
  mut step : Int // completed-step counter
  mut rng : UInt64 // deterministic RNG state
  mut last_flows : Array[Int] // amount moved per resource edge last step (for viz)
  mut pending : Array[Bool] // interactive activations queued for the next step
}
