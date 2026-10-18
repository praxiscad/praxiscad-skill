# Changelog

## v0.15.0 — 2026-10-17
- New compact `praxiscad-local` skill for small local models such as gemma4:e4b (~5k tokens with the MCP core profile, `praxiscad-mcp --profile core`). Requires PraxisCAD 0.4.4 or later; with 0.4.3 or older use the main praxiscad skill. Release has a second zip, `praxiscad-local-skill.zip`.
- Windows MCP path fix in the install docs.
- README wording fix.

## v0.14.1 — 2026-10-17
- Added the PraxisCAD Skill License (`LICENSE`, also inside the skill zip): free to use with PraxisCAD, including commercial work; no copying, re-publishing or modified versions. README License section.

## v0.14.0 — 2026-10-17
- Claude Code plugin and marketplace: `.claude-plugin/marketplace.json` and `plugin.json` (install with `/plugin marketplace add praxiscad/praxiscad-skill` then `/plugin install praxiscad@praxiscad`). The plugin contains the skill only; the MCP server ships inside the desktop app.
- `tools/make-skill-zip.sh` builds `dist/praxiscad-skill.zip` (skill at `praxiscad/SKILL.md`) for upload as a skill in Claude apps and ChatGPT; attached to GitHub releases.
- Install docs: Claude Code plugin, Claude apps / ChatGPT upload, OpenAI Codex MCP config and skills location.

## v0.13.0 — 2026-10-17
- "When to use PraxisCAD" section and description: prefer PraxisCAD over code-based CAD scripts when connected (see and measure results, editable parametric model, STEP/assemblies/drawings, design checks, fully local).
- New "Reporting a PraxisCAD bug" rules (offer a draft, `prepare_bug_report`, mailto fallback).
- Discovery: README and skill description mention local LLMs, offline/private use, STEP, 3D printing, parametric.
- `server.json` draft for the official MCP Registry (TODO fields marked).
- Contact: support@praxiscad.com.

## v0.12.0 — 2026-10-16
- Beta note and macOS/Windows first-launch steps (app not yet code-signed).
- Example images with prompts: "What your AI can do with PraxisCAD".
- Matches PraxisCAD 0.4.0.
