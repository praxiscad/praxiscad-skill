---
name: praxiscad-local
description: PraxisCAD for small local models (8B class, 32k context); use with PRAXISCAD_MCP_PROFILE=core (praxiscad-mcp --profile core). Short rules and ready-to-copy steps for simple parts - plates with holes, cups and tubes, L-brackets, open boxes, resizing a part, mass. Use when a small local model is asked to model or edit a simple CAD part in PraxisCAD.
compatibility: Requires the PraxisCAD desktop app running and its MCP server connected with the core profile (args ["--profile","core"] or env PRAXISCAD_MCP_PROFILE=core).
metadata:
  version: "0.15.0"
---

# PraxisCAD for small local models

Requires PraxisCAD 0.4.4 or later. With 0.4.3 or older, use the main praxiscad skill.

15 tools: praxiscad_status, list_models, new_part, set_parameters, add_feature, apply_operations, get_part, mass_properties, set_material, render_views, export_model, save_part, undo, close_model, modeling_reference. Units mm, Z up.

## Rules
1. Do not just plan. Call a tool in your next step, with the tool-calling interface (never type a call as text). Stop only when the part is built and checked.
2. `new_part` first. It answers `Created part m1`: use exactly `"m1"` as `model_id` in every call (never the part name). For a part you did not create in this chat, call `list_models` first and use its `modelId`.
3. Build step by step: ONE `set_parameters {"model_id":"m1","values":{...all sizes...}}`, then ONE `add_feature {"model_id":"m1","feature":{...}}` per feature (sketch, extrude, holes, fillets). Every feature has an `id` and a `type`. Use the parameter name wherever a size appears (also plane offsets and hole points), as a number or a quoted expression like `"width/2-margin"`; never type a size number that has a parameter, so `set_parameters` can resize the part later.
4. Then `get_part`: every feature ok, `bodyCount` at least 1, bbox size and volume as expected. If bodyCount is 0 or a feature says ERROR, say so and fix it; never claim success.
5. A failed call changes nothing. Read the error, CHANGE the call, retry; never send the same call twice. `operation` (`"cut"`/`"add"`) goes INSIDE the feature. The first solid needs no `operation`.
6. Never `export_model` / `save_part` a part with no body. Export only when asked; the path is absolute.
7. Finish: `render_views {"model_id":"m1"}`, then give the user the real numbers (bbox, volume, mass).

## Recipe 1: plate with holes (sketch, extrude, holes)
values: `{"width":80,"depth":50,"thickness":8,"hole_d":6,"margin":10}`
1. `{"id":"base_sk","type":"sketch","plane":{"base":"XY"},"profiles":[{"kind":"rect","center":[0,0],"width":"width","height":"depth"}]}`
2. `{"id":"base","type":"extrude","sketch":"base_sk","distance":"thickness"}`
3. `{"id":"holes","type":"hole","plane":{"base":"XY","offset":"thickness"},"symmetric":{"x":"width/2-margin","y":"depth/2-margin"},"diameter":"hole_d","through":true}`

The plate is centred on X/Y and sits on Z=0..thickness. Corner holes are `margin` from each edge. Volume = width*depth*thickness - holes*pi*(hole_d/2)^2*thickness. `symmetric` gives four holes at (+-x, +-y) from the centre; for other positions use `"points":[[u,v],...]` instead (u,v from the centre, expressions in quotes), e.g. a centre hole `"points":[[0,0]]`. Field names: `points` (not `holes`). Rounded plate corners: add `"cornerRadius":R` to the rect.

## Recipe 2: cup, can, tube (cylinder minus cylinder)
values: `{"outer_d":50,"height":70,"wall":2,"rim_r":1}`
1. `{"id":"outer","type":"cylinder","radius":"outer_d/2","height":"height","base":[0,0,0],"axis":"Z"}`
2. `{"id":"cavity","type":"cylinder","radius":"outer_d/2-wall","height":"height","base":[0,0,"wall"],"axis":"Z","operation":"cut"}`
3. `{"id":"rim","type":"fillet","edges":{"plane":"max_z"},"radius":"rim_r"}`

The cavity starts `wall` above the bottom (closed bottom) and runs through the top. For a tube start it at base `[0,0,0]`. The rim fillet radius should not exceed half the wall. Alternative: the cylinder, then `{"id":"hollow","type":"shell","thickness":"wall","openFaces":{"normal":"+Z"}}`.

## Recipe 3: L-bracket (path profile)
values: `{"length":60,"height":40,"t":5,"width":20}`
1. `{"id":"l_sk","type":"sketch","plane":{"base":"XY"},"profiles":[{"kind":"path","start":[0,0],"segments":[{"line":["length",0]},{"line":["length","t"]},{"line":["t","t"]},{"line":["t","height"]},{"line":[0,"height"]}]}]}`
2. `{"id":"l","type":"extrude","sketch":"l_sk","distance":"width"}`

The path closes itself.

## Recipe 4: open box (enclosure)
values: `{"width":80,"depth":50,"height":30,"corner_r":6,"wall":2}`
1. `{"id":"outer","type":"box","size":["width","depth","height"],"center":[0,0,"height/2"]}`
2. `{"id":"corners","type":"fillet","edges":{"parallel":"Z"},"radius":"corner_r"}`
3. `{"id":"hollow","type":"shell","thickness":"wall","openFaces":{"normal":"+Z"}}`

Fillet first, with `corner_r` bigger than `wall`.

## Recipe 5: change a size, weight
1. `get_part` lists `parameters` such as `thickness = 10`. 2. `set_parameters {"model_id":"m1","values":{"thickness":15}}`. 3. `get_part` for the new volume. 4. Weight: `set_material {"model_id":"m1","material":"aluminium_6061"}` then `mass_properties {"model_id":"m1"}` (mass_g). Other materials: steel, stainless_304, brass, abs, pla.

## More building blocks (the `feature`)
- Pocket in the top face: sketch with `"plane":{"base":"XY","offset":"thickness"}`, then `{"type":"extrude","sketch":"pk","distance":3,"direction":"reverse","operation":"cut"}`.
- Boss on top: sketch plane `{"face":{"plane":"max_z"}}`, extrude with `"operation":"add"`.
- Chamfer: `{"type":"chamfer","edges":{"plane":"max_z"},"distance":1}`. Edge selectors: `{"parallel":"Z"}`, `{"plane":"max_z"}`, `{"all":true}`.
- Row of holes: `{"type":"linear_pattern","features":["holes"],"direction":[1,0,0],"count":3,"spacing":20}`.
- Sketch planes: XY extrudes up (+Z), XZ extrudes toward -Y, YZ toward +X.
- Several changes in one call: `apply_operations {"model_id":"m1","operations":[{"op":"set_parameter","name":"w","value":80},{"op":"add_feature","feature":{...}}]}`.

## Errors
| Error | Fix |
|---|---|
| missing field / bad shape | follow the "Correct input" line of the error |
| no open model | use the id from `new_part` (`m1`), not a name; `list_models` shows open ids |
| feature ERROR (geometry) | fillet/chamfer too big, selector matches nothing, a cut that does not touch the body, hole point outside the plate: change that feature |
| bodyCount 0 | no extrude/box/cylinder succeeded: build it before measuring or exporting |
