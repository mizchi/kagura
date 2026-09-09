///|
test "parse_capture_config reads the three paths and the binarize flag" {
  let text =
    #|screenshot_path=/tmp/out/frame.png
    #|context_path=/tmp/out/context.json
    #|summary_path=/tmp/out/summary.txt
    #|binarize=1
    #|
  match parse_capture_config(text) {
    Some(config) => {
      assert_eq(config.screenshot_path, "/tmp/out/frame.png")
      assert_eq(config.context_path, "/tmp/out/context.json")
      assert_eq(config.summary_path, "/tmp/out/summary.txt")
      assert_true(config.binarize)
    }
    None => fail("expected a parsed config")
  }
}

///|
test "parse_capture_config defaults binarize to false" {
  let text =
    #|screenshot_path=a.png
    #|context_path=b.json
    #|summary_path=c.txt
    #|
  match parse_capture_config(text) {
    Some(config) => assert_false(config.binarize)
    None => fail("expected a parsed config")
  }
}

///|
test "parse_capture_config accepts the truthy spellings a driver may write" {
  for value in ["1", "true", "TRUE"] {
    let text = "screenshot_path=a.png\ncontext_path=b.json\nsummary_path=c.txt\nbinarize=" +
      value
    match parse_capture_config(text) {
      Some(config) => assert_true(config.binarize)
      None => fail("expected a parsed config for binarize=" + value)
    }
  }
  for value in ["0", "false", "no", ""] {
    let text = "screenshot_path=a.png\ncontext_path=b.json\nsummary_path=c.txt\nbinarize=" +
      value
    match parse_capture_config(text) {
      Some(config) => assert_false(config.binarize)
      None => fail("expected a parsed config for binarize=" + value)
    }
  }
}

///|
/// A driver that mis-stages the file should be told, not aborted: a bare panic
/// from inside a headless run says nothing about which key was missing.
test "parse_capture_config rejects a config missing a required path" {
  assert_true(parse_capture_config("") is None)
  assert_true(parse_capture_config("screenshot_path=a.png") is None)
  assert_true(
    parse_capture_config("screenshot_path=a.png\ncontext_path=b.json") is None,
  )
  assert_true(
    parse_capture_config(
      "screenshot_path=\ncontext_path=b.json\nsummary_path=c.txt",
    )
    is None,
  )
}

///|
test "parse_capture_config tolerates blank lines, padding and CRLF" {
  let text = "\r\n  screenshot_path =  a.png \r\n\r\ncontext_path=b.json\r\nsummary_path=c.txt\r\n"
  match parse_capture_config(text) {
    Some(config) => {
      assert_eq(config.screenshot_path, "a.png")
      assert_eq(config.context_path, "b.json")
      assert_eq(config.summary_path, "c.txt")
    }
    None => fail("expected a parsed config")
  }
}

///|
/// Windows paths carry `=` in neither key nor value, but a value may; splitting
/// on the first `=` keeps such a value intact.
test "parse_capture_config splits on the first equals only" {
  let text = "screenshot_path=C:/out/a=b.png\ncontext_path=b.json\nsummary_path=c.txt"
  match parse_capture_config(text) {
    Some(config) => assert_eq(config.screenshot_path, "C:/out/a=b.png")
    None => fail("expected a parsed config")
  }
}

///|
test "parse_capture_config ignores lines that are not assignments" {
  let text = "# a comment\nnot an assignment\n=novalue\nscreenshot_path=a.png\ncontext_path=b.json\nsummary_path=c.txt"
  assert_true(parse_capture_config(text) is Some(_))
}

///|
test "capture_bytes_to_string decodes ascii config bytes" {
  assert_eq(capture_bytes_to_string(b"a=1\nb=2"), "a=1\nb=2")
  assert_eq(capture_bytes_to_string(b""), "")
}

///|
test "binarize_luma thresholds at mid grey" {
  assert_eq(binarize_luma(0, 0, 0), 0)
  assert_eq(binarize_luma(255, 255, 255), 255)
  assert_eq(binarize_luma(128, 128, 128), 255)
  assert_eq(binarize_luma(127, 127, 127), 0)
  // Green dominates the luma weights: full green reads as light while full
  // blue, at the same channel value, reads as dark.
  assert_eq(binarize_luma(0, 255, 0), 255)
  assert_eq(binarize_luma(0, 0, 255), 0)
}

///|
test "binarize_rgba8 collapses colour and preserves alpha" {
  let pixels = [255, 255, 255, 10, 0, 0, 0, 20, 0, 0, 200, 30]
  binarize_rgba8(pixels)
  assert_eq(pixels, [255, 255, 255, 10, 0, 0, 0, 20, 0, 0, 0, 30])
}

///|
/// A truncated final pixel must not make the loop read past the buffer.
test "binarize_rgba8 leaves a partial trailing pixel alone" {
  let pixels = [255, 255, 255, 1, 255, 255]
  binarize_rgba8(pixels)
  assert_eq(pixels, [255, 255, 255, 1, 255, 255])
  let empty : Array[Int] = []
  binarize_rgba8(empty)
  assert_eq(empty.length(), 0)
}

///|
test "encode_rgba8_png produces a PNG signature" {
  let pixels : Array[Int] = []
  for _ in 0..<(2 * 2) {
    pixels.push(10)
    pixels.push(20)
    pixels.push(30)
    pixels.push(255)
  }
  match encode_rgba8_png(2, 2, pixels) {
    Some(png) => {
      assert_true(png.length() > 8)
      assert_eq(png[0].to_int(), 0x89)
      assert_eq(png[1].to_int(), 0x50)
      assert_eq(png[2].to_int(), 0x4E)
      assert_eq(png[3].to_int(), 0x47)
    }
    None => fail("expected an encoded PNG")
  }
}
