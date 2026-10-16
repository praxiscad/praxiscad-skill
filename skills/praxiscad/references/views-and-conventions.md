# Views and conventions

## Coordinate system
- Right-handed, **Z up**, units millimetres.
- Bounding boxes are `{min:[x,y,z], max:[x,y,z]}`; `size` = max − min.

## Standard views (`praxiscad:set_view`, `praxiscad:render_views`)
| View | Camera looks along | Screen right | Screen up |
|---|---|---|---|
| `front` | +Y (camera on −Y) | +X | +Z |
| `back` | −Y | −X | +Z |
| `right` | −X (camera on +X) | +Y | +Z |
| `left` | +X | −Y | +Z |
| `top` | −Z (camera above) | +X | +Y |
| `bottom` | +Z | +X | −Y |
| `iso` | from (+X, −Y, +Z) toward the model | | +Z |

Some CAD tools are Y-up (their "front plane" is XY). In PraxisCAD the floor plane is XY and
height is Z. Translate when users describe directions in Y-up terms.

## Custom directions, projection and sections
- **Custom direction:** `{"from": [x, y, z], "name"?: "..."}` is a direction **from the model toward the camera** in world coordinates (Z up). `[0, 0, -1]` looks at the underside, `[1, -1, -1]` is an isometric from below, `[-1, -1, 1]` an isometric from the front left, and a face normal (from `praxiscad:measure`) looks straight at that face. The direction must not be zero.
- `praxiscad:render_views` mixes standard and custom views (at most 8); each image is labelled with its `name` (default `"custom"`):

```json
{"views": ["iso", {"from": [0, 0, -1], "name": "under"}, {"from": [1, -1, -1], "name": "iso_below"}], "projection": "persp"}
```
- **Projection:** `"ortho"` (true proportions, no distortion; the usual default) or `"persp"` (natural look). In `praxiscad:render_views` it applies to those images only; in `praxiscad:set_view` it changes the user's viewport until changed.
- **The user's camera** (`praxiscad:set_view`): give `view` **or** `from` (not both), plus optional `fit` (default true), `projection`, `section` and `model_id` (zoom to that model's bounding box instead of everything; `model_id` alone just fits that model). At least one of `view`, `from`, `projection`, `section`, `model_id` is required:

```json
{"from": [0, -1, 0.3], "projection": "persp", "section": {"axis": "x", "offset": 25}}
```
- **Section view:** `{"axis": "x" | "y" | "z", "offset"?: mm, "flip"?: true}`. The plane is perpendicular to the axis at `offset` (default: the middle of the model); the material on the positive side is removed, so you look into the cut from +axis (`flip: true` removes the other side instead). Turned on with `praxiscad:set_view` it stays on for the user **and** appears in every `praxiscad:render_views` until `{"axis": "off"}`; passed to `praxiscad:render_views` it applies to those images only.
- `praxiscad:set_view` moves the user's camera; `praxiscad:render_views` never does. Use `set_view` to show the user something and `render_views` to look yourself.

## Sketch planes (modeling)
| PraxisCAD plane | Faces the view | u, v | Normal | Offset `o` puts it at |
|---|---|---|---|---|
| `XY` | `top` | +X, +Y | +Z | Z = o |
| `XZ` | `front` | +X, +Z | −Y | Y = −o |
| `YZ` | `right` | +Y, +Z | +X | X = o |

A "top plane" is PraxisCAD `XY`, a "front plane" is PraxisCAD `XZ` and a "right plane" is PraxisCAD `YZ`
(with Z up).

## Ids
- Models: `praxiscad:new_part`, `praxiscad:new_assembly`, `praxiscad:new_drawing`, `praxiscad:convert_to_part`, `praxiscad:open_step_file`, `praxiscad:list_models` (never guess).
- Model kinds: `part` (`.pcad`), `imported` (STEP), `assembly` (`.pcasm`), `drawing` (`.pcdrw`).
- Features and parameters: the ids/names you chose, listed by `praxiscad:get_part`.
- Bodies: `b0`, `b1`, ... in modeling results and `praxiscad:get_part`; in assemblies `<componentId>/<bodyId>`; inside a sub-assembly the body is `<child>.<body>` (`s1/plate.b0`).
- Face and edge ids (from `praxiscad:get_selection`, `praxiscad:recognize_features`, `praxiscad:check_design`) belong to the current geometry and change after edits: use them right away (for example in `praxiscad:measure`), and use selectors in saved features.
- Selected vertices (`kind: "vertex"`) come with their `point` [x, y, z]; their ids are only valid for the current revision. Measure them as `{"kind": "point", "point": [...]}` or use the point in a `near` selector.
- `praxiscad:set_selection` takes the same ids to highlight things for the user: `{"items": [{"model_id": "m1", "kind": "edge", "body_id": "b0", "id": 7}]}` (`kind` `body` needs no `id`; assembly bodies `"<componentId>/<bodyId>"`; at most 500 items). It replaces the user's selection; `{"items": []}` clears it.
- Drawing edge ids (`"b0:e12"`; assembly drawings `"bolt/b0:e12"`) come from `praxiscad:get_drawing`.

## Display modes (`praxiscad:set_display_mode`)
| Mode | Good for |
|---|---|
| `shaded-edges` | Default; reading shape and features |
| `shaded` | Smooth surfaces, colours and finishes set with `praxiscad:set_appearance` |
| `wireframe` | Seeing internal edges and hidden features |
| `hidden-lines` | Drawing-like line views |
| `zebra` | Reflection stripes to judge continuity and highlight flow (`stripes`, `width`, `direction`, `invert`); see [surface-analysis.md](surface-analysis.md) |
| `curvature` | Curvature colour map of the active model (`kind`: `gaussian`, `mean`, `max`, `min`, `maxAbs`; `min`/`max` range); the next `praxiscad:render_views` shows it. Set `shaded-edges` again when done |

## Screenshot tips (`praxiscad:render_views`)
- Default 800×600 is enough for shape checks; use 1200–2048 px only for small details.
- Ask for the views that answer the question (e.g. `top` for hole patterns, `front`/`right` for heights).
- A render shows **one model**: `model_id`, default the active one (the model the user is working on). The user's other open models stay out of the images, so never close them to get a clean picture; the views are fitted to the bodies shown.
- `isolate: {"bodies": ["b0", "b2"]}` shows only those bodies of the model, `hide: ["b1"]` leaves bodies out (a cover or lid, to look inside). Both apply to these images only: the user's visibility and selection are untouched (bodies the user hid stay hidden unless isolated). Body ids come from `praxiscad:get_model_info`; an unknown model or body id is `not_found`, nothing left to render is `bad_request`.
- `scene: true` renders every open model together (not with `model_id`, `isolate` or `hide`), for example to show how two open parts compare in size.
- `section: {"axis": "x" | "y" | "z", "offset"?, "flip"?}` looks inside the part (cut faces are capped); `{"axis": "off"}` renders without the user's section view.
- Hidden side or a specific face: a custom direction (`{"from": [0, 0, -1]}` for the underside, a face normal for that face) instead of guessing from the standard views.
- `include_references: true` shows reference images (for image-to-CAD tracing); they are hidden by default.
- `background: "white"` gives drawing-like images; `"transparent"` a PNG with alpha.
- `quality: "render"` gives a beauty render (materials and appearances, environment lighting, soft shadow, no edges) for product shots, with `environment` `studio` (default), `outdoor` or `warehouse`; keep the default `standard` quality for checking geometry. See [materials-appearance.md](materials-appearance.md#7-product-renders).
