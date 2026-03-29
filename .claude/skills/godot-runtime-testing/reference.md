# Godot Runtime Testing — MCP Tools Reference

## Architecture

Three-layer system for testing the running game:

```
Claude Agent
    ↓ (MCP stdio)
Node.js MCP Server
    ↓ (WebSocket :9080)              ↓ (TCP :9081)
Godot Editor Plugin          →     Running Game
(run_scene / stop_scene)           (MCPTestServer autoload)
```

- **Editor commands** (run/stop/status) go through the existing editor WebSocket on port 9080
- **Game commands** (screenshot, click, read text) connect directly to the game's TCP server on port 9081
- The `MCPTestServer` autoload is automatically registered when the MCP addon is enabled
- It only activates in debug builds (`OS.is_debug_build()`)

## Available MCP Tools

### Game Lifecycle

| Tool | Description |
|------|-------------|
| `run_game` | Launch main scene or a specific scene. Optional `scene_path` param. |
| `stop_game` | Stop the running game. |
| `is_game_running` | Check if a game is currently running. |

### Visual Inspection

| Tool | Description |
|------|-------------|
| `game_screenshot` | Capture viewport as PNG. Returns file path. Use the Read tool to view it. |
| `game_read_text` | Read ALL visible text on screen (Labels, Buttons, RichTextLabels, LineEdits) with positions and node paths. |
| `game_get_tree` | Dump the full live scene tree with types, visibility, positions, and text content. |
| `game_get_node` | Get detailed info about a specific node (properties, position, size, text, script). Pass `path` param. |

### Interaction

| Tool | Description |
|------|-------------|
| `game_click` | Click at screen coordinates `{x, y}`. |
| `game_click_node` | Click the center of a node by path (`/root/Main/UI/Button`) or by name (`StartButton`). |
| `game_press_action` | Simulate an input action. Params: `action` (string), `pressed` (bool), `duration` (seconds for auto-release). |

## Testing Workflow

### Basic UI verification flow:

```
1. run_game                          → Launch the game
2. (wait 1-2 seconds for load)
3. game_screenshot                   → Capture what's on screen
4. Read tool on screenshot path      → View the image
5. game_read_text                    → Get all visible text
6. game_click_node "StartButton"     → Click a button
7. game_screenshot                   → Verify the result
8. stop_game                         → Done
```

### Node finding:

- **By absolute path**: `"/root/Main/UI/HUD/ScoreLabel"` — exact scene tree path
- **By name**: `"ScoreLabel"` — searches the entire tree for first match
- Both `game_click_node` and `game_get_node` support this

### Reading the screen:

`game_read_text` returns structured data for each text element:
- `type`: Label, RichTextLabel, Button, LineEdit
- `text`: The displayed text content
- `position`: Screen coordinates `{x, y}`
- `size`: Element dimensions `{width, height}`
- `path`: Full node path
- `disabled`: (buttons only) whether the button is disabled

### Input simulation:

```
game_press_action {action: "ui_accept"}              → Press Enter/Space
game_press_action {action: "ui_accept", pressed: false} → Release
game_press_action {action: "move_left", duration: 0.5}  → Hold for 0.5s then release
```

Actions must exist in the project's Input Map.

### Scene tree inspection:

`game_get_tree` returns a recursive JSON hierarchy:
```json
{
  "name": "root",
  "type": "Window",
  "children": [
    {
      "name": "Main",
      "type": "Node2D",
      "visible": true,
      "position": {"x": 0, "y": 0},
      "children": [...]
    }
  ]
}
```

Limited to 15 levels deep to prevent excessive output.

## Key Files

| File | Purpose |
|------|---------|
| `addons/godot_mcp/runtime/test_server.gd` | Game-side TCP server autoload (port 9081) |
| `addons/godot_mcp/commands/runtime_commands.gd` | Editor-side run/stop commands |
| `godot-mcp/server/src/tools/runtime_tools.ts` | Node.js MCP tool definitions |
| `godot-mcp/server/src/utils/game_connection.ts` | Node.js TCP client for game connection |

## Troubleshooting

- **"Failed to connect to game"**: The game must be running with the MCPTestServer autoload. Check that the addon registered it in project.godot under `[autoload]`.
- **Screenshot is black**: The first frame may not be rendered yet. Wait a second after `run_game` before taking a screenshot.
- **"Unknown input action"**: The action name must match exactly what's in Project → Project Settings → Input Map.
- **Node not found**: Use `game_get_tree` to see the actual runtime tree structure, which may differ from the editor scene tree.
- **Port 9081 in use**: Only one game instance can use the test server at a time.
