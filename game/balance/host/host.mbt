///|
pub fn create(
  initial : String,
  sigma : Double,
  seed : Int32,
) -> @balance.Search {
  @balance.Search::new(@balance.decode_vector(initial), sigma, seed) catch {
    _ => abort("invalid_search")
  }
}

///|
pub fn ask(search : @balance.Search) -> String {
  let population = search.ask() catch {
    _ => return "{\"error\":\"awaiting_fitness\"}"
  }
  let values : Array[Json] = population.map(p => @json.ToJson::to_json(p))
  Json::array(values).stringify()
}

///|
pub fn tell(search : @balance.Search, fitness : String) -> String {
  try {
    search.tell(@balance.decode_vector(fitness))
    "applied"
  } catch {
    _ => "invalid_fitness"
  }
}
