# Changelog

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
