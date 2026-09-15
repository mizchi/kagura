# character3d

Reusable movement policy for dynamic characters. `motor_acceleration` is a pure
function: input, current velocity, support contact and configuration determine
the acceleration to apply. The physics world owns position and velocity.

At each fixed physics tick:

1. Find support with `sphere_ground_contact(body, bodies, config)`.
2. If jumping from support, apply an upward impulse and use air control that tick.
3. Call `motor_acceleration(config, velocity, direction, ground, gravity, dt)`.
4. Apply `body.mass * acceleration` as a force, then step physics.
5. Read the body position for the character and camera. Ignore its own collider
   in camera obstruction and weapon ray queries.

Horizontal input magnitude is clamped to one, preserving analog input strength.
On the ground, target speed and feedback act along the contact plane, relative
to support velocity. Tangential gravity is compensated within the same force
budget. In the air, only horizontal velocity is controlled; gravity and launches
remain intact. Force limits prevent input from erasing an impact in one frame.

| `MotorConfig` field | Default | Meaning |
|---|---:|---|
| `speed` | 4.8 | Target movement speed, units/s |
| `response_time` | 0.12 | Velocity response time, seconds |
| `ground_acceleration` | 30 | Acceleration limit while steering on ground |
| `ground_braking` | 6 | Braking limit without input on ground |
| `air_acceleration` | 6 | Acceleration limit while steering in air |
| `air_braking` | 0.5 | Braking limit without input in air |
| `jump_speed` | 5.2 | Takeoff speed used by the integration |
| `max_slope_cos` | 0.65 | Minimum upward component of a walkable normal |
| `probe_distance` | 0.06 | Extra radius for the support query |

Speeds, times and limits should be nonnegative, with a positive fixed timestep.
An explicitly supplied `GroundContact.normal` must be a unit vector. The probe
returns unit normals from the physics narrowphase, ignores the character itself,
rejects walls/ceilings, and excludes a support when the character is separating
upward faster than 0.5 units/s. It does not snap positions or require cached
contact state.

Arena 3D uses a sphere with locked rotation (`inv_inertia: 0`), zero restitution
and low friction. Its integration and jump/reset logic live in
`examples/games/arena3d/player_physics.mbt`. Different collision shapes can supply
their own ground query while reusing the same motor.

Run `just arena-physics-test` and `just target=native arena-physics-test` from the
repository root. Tests cover impacts, counter steering, timestep convergence,
slope support, air control, jumping and integration with the shared physics yard.
