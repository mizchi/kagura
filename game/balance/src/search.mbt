///|
/// Stateful ask/tell adapter. Game evaluation stays outside the optimizer and
/// may be asynchronous (for example Jev). Coordinates are normalized to [0,1].
pub struct Search {
  cma : @optimizer.CmaEs
  mut pending : Array[Array[Double]]?
}

///|
pub fn Search::new(
  initial : Array[Double],
  sigma : Double,
  seed : Int32,
) -> Search raise {
  if initial.is_empty() ||
    initial.length() > 32 ||
    !(sigma > 0.0 && sigma <= 1.0) ||
    initial.any(v => !(v >= 0.0 && v <= 1.0)) {
    fail("invalid_search")
  }
  { cma: @optimizer.CmaEs::new(initial, sigma, seed~), pending: None, }
}

///|
pub fn Search::generation(self : Search) -> Int32 {
  self.cma.generation
}

///|
pub fn Search::ask(self : Search) -> Array[Array[Double]] raise {
  if self.pending is Some(_) {
    fail("awaiting_fitness")
  }
  let population = self.cma.sample_population()
  self.pending = Some(population)
  population.map(p => p.copy())
}

///|
pub fn Search::tell(self : Search, losses : Array[Double]) -> Unit raise {
  guard self.pending is Some(population) else { fail("no_population") }
  if losses.length() != population.length() ||
    losses.any(v => !(v >= 0.0 && v < 1.0e100)) {
    fail("invalid_fitness")
  }
  let ranked = losses.mapi((i, loss) => (loss, i))
  ranked.sort_by((a, b) => a.0.compare(b.0))
  self.cma.update(ranked.map(entry => population[entry.1]))
  self.pending = None
}

///|
pub fn decode_vector(source : String) -> Array[Double] raise {
  let data = @json.parse(source)
  guard data is Array(values) else { fail("invalid_vector") }
  values.map(value => {
    guard value is Number(n, ..) else { fail("invalid_number") }
    n
  })
}
