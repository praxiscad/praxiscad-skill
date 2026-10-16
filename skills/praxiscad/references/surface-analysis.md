# Surface analysis (class A checks)

`praxiscad:analyze_surfaces` measures how well the faces of a part or imported STEP model join, and
`praxiscad:set_display_mode` `zebra` / `curvature` plus `praxiscad:render_views` show it. The live
reference is `praxiscad:modeling_reference {"topic": "surface_analysis"}`.

## Contents
1. [Continuity levels](#1-continuity-levels)
2. [Arguments](#2-arguments)
3. [Reading the result](#3-reading-the-result)
4. [Looking at it](#4-looking-at-it)
5. [Workflow](#5-workflow)
6. [Class A is more than a flag](#6-class-a-is-more-than-a-flag)

## 1. Continuity levels
- **G0**: the faces meet (largest gap along the edge, mm).
- **G1**: G0 and the normals agree (largest angle, degrees). A fillet is G1 with its faces.
- **G2**: G1 and the normal curvature agrees across the edge (relative difference).
`achieved` is the highest level an edge reaches; `passes` says whether it meets `spec.required`.

## 2. Arguments
```json
{"model_id": "m1", "spec": {"required": "G2", "g1_angle_deg": 0.1},
 "edge_ids": [12, 13], "body_id": "b0", "report_path": "/Users/me/surf.json"}
```
| Field | Meaning |
|---|---|
| `model_id` | Optional when exactly one part or imported model is open |
| `spec.required` | `none` (default: only gaps and near-miss tangent joins), `G0`, `G1`, `G2` |
| `spec` tolerances | `g0_gap_mm` 0.001, `g1_angle_deg` 0.1, `g2_curvature_rel` 0.05, `g2_curvature_abs` 0.0001 (1/mm), `sliver_min_width_mm` 0.05, `ripple_curvature_tol` 0.001, `near_miss_angle_deg` 2 |
| `face_ids` / `edge_ids` / `body_id` | Restrict the analysis (ids repeat across bodies) |
| `samples_per_edge` | 2-512, default 16 |
| `include_samples`, `include_control_net` | Large; prefer `report_path` |
| `report_path` | Absolute `.json` path for the full report |
| `max_listed` | Items listed in the reply (default 20) |

Typical tolerances: machining or printing 0.001-0.01 mm and 0.1-0.5 degrees; visible styled
surfaces 0.1 degrees or less and 5-10 % curvature. Use the user's numbers when given.

## 3. Reading the result
- `summary.byContinuity` counts edges by level; `failingEdges` is worst first with `worstPoint`.
- `notableFaces` lists slivers, ripples (curvature that oscillates inside a face) and singular points.
- `issueGroups` (the app's `summary.groups`) groups issues by kind, severity and rule with `count`, `minValue`..`maxValue`, `unit` and a ready-made `message`. Rules: gap, nearMiss, belowRequired, internalContinuity, internalCrease, sliver, ripple, singularity, nonManifold, evaluation. Report the groups; `issues` then holds one example per group and `issuesNotListed` counts the rest (all of them are in the `report_path` file).
- Internal knot lines: a spline face can be creased or only G1 inside. `internalContinuity` (`G2` smooth, `G1`, `G0` creased), `internalAngleDeg`, `internalCurvatureJump` and `knotJumps` (points) describe it; the matching issue has a `faceId` but no `edgeId` (select the face, not an edge). Such a face is listed first in `notableFaces`.
- `maxCurveOffsetMm` on an edge: the edge curve itself lies that far off its face (a tolerant edge in the source geometry, common in imported STEP). Above `g0_gap_mm` this is a data-quality problem of the source model, not a design choice: say so instead of proposing a blend.
- `*NotListed` fields say how many entries were left out.
- Only exact B-rep faces are analysed; mesh-only bodies give an info issue.

## 4. Looking at it
1. `praxiscad:set_display_mode {"mode": "zebra"}` then `praxiscad:render_views` (iso and a side view); repeat with `"direction": "horizontal"`.
2. `praxiscad:set_display_mode {"mode": "curvature", "kind": "mean"}` then `praxiscad:render_views`.
   `kind`: `mean` for flow, `maxAbs` for tight radii, `gaussian` for dome versus saddle. A colour jump at an edge is a curvature break; speckle is ripple.
3. `praxiscad:set_display_mode {"mode": "shaded-edges"}` when done.

The user can also open **Inspect → Surface Analysis** in PraxisCAD: the same continuity report as a panel (G0/G1/G2 across edges, creases inside faces, edge-curve offsets), plus curvature combs on edges. Combs are a window feature; use `analyze_surfaces` and the display modes for your own checks.

## 5. Workflow
Analyze with the level the design needs, look at zebra and curvature, explain the failing edges
with their numbers, propose a fix in the responsible feature (fillet or blend parameters, loft
or sweep guides, spline sketches), ask before changing the design, apply, analyze again. If the
available features cannot reach the level, say so.

## 6. Class A is more than a flag
G2 on every edge does not make a surface class A: highlight flow across the whole surface, even
curvature distribution and no waviness inside a face matter too. Show the renders and let the
user judge.
