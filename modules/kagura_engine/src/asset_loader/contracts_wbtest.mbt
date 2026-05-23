///|
struct PendingFetch {
  url : String
  callback : (@atlas.ImageSpec?) -> Unit
}

///|
struct FetchStub {
  pending : Array[PendingFetch]
}

///|
fn new_fetch_stub() -> FetchStub {
  { pending: [] }
}

///|
fn enqueue_stub_fetch(
  stub : FetchStub,
  url : String,
  callback : (@atlas.ImageSpec?) -> Unit,
) -> Unit {
  stub.pending.push({ url, callback })
}

///|
fn success_spec(seed : Int) -> @atlas.ImageSpec {
  if seed % 2 == 0 {
    @atlas.image_spec_with_rgba8(2, 2, [
      255, 0, 0, 255, 0, 255, 0, 255, 0, 0, 255, 255, 255, 255, 255, 255,
    ])
  } else {
    @atlas.image_spec_with_rgba8(2, 2, [
      0, 0, 0, 255, 255, 255, 255, 255, 10, 20, 30, 255, 200, 210, 220, 255,
    ])
  }
}

///|
test "enqueue/start_pending transitions Pending -> Loading" {
  let stub = new_fetch_stub()
  let loader = AsyncImageLoader::new(fetch_image_fn=fn(url, callback) {
    enqueue_stub_fetch(stub, url, callback)
  })
  let id = loader.enqueue(@atlas.new_asset_key("async/pending"), "/a.png")
  let before = loader.progress()
  assert_eq(before.total, 1)
  assert_eq(before.pending, 1)
  assert_eq(before.loading, 0)
  let started = loader.start_pending()
  assert_eq(started, 1)
  assert_eq(stub.pending.length(), 1)
  assert_eq(stub.pending[0].url, "/a.png")
  let after = loader.progress()
  assert_eq(after.pending, 0)
  assert_eq(after.loading, 1)
  match loader.request(id) {
    Some(req) => assert_eq(req.status.to_int(), 1)
    None => panic()
  }
}

///|
test "successful callback updates status and completed queue" {
  let stub = new_fetch_stub()
  let loader = AsyncImageLoader::new(fetch_image_fn=fn(url, callback) {
    enqueue_stub_fetch(stub, url, callback)
  })
  let id = loader.enqueue(@atlas.new_asset_key("async/success"), "/ok.png")
  ignore(loader.start_pending())
  (stub.pending[0].callback)(Some(success_spec(0)))
  let progress = loader.progress()
  assert_eq(progress.loading, 0)
  assert_eq(progress.succeeded, 1)
  let completed = loader.drain_completed()
  assert_eq(completed.length(), 1)
  assert_eq(completed[0], id)
  let completed2 = loader.drain_completed()
  assert_eq(completed2.length(), 0)
  match loader.request(id) {
    Some(req) => assert_eq(req.status.to_int(), 2)
    None => panic()
  }
}

///|
test "failed callback updates status to Failed" {
  let stub = new_fetch_stub()
  let loader = AsyncImageLoader::new(fetch_image_fn=fn(url, callback) {
    enqueue_stub_fetch(stub, url, callback)
  })
  let id = loader.enqueue(@atlas.new_asset_key("async/fail"), "/ng.png")
  ignore(loader.start_pending())
  (stub.pending[0].callback)(None)
  let progress = loader.progress()
  assert_eq(progress.loading, 0)
  assert_eq(progress.failed, 1)
  match loader.request(id) {
    Some(req) => assert_eq(req.status.to_int(), 3)
    None => panic()
  }
}

///|
test "commit_image creates then updates repository entry" {
  let stub = new_fetch_stub()
  let loader = AsyncImageLoader::new(fetch_image_fn=fn(url, callback) {
    enqueue_stub_fetch(stub, url, callback)
  })
  let repo = @atlas.new_simple_image_repository()
  let key = @atlas.new_asset_key("async/commit")

  let id1 = loader.enqueue(key, "/v1.png")
  ignore(loader.start_pending())
  (stub.pending[0].callback)(Some(success_spec(0)))
  let handle1 = loader.commit_image(id1, repo)
  match handle1 {
    Some(h) => {
      assert_true(h.id > 0)
      assert_eq(@atlas.get_image_generation_by_id(repo, h.id), 1)
    }
    None => panic()
  }

  let id2 = loader.enqueue(key, "/v2.png")
  ignore(loader.start_pending())
  (stub.pending[1].callback)(Some(success_spec(1)))
  let handle2 = loader.commit_image(id2, repo)
  match (handle1, handle2) {
    (Some(h1), Some(h2)) => {
      assert_eq(h1.id, h2.id)
      assert_eq(@atlas.get_image_generation_by_id(repo, h2.id), 2)
    }
    _ => panic()
  }
}
