///|
test "planned image palette registry stores clamped channels" {
  clear_planned_image_palette_registry()
  register_planned_image_palette(
    7, -10, 300, 64, 255, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12,
  )

  assert_eq(planned_image_palette_registry_count(), 1)
  assert_eq(planned_image_palette_generation(7), 1)
  assert_eq(planned_image_palette_channel(7, 0, 0), 0)
  assert_eq(planned_image_palette_channel(7, 0, 1), 255)
  assert_eq(planned_image_palette_channel(7, 0, 2), 64)
  assert_eq(planned_image_palette_channel(7, 0, 3), 255)
  assert_eq(planned_image_palette_channel(7, 1, 0), 1)
  assert_eq(planned_image_palette_channel(7, 1, 1), 2)
  assert_eq(planned_image_palette_channel(7, 1, 2), 3)
  assert_eq(planned_image_palette_channel(7, 1, 3), 4)
  assert_eq(planned_image_palette_channel(7, 2, 0), 5)
  assert_eq(planned_image_palette_channel(7, 2, 1), 6)
  assert_eq(planned_image_palette_channel(7, 2, 2), 7)
  assert_eq(planned_image_palette_channel(7, 2, 3), 8)
  assert_eq(planned_image_palette_channel(7, 3, 0), 9)
  assert_eq(planned_image_palette_channel(7, 3, 1), 10)
  assert_eq(planned_image_palette_channel(7, 3, 2), 11)
  assert_eq(planned_image_palette_channel(7, 3, 3), 12)
  assert_eq(planned_image_palette_channel(7, 4, 0), -1)
  assert_eq(planned_image_palette_channel(99, 0, 0), -1)
}

///|
test "planned image palette registry overwrites existing image id" {
  clear_planned_image_palette_registry()
  register_planned_image_palette(
    3, 1, 1, 1, 255, 1, 1, 1, 255, 1, 1, 1, 255, 1, 1, 1, 255,
  )
  register_planned_image_palette(
    3, 9, 8, 7, 6, 9, 8, 7, 6, 9, 8, 7, 6, 9, 8, 7, 6,
  )

  assert_eq(planned_image_palette_registry_count(), 1)
  assert_eq(planned_image_palette_generation(3), 2)
  assert_eq(planned_image_palette_channel(3, 0, 0), 9)
  assert_eq(planned_image_palette_channel(3, 0, 1), 8)
  assert_eq(planned_image_palette_channel(3, 0, 2), 7)
  assert_eq(planned_image_palette_channel(3, 0, 3), 6)
}

///|
test "planned source image registry stores uploaded rgba8 pixels" {
  clear_planned_source_image_registry()
  begin_planned_source_image_upload(40, 2, 2)
  set_planned_source_image_pixel(40, 0, 0, 1, 2, 3, 4)
  set_planned_source_image_pixel(40, 1, 0, 5, 6, 7, 8)
  set_planned_source_image_pixel(40, 0, 1, 9, 10, 11, 12)
  set_planned_source_image_pixel(40, 1, 1, 13, 14, 15, 16)
  end_planned_source_image_upload(40)

  assert_eq(planned_source_image_registry_count(), 1)
  assert_eq(planned_source_image_generation(40), 1)
  assert_eq(planned_source_image_width(40), 2)
  assert_eq(planned_source_image_height(40), 2)
  assert_eq(planned_source_image_pixel_channel(40, 0, 0, 0), 1)
  assert_eq(planned_source_image_pixel_channel(40, 1, 0, 1), 6)
  assert_eq(planned_source_image_pixel_channel(40, 0, 1, 2), 11)
  assert_eq(planned_source_image_pixel_channel(40, 1, 1, 3), 16)
  assert_eq(planned_source_image_pixel_channel(40, 9, 9, 0), -1)
}

///|
test "planned source image registry overwrites image dimensions on begin" {
  clear_planned_source_image_registry()
  begin_planned_source_image_upload(2, 1, 1)
  set_planned_source_image_pixel(2, 0, 0, 10, 20, 30, 40)
  end_planned_source_image_upload(2)

  begin_planned_source_image_upload(2, 3, 1)
  set_planned_source_image_pixel(2, 2, 0, 1, 2, 3, 4)
  end_planned_source_image_upload(2)

  assert_eq(planned_source_image_registry_count(), 1)
  assert_eq(planned_source_image_generation(2), 2)
  assert_eq(planned_source_image_width(2), 3)
  assert_eq(planned_source_image_height(2), 1)
  assert_eq(planned_source_image_pixel_channel(2, 2, 0, 0), 1)
  assert_eq(planned_source_image_pixel_channel(2, 2, 0, 1), 2)
  assert_eq(planned_source_image_pixel_channel(2, 2, 0, 2), 3)
  assert_eq(planned_source_image_pixel_channel(2, 2, 0, 3), 4)
}

///|
test "planned source image patch updates generation and modified pixels only" {
  clear_planned_source_image_registry()
  begin_planned_source_image_upload(9, 2, 2)
  set_planned_source_image_pixel(9, 0, 0, 1, 2, 3, 4)
  set_planned_source_image_pixel(9, 1, 0, 5, 6, 7, 8)
  set_planned_source_image_pixel(9, 0, 1, 9, 10, 11, 12)
  set_planned_source_image_pixel(9, 1, 1, 13, 14, 15, 16)
  end_planned_source_image_upload(9)
  assert_eq(planned_source_image_generation(9), 1)

  let began = begin_planned_source_image_patch(9)
  assert_true(began)
  set_planned_source_image_pixel(9, 1, 0, 101, 102, 103, 104)
  let patched = end_planned_source_image_patch(9)
  assert_true(patched)
  assert_eq(planned_source_image_generation(9), 2)
  assert_eq(planned_source_image_pixel_channel(9, 0, 0, 0), 1)
  assert_eq(planned_source_image_pixel_channel(9, 1, 0, 0), 101)
  assert_eq(planned_source_image_pixel_channel(9, 1, 0, 3), 104)
  assert_eq(planned_source_image_pixel_channel(9, 0, 1, 0), 9)
  assert_eq(planned_source_image_pixel_channel(9, 1, 1, 0), 13)
}

///|
test "planned source image patch returns false for unknown image id" {
  clear_planned_source_image_registry()
  assert_true(!begin_planned_source_image_patch(999))
  assert_true(!end_planned_source_image_patch(999))
}
