///|
test "AssetStreamer: basic request and update" {
  let fetcher = new_mock_fetcher()
  let streamer = new_asset_streamer(fetcher, config=default_streamer_config())
  let mut received = false
  let key = @asset.new_asset_key("test")
  ignore(
    streamer.request("test.png", key, Normal, fn(data) {
      match data {
        Some(_) => received = true
        None => ()
      }
    }),
  )
  streamer.update()
  assert_eq(streamer.progress().active, 1)
  complete_mock(fetcher, 0, Some(b"data"))
  streamer.update()
  assert_true(received)
}

///|
test "AssetStreamer: duplicate request returns same id" {
  let fetcher = new_mock_fetcher()
  let streamer = new_asset_streamer(fetcher, config=default_streamer_config())
  let key = @asset.new_asset_key("dup")
  let id1 = streamer.request("a.png", key, Normal, fn(_) {  })
  let id2 = streamer.request("a.png", key, Normal, fn(_) {  })
  assert_eq(id1, id2)
  // Only one fetch should have been enqueued
  streamer.update()
  assert_eq(fetcher.requests.length(), 1)
}

///|
test "AssetStreamer: duplicate request fans out completion callbacks" {
  let fetcher = new_mock_fetcher()
  let streamer = new_asset_streamer(fetcher, config=default_streamer_config())
  let key = @asset.new_asset_key("dup-fanout")
  let completions : Array[String] = []
  ignore(
    streamer.request("fanout.png", key, Normal, fn(data) {
      match data {
        Some(_) => completions.push("first")
        None => ()
      }
    }),
  )
  ignore(
    streamer.request("fanout.png", key, Normal, fn(data) {
      match data {
        Some(_) => completions.push("second")
        None => ()
      }
    }),
  )
  streamer.update()
  complete_mock(fetcher, 0, Some(b"fanout"))
  streamer.update()
  assert_eq(completions, ["first", "second"])
}

///|
test "AssetStreamer: distance-based priority" {
  let fetcher = new_mock_fetcher()
  let streamer = new_asset_streamer(fetcher, config={
    ..default_streamer_config(),
    max_concurrent: 1,
  })
  let thresholds = default_distance_thresholds()
  // Request far object first, then close object
  ignore(
    streamer.request_by_distance(
      "far.png",
      @asset.new_asset_key("far"),
      100.0,
      thresholds~,
      on_complete=fn(_) {  },
    ),
  )
  ignore(
    streamer.request_by_distance(
      "close.png",
      @asset.new_asset_key("close"),
      5.0,
      thresholds~,
      on_complete=fn(_) {  },
    ),
  )
  streamer.update()
  // Close object (Critical priority) should be fetched first
  assert_eq(fetcher.requests[0].url, "close.png")
}

///|
test "AssetStreamer: LOD skip duplicate" {
  let fetcher = new_mock_fetcher()
  let streamer = new_asset_streamer(fetcher, config=default_streamer_config())
  let key = @asset.new_asset_key("model")
  let id1 = streamer.request_lod("model_lod2.obj", key, 2, Normal, fn(_) {  })
  // Request same or lower LOD → should return same id
  let id2 = streamer.request_lod("model_lod1.obj", key, 1, Normal, fn(_) {  })
  assert_eq(id1, id2)
}

///|
test "AssetStreamer: LOD upgrade" {
  let fetcher = new_mock_fetcher()
  let streamer = new_asset_streamer(fetcher, config=default_streamer_config())
  let key = @asset.new_asset_key("model")
  let id1 = streamer.request_lod("model_lod1.obj", key, 1, Normal, fn(_) {  })
  // Request higher LOD → should create new request
  let id2 = streamer.request_lod("model_lod2.obj", key, 2, High, fn(_) {  })
  assert_true(id1 != id2)
}

///|
test "AssetStreamer: eviction" {
  let evicted : Array[String] = []
  let config : AssetStreamerConfig = {
    max_concurrent: 4,
    max_cached: 2,
    eviction_interval: 1, // sweep every frame
  }
  let fetcher = new_mock_fetcher()
  let streamer = new_asset_streamer(fetcher, config~, on_evict=fn(key) {
    evicted.push(key.value)
  })
  // Add 3 entries
  ignore(
    streamer.request("a.png", @asset.new_asset_key("a"), Normal, fn(_) {  }),
  )
  streamer.update() // frame 0→1
  ignore(
    streamer.request("b.png", @asset.new_asset_key("b"), Normal, fn(_) {  }),
  )
  streamer.update() // frame 1→2
  ignore(
    streamer.request("c.png", @asset.new_asset_key("c"), Normal, fn(_) {  }),
  )
  // Touch "b" to keep it alive
  streamer.touch(@asset.new_asset_key("b"))
  streamer.update() // frame 2→3, triggers eviction (3 > max_cached 2)
  // "a" should be evicted (oldest untouched)
  assert_eq(evicted.length(), 1)
  assert_eq(evicted[0], "a")
}

///|
test "AssetStreamer: manual evict" {
  let evicted : Array[String] = []
  let fetcher = new_mock_fetcher()
  let streamer = new_asset_streamer(fetcher, on_evict=fn(key) {
    evicted.push(key.value)
  })
  let key = @asset.new_asset_key("manual")
  ignore(streamer.request("m.png", key, Normal, fn(_) {  }))
  streamer.evict(key)
  assert_eq(evicted, ["manual"])
}

///|
test "AssetStreamer: payload released after callbacks fire (Delivered state)" {
  let fetcher = new_mock_fetcher()
  let streamer = new_asset_streamer(fetcher, config=default_streamer_config())
  let key = @asset.new_asset_key("release")
  let mut first_received = false
  ignore(
    streamer.request("release.png", key, Normal, fn(data) {
      match data {
        Some(_) => first_received = true
        None => ()
      }
    }),
  )
  streamer.update()
  complete_mock(fetcher, 0, Some(b"payload"))
  streamer.update()
  assert_true(first_received)
  // After completion, requesting the same key again should get None
  // because payload was released (Delivered state)
  let mut late_data : Bytes? = Some(b"should-be-none")
  ignore(
    streamer.request("release.png", key, Normal, fn(data) { late_data = data }),
  )
  assert_true(late_data is None)
}

///|
test "AssetStreamer: fetch failure delivers None to callbacks" {
  let fetcher = new_mock_fetcher()
  let streamer = new_asset_streamer(fetcher, config=default_streamer_config())
  let key = @asset.new_asset_key("fail")
  let mut received_data : Bytes? = Some(b"initial")
  ignore(
    streamer.request("fail.png", key, Normal, fn(data) { received_data = data }),
  )
  streamer.update()
  // Simulate fetch failure (None)
  complete_mock(fetcher, 0, None)
  streamer.update()
  assert_true(received_data is None)
}

///|
test "AssetStreamer: eviction of in-flight request cancels fetch" {
  let evicted : Array[String] = []
  let fetcher = new_mock_fetcher()
  let streamer = new_asset_streamer(fetcher, on_evict=fn(key) {
    evicted.push(key.value)
  })
  let key = @asset.new_asset_key("inflight")
  ignore(streamer.request("inflight.png", key, Normal, fn(_) {  }))
  streamer.update()
  assert_eq(fetcher.requests.length(), 1)
  assert_false(fetcher.requests[0].cancelled)
  // Evict while still in-flight
  streamer.evict(key)
  assert_true(fetcher.requests[0].cancelled)
  assert_eq(evicted, ["inflight"])
}

///|
test "AssetStreamer: LOD upgrade cancels previous in-flight fetch" {
  let fetcher = new_mock_fetcher()
  let streamer = new_asset_streamer(fetcher, config=default_streamer_config())
  let key = @asset.new_asset_key("lod-cancel")
  ignore(streamer.request_lod("model_lod1.obj", key, 1, Normal, fn(_) {  }))
  streamer.update()
  assert_eq(fetcher.requests.length(), 1)
  // Upgrade to higher LOD
  ignore(streamer.request_lod("model_lod2.obj", key, 2, High, fn(_) {  }))
  // Previous fetch should be cancelled
  assert_true(fetcher.requests[0].cancelled)
}

///|
test "reprioritize pending request" {
  let fetcher = new_mock_fetcher()
  let manager = new_asset_stream_manager(fetcher, max_concurrent=1)
  // Enqueue two Low requests, then reprioritize second to Critical
  let _id1 = manager.enqueue("first.png", Low, fn(_) {  })
  let id2 = manager.enqueue("second.png", Low, fn(_) {  })
  let ok = manager.reprioritize(id2, Critical)
  assert_true(ok)
  // Now start fetching — the reprioritized one should go first
  manager.update()
  assert_eq(fetcher.requests[0].url, "second.png")
}

///|
test "reprioritize non-existent returns false" {
  let fetcher = new_mock_fetcher()
  let manager = new_asset_stream_manager(fetcher, max_concurrent=1)
  let ok = manager.reprioritize(999, Critical)
  assert_false(ok)
}
