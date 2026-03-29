---
name: godot-runtime-testing
description: Runtime game testing via MCP tools. Run the game, take screenshots, click UI elements, read on-screen text, inspect the scene tree, and simulate input — all without leaving Claude. Use when testing UI flows, verifying visual output, or validating game behavior.
user-invokable: true
---

For full implementation details, see [reference.md](reference.md).

## Key Patterns

- **Run/Stop**: `run_game` launches main or custom scene, `stop_game` stops it
- **Screenshot**: `game_screenshot` captures viewport PNG — use Read tool to view the image
- **Read Text**: `game_read_text` returns all visible Label/Button/RichTextLabel text with positions
- **Click**: `game_click_node` clicks by node path/name, `game_click` clicks by coordinates
- **Input**: `game_press_action` simulates input actions (ui_accept, move_left, etc.)
- **Inspect**: `game_get_tree` dumps live scene hierarchy, `game_get_node` gets node details
- **Flow**: run_game → wait a moment → game_screenshot/game_read_text → game_click_node → repeat
