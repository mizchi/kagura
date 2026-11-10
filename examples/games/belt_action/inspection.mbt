///|
fn tuning_subjects(g : @sim.Game) -> Array[@inspection.Subject] {
  let subjects : Array[@inspection.Subject] = [
    {
      id: "game",
      name: "Shift",
      fields: [
        @inspection.Field::Text("mode", "Mode", g.mode, false),
        @inspection.number("stage", g.stage.to_double() + 1, label="Sector"),
        @inspection.number(
          "frameCount",
          g.frames.to_double(),
          label="Elapsed",
          unit="frames",
        ),
        @inspection.number(
          "remaining",
          g.remaining().to_double(),
          label="Enemies",
        ),
        @inspection.number(
          "hitStop",
          g.hit_stop.to_double(),
          label="Hit stop",
          unit="frames",
        ),
      ],
    },
    {
      id: "player",
      name: "Player",
      fields: [
        @inspection.number(
          "hp",
          g.player.hp.to_double(),
          label="HP (1..6)",
          editable=true,
        ),
        @inspection.number(
          "x",
          g.player.x,
          label="Position X",
          unit="px",
          editable=true,
        ),
        @inspection.number(
          "z",
          g.player.z,
          label="Depth (300..445)",
          unit="px",
          editable=true,
        ),
        @inspection.Field::Text("action", "Action", g.player.action, false),
        @inspection.number(
          "age",
          g.player.age.to_double(),
          label="Action age",
          unit="frames",
        ),
      ],
    },
    {
      id: "combat",
      name: "Combat tuning",
      fields: [
        @inspection.number(
          "damage",
          g.damage.to_double(),
          label="Damage (1..4)",
          editable=true,
        ),
        @inspection.number(
          "windup",
          g.windup.to_double(),
          label="Enemy windup (36..120)",
          unit="frames",
          editable=true,
        ),
      ],
    },
  ]
  for e in g.enemies {
    subjects.push({
      id: "enemy:\{e.id}",
      name: if e.kind == 3 {
        "Foreman"
      } else {
        "Enemy \{e.id}"
      },
      fields: [
        @inspection.number("hp", e.hp.to_double(), label="HP"),
        @inspection.number("x", e.x, label="Position X"),
        @inspection.number("z", e.z, label="Depth"),
        @inspection.Field::Text("action", "Action", e.action, false),
        @inspection.Field::Boolean("braced", "Braced", e.braced(), false),
        @inspection.Field::Boolean("open", "Counter opening", e.open(), false),
        @inspection.Field::Boolean(
          "attackHit",
          "Attack connected",
          e.attack_hit,
          false,
        ),
        @inspection.number(
          "timer",
          e.timer.to_double(),
          label="Remaining",
          unit="frames",
        ),
      ],
    })
  }
  subjects
}
