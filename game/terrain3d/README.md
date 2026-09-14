# Procedural height fields

`mizchi/kagura_game/terrain3d` provides deterministic, seeded height fields without
gameplay, graphics-backend or editor dependencies. It also retains the existing
tile-grid-to-mesh adapter.

## Algorithms

| Pattern | Implementation | Expected character |
| --- | --- | --- |
| `Flat` | Zero height | Comparison baseline |
| `Perlin` | 2D gradient noise, quintic fade, four octaves | Coherent rolling hills |
| `DiamondSquare` | Seeded coarse anchors, alternating diamond/square refinement, diminishing displacement | Irregular ridges and valleys |
| `Voronoi` | Worley cellular distance field, `1.35 × (F2 − F1)` | Raised cells with sharp slope changes and low cell boundaries |
| `Hybrid` | 65% cellular + 35% fractal Perlin | Cellular outlines with gentler undulation |

Voronoi here means a **distance field derived from Voronoi sites**, sampled on the
same grid as the other algorithms. It does not construct polygonal Voronoi meshes.
Low-poly appearance comes from mesh density and separate triangle normals as well
as the height function. A polygonal Voronoi/Delaunay mesh is a separate possible
experiment; discontinuous per-cell plateaus would also need cliff collision.

Diamond Square expands to a power-of-two square and crops the result. `scale`
chooses the next power-of-two anchor spacing; its changes are therefore discrete.
`roughness` controls octave/displacement decay, and does not affect pure Voronoi
or Flat. All implementations use coordinate hashes, without mutable random state.

## Contract

`generate_height_field(cells_x, cells_z, config)` accepts dimensions 1–512 and
validates amplitude 0–32, scale 4–128 and roughness 0.1–0.85. Output heights are
bounded by `[0, amplitude]`; actual relief is usually smaller. Fields use unit
spacing and contain `(cells_x + 1) × (cells_z + 1)` row-major corner samples.

- `sample(x, z)` interpolates triangles `(00,01,11)` and `(00,11,10)`, split along
  the `00 → 11` diagonal. It clamps out-of-bounds coordinates to the field edge.
- `raycast(ox,oy,oz,dx,dy,dz,max_distance~)` visits crossed cells with a 2D DDA and
  intersects those exact triangles. Its limit is a ray parameter; normalize the
  direction when it should represent world distance. A miss returns `None`.
- `project_polygon(points, lift~)` clips a convex XZ polygon against the surface
  triangles before projecting it. Contact shadows stay on slopes throughout each
  triangle, avoiding the holes caused by moving only the original vertices.
- `crop` retains identical overlap samples. Generate a shared field before
  cutting streamed regions, particularly for Diamond Square.
- `set` edits a valid corner; `limit_slope(rise)` lowers surrounding terrain to
  bound each cardinal edge by `rise`, preserving low road/building pads. Triangle
  gradients are consequently bounded by `sqrt(2) * rise`.
- `statistics` reports actual min/max, maximum triangle gradient and triangle count.

HeightField owns a mutable sample array. Callers must use finite sample values,
valid indices for `set`, and keep rendering's triangulation consistent. This is a
2.5D surface, suitable for grounded actors and aim picking; caves, overhangs and
full 3D projectile physics require a different collision representation.

## Research references

- Ken Perlin: [Improved Noise reference (2002)](https://cs.nyu.edu/~perlin/noise/)
  and [GPU Gems chapter 5](https://developer.nvidia.com/gpugems/gpugems/part-i-natural-effects/chapter-5-implementing-improved-perlin-noise).
  The quintic interpolation smooths second derivatives at lattice boundaries.
- Fournier, Fussell and Carpenter: *Computer Rendering of Stochastic Models*
  (1982), [DOI](https://doi.org/10.1145/358523.358553).
  The terrain survey authors' [DEM repository](https://perso.liris.cnrs.fr/eguerin/demrepo/)
  describes Diamond Square refinement from a coarse initial grid and provides
  comparative generated terrains.
- Steven Worley: [A Cellular Texture Basis Function (1996)](https://cedric.cnam.fr/~cubaud/PROCEDURAL/worley.pdf).
  Nearest-feature distances produce continuous cellular textures with abrupt
  derivative changes. The specific F2−F1 terrain blend above is our design choice.

These are independent 2D implementations based on algorithm descriptions, not
copies of the reference source code. Run `moon -C game test terrain3d --target js`
or the repository's `just game-components-test`.

## Gameplay routes before noise detail

`TerrainPad` describes a level combat/settlement anchor (`x`, `z`, `height`,
`radius`). `TerrainRoute` describes a graded segment with endpoint heights and
half-width. Compose several segments for switchbacks or loops, then call
`field.grade_routes(pads, routes, blend=4.0)` to embed the network in a heightfield.
Call `limit_slope` afterwards when the surrounding landscape must also remain
walkable. Nearby low constraints may lower a high pad during that repair; inspect
final sampled elevations, not just requested anchor heights.

`cell_slope(x,z)` returns the maximum gradient of the two rendered triangles.
The component owns neither mission progression nor enemy placement. ASHEN REALMS
supplies those in its game module and validates routes after terrain repair.
