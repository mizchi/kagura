///|
fn sample_codec_spec() -> ImageSpec {
  image_spec_with_rgba8(2, 2, [
    255, 0, 0, 255, 0, 255, 0, 255, 0, 0, 255, 255, 255, 255, 255, 255,
  ])
}

///|
test "detect_raster_image_format identifies png jpeg bmp" {
  let source = sample_codec_spec()
  let png = encode_png_image_spec(source) catch { _ => panic() }
  let jpeg = encode_jpeg_image_spec(source, quality=95) catch { _ => panic() }
  let bmp = encode_bmp_image_spec(source) catch { _ => panic() }
  assert_eq(detect_raster_image_format(png), Some(RasterImageFormat::Png))
  assert_eq(detect_raster_image_format(jpeg), Some(RasterImageFormat::Jpeg))
  assert_eq(detect_raster_image_format(bmp), Some(RasterImageFormat::Bmp))
  let unknown = Bytes::from_array([Int::to_byte(1), Int::to_byte(2)])
  assert_eq(detect_raster_image_format(unknown), None)
}

///|
test "png encode/decode roundtrip keeps exact channels" {
  let source = sample_codec_spec()
  let encoded = encode_png_image_spec(source) catch { _ => panic() }
  let decoded = decode_png_image_spec(encoded) catch { _ => panic() }
  assert_eq(decoded.width, 2)
  assert_eq(decoded.height, 2)
  assert_eq(decoded.pixels_rgba8.length(), 16)
  assert_eq(decoded.pixels_rgba8[0], 255)
  assert_eq(decoded.pixels_rgba8[1], 0)
  assert_eq(decoded.pixels_rgba8[2], 0)
  assert_eq(decoded.pixels_rgba8[3], 255)
  assert_eq(decoded.pixels_rgba8[12], 255)
  assert_eq(decoded.pixels_rgba8[13], 255)
  assert_eq(decoded.pixels_rgba8[14], 255)
  assert_eq(decoded.pixels_rgba8[15], 255)
}

///|
test "decode_image_spec_auto uses detected format" {
  let source = sample_codec_spec()
  let png = encode_png_image_spec(source) catch { _ => panic() }
  let decoded = decode_image_spec_auto(png) catch { _ => panic() }
  match decoded {
    Some(spec) => {
      assert_eq(spec.width, 2)
      assert_eq(spec.height, 2)
      assert_eq(spec.pixels_rgba8.length(), 16)
    }
    None => panic()
  }
}

///|
test "create_image_from_raster_bytes decodes and creates repository image" {
  let source = sample_codec_spec()
  let png = encode_png_image_spec(source) catch { _ => panic() }
  let repo = new_simple_image_repository()
  let key = new_asset_key("codec/create")
  let created = create_image_from_raster_bytes(repo, key, png) catch {
    _ => panic()
  }
  match created {
    Some(handle) => {
      assert_eq(handle.width, 2)
      assert_eq(handle.height, 2)
      assert_eq(get_image_generation_by_id(repo, handle.id), 1)
    }
    None => panic()
  }
}

///|
test "update_image_from_raster_bytes updates existing image generation" {
  let source = sample_codec_spec()
  let png0 = encode_png_image_spec(source) catch { _ => panic() }
  let changed = image_spec_with_rgba8(2, 2, [
    254, 0, 0, 255, 0, 255, 0, 255, 0, 0, 255, 255, 255, 255, 255, 255,
  ])
  let png1 = encode_png_image_spec(changed) catch { _ => panic() }
  let repo = new_simple_image_repository()
  let key = new_asset_key("codec/update")
  let created = create_image_from_raster_bytes(repo, key, png0) catch {
    _ => panic()
  }
  let created_handle = match created {
    Some(handle) => handle
    None => panic()
  }
  let updated = update_image_from_raster_bytes(repo, key, png1) catch {
    _ => panic()
  }
  match updated {
    Some(handle2) => {
      assert_eq(handle2.id, created_handle.id)
      assert_eq(handle2.width, 2)
      assert_eq(handle2.height, 2)
    }
    None => panic()
  }
  assert_eq(get_image_generation_by_id(repo, created_handle.id), 2)
}

///|
test "create_image_from_raster_bytes returns none on unknown format" {
  let repo = new_simple_image_repository()
  let key = new_asset_key("codec/unknown")
  let unknown = Bytes::from_array([Int::to_byte(1), Int::to_byte(2)])
  let created = create_image_from_raster_bytes(repo, key, unknown) catch {
    _ => panic()
  }
  match created {
    Some(_) => panic()
    None => ()
  }
}

///|
test "bmp encode/decode roundtrip keeps dimensions and pixel length" {
  let source = sample_codec_spec()
  let encoded = encode_bmp_image_spec(source) catch { _ => panic() }
  let decoded = decode_bmp_image_spec(encoded) catch { _ => panic() }
  assert_eq(decoded.width, 2)
  assert_eq(decoded.height, 2)
  assert_eq(decoded.pixels_rgba8.length(), 16)
}

///|
test "jpeg encode/decode keeps dimensions" {
  let source = sample_codec_spec()
  let encoded = encode_jpeg_image_spec(source, quality=95) catch {
    _ => panic()
  }
  let decoded = decode_jpeg_image_spec(encoded) catch { _ => panic() }
  assert_eq(decoded.width, 2)
  assert_eq(decoded.height, 2)
  assert_eq(decoded.pixels_rgba8.length(), 16)
}

///|
test "encode_image_spec dispatches by target format" {
  let source = sample_codec_spec()
  let encoded_png = encode_image_spec(source, RasterImageFormat::Png) catch {
    _ => panic()
  }
  assert_eq(
    detect_raster_image_format(encoded_png),
    Some(RasterImageFormat::Png),
  )
  let encoded_jpeg = encode_image_spec(source, RasterImageFormat::Jpeg) catch {
    _ => panic()
  }
  assert_eq(
    detect_raster_image_format(encoded_jpeg),
    Some(RasterImageFormat::Jpeg),
  )
  let encoded_bmp = encode_image_spec(source, RasterImageFormat::Bmp) catch {
    _ => panic()
  }
  assert_eq(
    detect_raster_image_format(encoded_bmp),
    Some(RasterImageFormat::Bmp),
  )
}

///|
test "resize image spec with nearest updates dimensions and payload length" {
  let source = sample_codec_spec()
  let resized = resize_image_spec(source, 4, 3, Nearest) catch { _ => panic() }
  assert_eq(resized.width, 4)
  assert_eq(resized.height, 3)
  assert_eq(resized.pixels_rgba8.length(), 4 * 3 * 4)
}
