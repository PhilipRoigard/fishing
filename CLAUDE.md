**KEEP IT SIMPLE**: Focus on solving the immediate task without over-engineering:
- Implement only what's requested - don't add unnecessary features or complexity
- Don't create build scripts, test runners, or automation unless specifically asked
- Don't attempt to run Godot headless or create testing frameworks
- Stick to the core functionality and avoid scope creep
- The user will test the implementation themselves in the Godot editor

## Engine Requirements

**CRITICAL**: This project requires **Godot 4.6+**. Always use modern Godot 4.6+ syntax and features:
- Use `@export` instead of `export`
- Use `await` instead of `yield`
- **NEVER use `:=` for type inference** — it is no longer valid in Godot 4.6+. Always use explicit type annotations: `var x: float = 1.0`, not `var x := 1.0`
- Leverage new Godot 4.6+ features like improved type hints, new nodes, and enhanced scripting capabilities
- Take advantage of performance improvements in the latest engine version

## Code Structure and Organization

1. **Use proper GDScript style**
   - Follow the [official GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
   - Use snake_case for functions and variables
   - Use PascalCase for classes and nodes
   - Use UPPER_CASE for constants and enums
   - **GODOT 4.4+**: Always use `@export` syntax, never legacy `export`
   - **GODOT 4.4+**: Use proper type hints with modern syntax: `var health: int = 100`
   - **PREFER TYPED ARRAYS OVER DICTIONARIES**: When tracking objects with associated data, use typed arrays with a small class instead of Dictionary
     - ❌ `var enemy_hit_times: Dictionary = {}` with `enemy_hit_times[enemy] = time`
     - ✓ Create a class: `class EnemyHitRecord: var enemy: Enemy; var hit_time: float`
     - ✓ Use typed array: `var hit_records: Array[EnemyHitRecord] = []`
     - This provides type safety, better autocomplete, and clearer intent
   - **TYPED ARRAY METHODS RETURN UNTYPED ARRAYS**: Methods like `filter()`, `map()`, `slice()` return untyped `Array`. Use `.assign()` to preserve typing:
     - ❌ `my_typed_array = my_typed_array.filter(func(x): return x.valid)` - Type error!
     - ✓ `my_typed_array.assign(my_typed_array.filter(func(x): return x.valid))` - Correct

2. **Autoloads**
   - **NEVER add `class_name` to autoload scripts** - the autoload singleton already provides a global name, adding `class_name` causes "Class hides an autoload singleton" errors
   - ❌ `class_name MyManager` in an autoload script
   - ✓ Just `extends Node` without class_name for autoloads
   - Register autoloads in `project.godot` under `[autoload]` section

3. **Node Structure**
   - Keep scene hierarchies as flat as possible
   - Name nodes appropriately based on their function
   - Use groups sparingly and intentionally
   - Favor composition over deep hierarchies

4. **Accessing Game Systems**
   - **NEVER use `get_tree().get_nodes_in_group()` to find managers/systems** - use the proper instance references instead
   - Access game systems through `Main.instance` (e.g., `Main.instance.spawn_manager`, `Main.instance.ability_controller`, `Main.instance.damage_system`)
   - Access autoload singletons directly by their global name (e.g., `DelveManager`, `CurrencyManager`, `EnemyPoolManager`, `SignalBus`)
   - Access EnemyManager via `EnemyManager.get_instance()`
   - ❌ `get_tree().get_nodes_in_group("spawn_manager")[0]`
   - ✓ `Main.instance.spawn_manager`

5. **Signal-based Communication**
   - Use signals for loose coupling between nodes
   - Prefer signals over direct node access when appropriate
   - Document signals with clear descriptions

6. **Constants and Configuration - Smart Configuration Strategy**
   - **GOAL**: Make game systems configurable for designers without over-engineering simple components
   - **USE CONFIG RESOURCES FOR**: Complex game systems that need designer/balancer tweaking
     - Enemy stats, abilities, spawn rates, difficulty scaling
     - Character progression, upgrade costs, economy values
     - Gameplay mechanics, timers, cooldowns that affect balance
     - Item stats, effects, rarities, unlock requirements
   - **USE @export VARIABLES FOR**: Simple components and UI elements
     - UI component sizing, spacing, colors, animations
     - Visual effects parameters, particles, shaders
     - Audio volumes, pitch ranges
     - Simple component behaviors
   - **EXAMPLES OF WHEN TO USE CONFIG RESOURCES**:
     - ✓ `EnemyConfig.gd` with health, damage, speed, abilities
     - ✓ `ItemSystemConfig.gd` with all items and their stats
     - ✓ `ProgressionConfig.gd` with level-up curves and costs
     - ✓ Complex systems where values relate to each other
   - **EXAMPLES OF WHEN @export IS FINE**:
     - ✓ `@export var hover_scale: float = 1.05` in a button component
     - ✓ `@export var fade_duration: float = 0.3` in a UI transition
     - ✓ `@export var particle_lifetime: float = 2.0` in an effect
     - ✓ Simple standalone values that don't affect game balance
   - **BANNED PATTERNS** (magic numbers in game systems):
     - ❌ `enemy.health = 100` - Use config resource
     - ❌ `const JUMP_SPEED = 400.0` - Use config resource for player stats
     - ❌ `spawn_delay = 5.0` - Use config resource for spawn system
   - **ACCEPTABLE PATTERNS** (reasonable defaults):
     - ✓ `@export var button_padding: int = 10` - Simple UI value
     - ✓ `const MAX_HISTORY = 50` - Technical constant, not game balance
     - ✓ `tween.tween_property(node, "modulate:a", 0.0, 0.3)` - Simple animation
   - **RULE OF THUMB**: If a designer/balancer would want to tweak it → Config Resource. If it's just a component default → @export is fine.
   - See configuration examples at the bottom of this file

## Performance Optimization

1. **Physics and Processing**
   - Use `_process` for visual updates, `_physics_process` for physics
   - Avoid expensive operations in process loops
   - **GODOT 4.4+**: Use `await get_tree().process_frame` instead of deprecated `yield`
   - Leverage Godot 4.4+ performance improvements in physics systems

2. **Shaders and Materials**
   - Create unique material instances when modifying shader parameters at runtime
   - Keep shaders simple and optimize for performance
   - Use shader parameters instead of recreating shaders

## Game Design Patterns

1. **State Management**
   - Use state machines for complex behaviors
   - Keep state transitions clear and well-defined
   - Document state dependencies

2. **Dependency Injection**
   - Pass dependencies through constructor methods when possible
   - Use dependency injection for better testability
   - Avoid global state when possible (except for true singletons)

3. **Component-Based Design**
   - **PRIORITY**: Create reusable components first - every piece of functionality should be designed as a modular, reusable component
   - Break functionality into focused, single-responsibility components
   - Design components to be easily instanced and configured across multiple scenes
   - Favor composition over inheritance for maximum flexibility
   - Use `@export` variables to make components configurable without code changes
   - Create component libraries that can be shared across different game systems
   - Examples: HealthComponent, DamageComponent, MovementComponent, UIComponent

## Tools and Asset Management

1. **Resource Management**
   - **PRIORITY**: Use custom Resource classes for configuration data instead of hardcoded values
   - **PREFER PRELOAD OVER LOAD**: Use `preload()` for resources known at compile time, `load()` only for dynamic loading
   - Use `preload()` for scenes, textures, audio, and configuration files that are always needed
   - Use `load()` only when the resource path is determined at runtime or for optional resources
   - Create dedicated config resources: `CharacterStats.gd extends Resource`, `GameSettings.gd extends Resource`
   - Store configuration in `.tres` files for easy external modification
   - Use Resource classes for data-oriented design
   - Organize resources in logical folder structures
   - Examples: `preload("res://config/enemy_stats.tres")`, `preload("res://scenes/bullet.tscn")`

2. **Scene Management**
   - **PRIORITY**: Create reusable scene components for all UI elements, game mechanics, and visual effects
   - **USE GODOT MCP**: Always use `mcp_godot-mcp_create_scene` and `mcp_godot-mcp_create_node` for scene creation
   - **AVOID PROGRAMMATIC UI**: Never create UI nodes in `_ready()` or other functions - use MCP tools instead
   - Use packed scenes for instancing reusable components
   - Design scenes to be self-contained and easily configurable
   - Consider scene inheritance for variations on a theme
   - Create scene libraries organized by functionality (UI/, Components/, Effects/, etc.)
   - Make scenes modular with clear interfaces through exported variables and signals

3. **Export Variables**
   - **GODOT 4.4+**: Use `@export` annotations with modern syntax
   - Set sensible defaults for exported variables
   - Use export groups and categories for organization: `@export_group("Movement")`, `@export_category("Combat")`
   - Leverage new export hints: `@export_range(0, 100)`, `@export_flags("Fire:1,Water:2,Earth:4")`
   - Make components highly configurable through exported properties

## Testing and Debugging

1. **Error Handling**
   - Use assertions to catch programming errors
   - Handle expected errors gracefully
   - Log meaningful error messages

## Documentation

1. **Code Documentation**
   - **NO COMMENTS**: Do not add comments to code. Code should be self-explanatory through good naming.
   - **DO NOT USE TRIPLE-QUOTED DOCSTRINGS**: Never use `"""docstring"""` syntax in GDScript
   - If code needs a comment to be understood, refactor it with better names instead
   - Use descriptive function names: `_load_game_map()`, `_spawn_enemy_at_portal()`, `_handle_player_death()`
   - Use meaningful variable names: `spawn_portals`, `player_config`, `game_started` instead of `portals`, `config`, `started`
   - Break complex logic into well-named helper functions rather than explaining with comments

## Project-Specific Guidelines

1. **UI Development**
   - **ALWAYS USE GODOT MCP**: Use MCP tools for all UI creation instead of programmatic node creation
   - **VISUAL FIRST**: UI should be designed visually in scenes, not hidden in code
   - Create reusable UI components as scenes with proper node hierarchies
   - **USE UNIQUE NODE REFERENCES**: Reference UI elements with `@onready var` using unique node syntax (`%NodeName`) instead of paths
     - Mark nodes as unique in the scene (right-click → "Access as Unique Name" or add `unique_name_in_owner = true` in .tscn)
     - ❌ `@onready var button: Button = $SafeZoneContainer/MainVBox/Header/BackButton`
     - ✓ `@onready var button: Button = %BackButton`
     - This allows designers to reorganize scene hierarchies without breaking scripts
   - Keep UI logic separate from UI structure - scenes define structure, scripts define behavior

2. **Shader Usage**
   - Create unique material instances for each object that needs individual shader parameter manipulation
   - Prefer simple shader effects that can be composed
   - Consider mobile performance implications if targeting that platform

2. **Enemy Behavior**
   - Implement clear visual feedback for player interactions
   - Use proper state machines for enemy AI
   - Ensure consistent difficulty scaling

## Available MCP Tools

When working with this Godot project, you have access to powerful MCP tools for scene and node creation:

### Scene Creation
- `mcp_godot-mcp_create_scene` - Create new scenes with specified root node types
- `mcp_godot-mcp_open_scene` - Open existing scenes for editing
- `mcp_godot-mcp_save_scene` - Save current scene changes

### Node Management  
- `mcp_godot-mcp_create_node` - Add nodes to the current scene with proper hierarchy
- `mcp_godot-mcp_delete_node` - Remove nodes from scenes
- `mcp_godot-mcp_list_nodes` - View scene node hierarchies
- `mcp_godot-mcp_update_node_property` - Modify node properties through MCP

### Script and Resource Management
- `mcp_godot-mcp_create_script` - Create and attach scripts to nodes
- `mcp_godot-mcp_edit_script` - Modify existing scripts
- `mcp_godot-mcp_create_resource` - Create resource files (.tres)

**USE THESE TOOLS** instead of creating UI elements programmatically in code!

## UI and Scene Creation

**CRITICAL - USE GODOT MCP FOR UI COMPONENTS**: Always use the Godot MCP tools to create UI elements and scenes:
- **NEVER create UI nodes programmatically in code** - this creates bloated, hard-to-maintain code
- Use `mcp_godot-mcp_create_scene` to create new scenes with proper root nodes
- Use `mcp_godot-mcp_create_node` to add UI elements to scenes through the MCP
- Design UI layouts in scenes using the MCP, not in `_ready()` functions
- Keep scripts focused on logic, not UI creation
- **Example of WRONG approach**: `var label = Label.new(); add_child(label); label.text = "Hello"`
- **Example of WRONG approach**: `@onready var label: Label = $Container/Panel/VBox/Label` (path-based reference)
- **Example of CORRECT approach**: Create scene with MCP, mark node as unique, reference with `@onready var label: Label = %Label`
- **UI should be visual and editable** in the Godot editor, not hidden in code


## Configuration Examples

### When to Use Config Resources (Game Systems)

**Bad - Magic numbers in game system:**
```gdscript
# DON'T DO THIS for game systems
func take_damage():
	health -= 1  # Magic number affecting gameplay
	await get_tree().create_timer(1.0).timeout  # Magic invincibility time
```

**Good - Config resource for game system:**
```gdscript
# EnemyConfig.gd extends Resource
class_name EnemyConfig
extends Resource

@export var max_health: int = 3
@export var damage_amount: int = 1
@export var speed: float = 150.0
@export var invincibility_time: float = 1.0

# Enemy.gd
@export var config: EnemyConfig

func take_damage():
	health -= config.damage_amount
	await get_tree().create_timer(config.invincibility_time).timeout
```

### When @export is Fine (Simple Components)

**Perfectly acceptable for UI/simple components:**
```gdscript
# ProductCard.gd - Simple UI component
extends PanelContainer

@export var hover_scale: float = 1.05
@export var animation_duration: float = 0.2
@export var default_padding: int = 10

func _on_mouse_entered():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE * hover_scale, animation_duration)
```

**Rule of thumb**: Game balance values → Config Resources. Component defaults → @export is fine.
