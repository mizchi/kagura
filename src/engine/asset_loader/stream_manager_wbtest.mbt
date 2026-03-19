///|
struct MockRequest {
  id : Int
  url : String
  _on_progress : (@asset.FetchProgress) -> Unit
  on_complete : (Bytes?) -> Unit
  mut cancelled : Bool
}

///|
struct MockFetcher {
  mut next_id : Int
  requests : Array[MockRequest]
}

///|
fn new_mock_fetcher() -> MockFetcher {
  { next_id: 1, requests: [] }
}

///|
impl @asset.BytesFetcher for MockFetcher with fetch(
  self,
  url,
  on_progress,
  on_complete,
) {
  let id = self.next_id
  self.next_id = self.next_id + 1
  self.requests.push({
    id,
    url,
    _on_progress: on_progress,
    on_complete,
    cancelled: false,
  })
  { id, }
}

///|
impl @asset.BytesFetcher for MockFetcher with cancel(self, handle) {
  for req in self.requests {
    if req.id == handle.id {
      req.cancelled = true
    }
  }
}

///|
impl @asset.BytesFetcher for MockFetcher with poll(_) {
  // no-op for mock
}

///|
fn complete_mock(fetcher : MockFetcher, req_index : Int, data : Bytes?) -> Unit {
  let req = fetcher.requests[req_index]
  if not(req.cancelled) {
    (req.on_complete)(data)
  }
}

///|
test "priority ordering: Critical before Low" {
  let fetcher = new_mock_fetcher()
  let manager = new_asset_stream_manager(fetcher, max_concurrent=1)
  let order : Array[String] = []
  ignore(manager.enqueue("low.png", Low, fn(_) { order.push("low") }))
  ignore(
    manager.enqueue("critical.png", Critical, fn(_) { order.push("critical") }),
  )
  // First update starts the highest-priority request
  manager.update()
  let p = manager.progress()
  assert_eq(p.active, 1)
  assert_eq(p.pending, 1)
  // The active request should be critical.png
  assert_eq(fetcher.requests[0].url, "critical.png")
  // Complete it
  complete_mock(fetcher, 0, Some(b"data"))
  manager.update()
  // Now low.png should start
  assert_eq(fetcher.requests[1].url, "low.png")
  complete_mock(fetcher, 1, Some(b"data"))
  manager.update()
  assert_eq(order, ["critical", "low"])
}

///|
test "max_concurrent limits active requests" {
  let fetcher = new_mock_fetcher()
  let manager = new_asset_stream_manager(fetcher, max_concurrent=2)
  ignore(manager.enqueue("a.png", Normal, fn(_) {  }))
  ignore(manager.enqueue("b.png", Normal, fn(_) {  }))
  ignore(manager.enqueue("c.png", Normal, fn(_) {  }))
  manager.update()
  let p = manager.progress()
  assert_eq(p.active, 2)
  assert_eq(p.pending, 1)
  assert_eq(fetcher.requests.length(), 2)
}

///|
test "cancel pending request" {
  let fetcher = new_mock_fetcher()
  let manager = new_asset_stream_manager(fetcher, max_concurrent=1)
  let id = manager.enqueue("cancel-me.png", Normal, fn(_) { panic() })
  manager.cancel(id)
  manager.update()
  let p = manager.progress()
  assert_eq(p.pending, 0)
  assert_eq(p.active, 0)
}

///|
test "cancel active request" {
  let fetcher = new_mock_fetcher()
  let manager = new_asset_stream_manager(fetcher, max_concurrent=2)
  let id = manager.enqueue("active.png", Normal, fn(_) { panic() })
  manager.update()
  assert_eq(manager.progress().active, 1)
  manager.cancel(id)
  // The cancel should mark the fetcher request as cancelled
  assert_true(fetcher.requests[0].cancelled)
}

///|
test "progress tracking" {
  let fetcher = new_mock_fetcher()
  let manager = new_asset_stream_manager(fetcher, max_concurrent=4)
  ignore(manager.enqueue("a.png", Normal, fn(_) {  }))
  ignore(manager.enqueue("b.png", Normal, fn(_) {  }))
  ignore(manager.enqueue("c.png", Normal, fn(_) {  }))
  manager.update()
  let p1 = manager.progress()
  assert_eq(p1.total, 3)
  assert_eq(p1.active, 3)
  assert_eq(p1.pending, 0)
  // Complete one successfully, one with failure
  complete_mock(fetcher, 0, Some(b"ok"))
  complete_mock(fetcher, 1, None)
  manager.update()
  let p2 = manager.progress()
  assert_eq(p2.completed, 1)
  assert_eq(p2.failed, 1)
  assert_eq(p2.active, 1)
}
