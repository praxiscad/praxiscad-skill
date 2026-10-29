# Install PraxisCAD and connect your AI client

## 1. Install the app
Download PraxisCAD for macOS (.dmg) or Windows (installer) from the PraxisCAD website and open it
once. Your AI can only work with PraxisCAD while the app is running.

Latest version, direct links:
- macOS (Apple silicon and Intel): https://praxiscad.com/get/macos
- Windows installer: https://praxiscad.com/get/windows
- Windows MSI: https://praxiscad.com/get/windows-msi

If you use this skill and PraxisCAD is not installed, your AI will offer these links and ask before
downloading anything.

> **Beta.** PraxisCAD is in beta: expect rough edges, and please report anything odd.

### First launch (the app is not code-signed yet)
PraxisCAD is not yet signed with an Apple Developer ID, so every Mac shows a one-time warning.
The warning is about the missing signature, not about anything found in the app; signed builds are coming soon.

**macOS**
1. Open the downloaded `.dmg` and drag **PraxisCAD** to **Applications**.
2. Open PraxisCAD. macOS says it could not verify the app. Click **Done** (not Move to Bin).
3. Open **System Settings → Privacy & Security**, scroll down, click **Open Anyway** next to PraxisCAD, and confirm.
   You only need to do this once.

**Windows:** if SmartScreen appears, click **More info → Run anyway**.

## 2. Connect your AI client
PraxisCAD ships a small MCP server, `praxiscad-mcp`, inside the app. In PraxisCAD open
**AI → Connect AI assistant**: it lists the AI clients installed on your computer and connects
them with one click (it shows what it will write and backs up the client's config first).

### By hand
Add a stdio MCP server named `praxiscad` whose command is the absolute path to `praxiscad-mcp`:
- macOS: `/Applications/PraxisCAD.app/Contents/MacOS/praxiscad-mcp`
- Windows: `C:\Users\YOU\AppData\Local\PraxisCAD\praxiscad-mcp.exe` (`%LOCALAPPDATA%\PraxisCAD`, next to `PraxisCAD.exe`)

Most clients use this JSON shape in their MCP config:

```json
{ "mcpServers": { "praxiscad": { "command": "/Applications/PraxisCAD.app/Contents/MacOS/praxiscad-mcp" } } }
```

| Client | Config |
|---|---|
| Claude Desktop | `claude_desktop_config.json` (Settings → Developer → Edit Config); restart Claude |
| Claude Code | `claude mcp add --scope user praxiscad -- "/Applications/PraxisCAD.app/Contents/MacOS/praxiscad-mcp"` |
| Cursor | `~/.cursor/mcp.json` |
| Windsurf | `~/.codeium/windsurf/mcp_config.json` |
| Gemini CLI | `~/.gemini/settings.json` |
| LM Studio (local models) | `~/.lmstudio/mcp.json` |
| VS Code (Copilot agent mode) | user `mcp.json`: `{"servers": {"praxiscad": {"type": "stdio", "command": "<path>"}}}` |
| OpenAI Codex | `~/.codex/config.toml`, see [Codex](#openai-codex) below |

### OpenAI Codex
Add to `~/.codex/config.toml` (or run `codex mcp add praxiscad -- <path>`):

```toml
[mcp_servers.praxiscad]
# macOS
command = "/Applications/PraxisCAD.app/Contents/MacOS/praxiscad-mcp"
# Windows: use the full path to praxiscad-mcp.exe, for example
# command = 'C:\Users\YOU\AppData\Local\PraxisCAD\praxiscad-mcp.exe'
```

Codex reads skills from `$HOME/.agents/skills` (all your projects) and `.agents/skills` in a
repository; copy `skills/praxiscad` to `~/.agents/skills/praxiscad`. Alternatively put
`instructions/AGENTS.md` in your project's `AGENTS.md`.

Config locations can change between client versions — check your client's MCP documentation.
Clients that only support **remote** MCP servers over HTTPS are not supported yet; a remote connector is planned.
The **ChatGPT desktop app** works: in PraxisCAD click Connect next to "Codex CLI" (the app shares that setup), and both
ChatGPT and Codex in the app can use PraxisCAD.

## 3. Check it works
Ask your AI: *"Is PraxisCAD running?"* — it calls `praxiscad_status` and reports the app version.
Then try: *"Make a 50 mm cube with a 20 mm hole through it in PraxisCAD."* The part appears in the
PraxisCAD window as the AI builds it, and PraxisCAD shows which assistant made the change. Follow up
with *"Check it for 3D printing"* (design check) or *"Make a drawing of it and export a PDF"*.

## 4. Optional: add the instructions

**Small local models:** use the compact `praxiscad-local` skill with `praxiscad-mcp --profile core`. Requires PraxisCAD 0.4.4 or later. With 0.4.3 or older, use the main praxiscad skill.
Pick the way that matches your client:
- **Claude Code (plugin):** in a Claude Code session run
  `/plugin marketplace add praxiscad/praxiscad-skill`, then `/plugin install praxiscad@praxiscad`.
  The plugin contains only the skill; the PraxisCAD MCP server comes with the desktop app (step 2).
- **Claude apps and ChatGPT (workplace plans):** download `praxiscad-skill.zip` from the
  [latest GitHub release](https://github.com/praxiscad/praxiscad-skill/releases/latest) and upload it as a
  skill (Claude: Customize > Skills; ChatGPT: skills settings). The ChatGPT desktop app connects to PraxisCAD
  through the Codex setup (PraxisCAD > AI > Connect AI assistant > Codex CLI).
- **OpenAI Codex:** copy `skills/praxiscad` to `~/.agents/skills/praxiscad` (see [Codex](#openai-codex)).
- Other clients with Agent Skills support: copy `skills/praxiscad` into the client's skills folder
  (for example `~/.claude/skills/praxiscad`).
- Everything else: use `instructions/AGENTS.md` as project rules or a system prompt (see the
  main [README](../README.md#quick-start) for where each client reads it).

The skill adds design rules, workflows for standard holes and threads, sketch tools and DXF
import/export, materials and renders, assemblies and motion, drawings, STEP editing, design
checks and worked examples on top of the instructions the MCP server already sends.

Update to the latest version (v0.12) whenever you update PraxisCAD; older copies don't describe
the newer tools.

## Privacy
The connection is local to your computer (no network port). Each app launch creates a new
access key readable only by your user account. Your model files stay on your computer; what the
AI sees (numbers and renders) goes to whichever AI service your client uses.
