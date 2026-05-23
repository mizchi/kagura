///|
/// Lazy iterator over (entity, A) for live entities holding A. Chains with
/// `.filter`/`.map`/etc. for ad-hoc queries. Use `query1_each` from hot
/// loops — the callback variant skips the per-step closure overhead that
/// `Iter` pays on the JS backend.
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
/// Direct-callback variants of `query*`. Pass the smallest expected store
/// first; the walk drives the first store and looks up the rest.
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
  let ad = a.data
  let bd = b.data
  let alive = world.alive
  let alen = ad.length()
  let blen = bd.length()
  let wlen = alive.length()
  let mut bound = if alen < wlen { alen } else { wlen }
  if blen < bound {
    bound = blen
  }
  for i in 0..<bound {
    if !alive.unsafe_get(i) {
      continue
    }
    match (ad.unsafe_get(i), bd.unsafe_get(i)) {
      (Some(av), Some(bv)) => f({ index: i }, av, bv)
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
  let ad = a.data
  let bd = b.data
  let cd = c.data
  let alive = world.alive
  let alen = ad.length()
  let blen = bd.length()
  let clen = cd.length()
  let wlen = alive.length()
  let mut bound = if alen < wlen { alen } else { wlen }
  if blen < bound {
    bound = blen
  }
  if clen < bound {
    bound = clen
  }
  for i in 0..<bound {
    if !alive.unsafe_get(i) {
      continue
    }
    match (ad.unsafe_get(i), bd.unsafe_get(i), cd.unsafe_get(i)) {
      (Some(av), Some(bv), Some(cv)) => f({ index: i }, av, bv, cv)
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
/// Direct-callback variant of `entities_with_tag`.
pub fn entities_with_tag_each(
  world : World,
  tags : ComponentStore[Array[Tag]],
  tag : Tag,
  f : (EntityId) -> Unit,
) -> Unit {
  tags.each_in(world, fn(eid, ts) { if ts.contains(tag) { f(eid) } })
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
