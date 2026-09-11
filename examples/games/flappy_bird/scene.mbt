///| Validate completely before touching live game state.
fn validate_layout(layout : @scene2d.Document) -> Unit raise {
  layout.validate()
  if layout.width != 320 || layout.height != 240 || layout.objects.length() != 2 { fail("Flappy Bird screen must be 320 x 240 with two objects") }
  let bird = layout.element("bird")
  let ground = layout.element("ground")
  if bird.kind != "bird" || ground.kind != "ground" || ground.x != 0.0 || ground.width != 320.0 || ground.y < 160.0 || ground.y > 239.0 || ground.y + ground.height != 240.0 { fail("Invalid Flappy Bird ground") }
  if bird.width > 64.0 || bird.height > 64.0 || bird.x < 0.0 || bird.y < 0.0 || bird.x + bird.width > 320.0 || bird.y + bird.height > ground.y { fail("Bird must fit above the ground") }
}

///|
fn Game::apply_scene(self : Game, layout : @scene2d.Document) -> Unit raise {
  validate_layout(layout)
  let copy : @scene2d.Document = @json.from_json(layout.to_json())
  self.layout = copy
  self.bird = copy.element("bird")
  self.ground = copy.element("ground")
  self.reset()
}
