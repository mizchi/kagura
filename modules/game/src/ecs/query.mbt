///|
/// Iterator-based query helpers. The walk uses the first store as the
/// driver and looks up the others; pass the smallest expected store first
/// when component overlap is sparse. Each helper skips entities whose
/// `World::is_alive` is false (generation mismatch or freed slot).
pub fn[A] query1(
  world : World,
  a : ComponentStore[A],
) -> Iter[(EntityId, A)] {
  a.iter_in(world)
}

///|
pub fn[A, B] query2(
  world : World,
  a : ComponentStore[A],
  b : ComponentStore[B],
) -> Iter[(EntityId, A, B)] {
  a.iter_in(world).filter_map(fn(entry) {
    let (eid, av) = entry
    match b.get(eid) {
      Some(bv) => Some((eid, av, bv))
      None => None
    }
  })
}

///|
pub fn[A, B, C] query3(
  world : World,
  a : ComponentStore[A],
  b : ComponentStore[B],
  c : ComponentStore[C],
) -> Iter[(EntityId, A, B, C)] {
  a.iter_in(world).filter_map(fn(entry) {
    let (eid, av) = entry
    match (b.get(eid), c.get(eid)) {
      (Some(bv), Some(cv)) => Some((eid, av, bv, cv))
      _ => None
    }
  })
}

///|
/// Direct-callback variants of `query*`. ~5x faster than the `Iter`
/// versions on the JS backend by skipping closure allocation per step.
pub fn[A] query1_each(
  world : World,
  a : ComponentStore[A],
  f : (EntityId, A) -> Unit,
) -> Unit {
  a.each_in(world, f)
}

///|
pub fn[A, B] query2_each(
  world : World,
  a : ComponentStore[A],
  b : ComponentStore[B],
  f : (EntityId, A, B) -> Unit,
) -> Unit {
  let len = a.data.length()
  let wlen = world.alive.length()
  let blen = b.data.length()
  for i in 0..<len {
    if i >= wlen {
      break
    }
    if !world.alive[i] {
      continue
    }
    let gen = a.generations[i]
    if gen != world.generations[i] {
      continue
    }
    if i >= blen || b.generations[i] != gen {
      continue
    }
    match (a.data[i], b.data[i]) {
      (Some(av), Some(bv)) => f({ index: i, generation: gen }, av, bv)
      _ => ()
    }
  }
}

///|
pub fn[A, B, C] query3_each(
  world : World,
  a : ComponentStore[A],
  b : ComponentStore[B],
  c : ComponentStore[C],
  f : (EntityId, A, B, C) -> Unit,
) -> Unit {
  let len = a.data.length()
  let wlen = world.alive.length()
  let blen = b.data.length()
  let clen = c.data.length()
  for i in 0..<len {
    if i >= wlen {
      break
    }
    if !world.alive[i] {
      continue
    }
    let gen = a.generations[i]
    if gen != world.generations[i] {
      continue
    }
    if i >= blen || b.generations[i] != gen {
      continue
    }
    if i >= clen || c.generations[i] != gen {
      continue
    }
    match (a.data[i], b.data[i], c.data[i]) {
      (Some(av), Some(bv), Some(cv)) =>
        f({ index: i, generation: gen }, av, bv, cv)
      _ => ()
    }
  }
}

///|
/// Convenience: entities tagged with `tag`. Tags are stored as
/// `ComponentStore[Array[Tag]]`, matching the multi-tag-per-entity model.
pub fn entities_with_tag(
  world : World,
  tags : ComponentStore[Array[Tag]],
  tag : Tag,
) -> Iter[EntityId] {
  tags.iter_in(world).filter_map(fn(entry) {
    let (eid, ts) = entry
    if ts.contains(tag) {
      Some(eid)
    } else {
      None
    }
  })
}

///|
/// Add a tag to an entity, allocating the per-entity tag array on first use.
pub fn tags_add(
  tags : ComponentStore[Array[Tag]],
  eid : EntityId,
  tag : Tag,
) -> Unit {
  match tags.get(eid) {
    Some(ts) => ts.push(tag)
    None => tags.set(eid, [tag])
  }
}

///|
pub fn tags_has(
  tags : ComponentStore[Array[Tag]],
  eid : EntityId,
  tag : Tag,
) -> Bool {
  match tags.get(eid) {
    Some(ts) => ts.contains(tag)
    None => false
  }
}
