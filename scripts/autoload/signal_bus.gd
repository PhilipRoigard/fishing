extends Node


# --- Game State ---
@warning_ignore("unused_signal")
signal game_started
@warning_ignore("unused_signal")
signal game_paused
@warning_ignore("unused_signal")
signal game_resumed

# --- Game Mode ---
@warning_ignore("unused_signal")
signal game_mode_changed(mode: int)
@warning_ignore("unused_signal")
signal fishing_session_started
@warning_ignore("unused_signal")
signal fishing_session_ended

# --- Fishing States ---
@warning_ignore("unused_signal")
signal fishing_state_changed(state: int)
@warning_ignore("unused_signal")
signal cast_started(strength: float)
@warning_ignore("unused_signal")
signal cast_landed(depth: float)
@warning_ignore("unused_signal")
signal hook_position_changed(position: Vector2)
@warning_ignore("unused_signal")
signal cast_strength_changed(strength: float)

# --- Bite & Fight ---
@warning_ignore("unused_signal")
signal bite_occurred(fish_id: String)
@warning_ignore("unused_signal")
signal bite_missed
@warning_ignore("unused_signal")
signal fight_started(fish_id: String)
@warning_ignore("unused_signal")
signal fight_progress_changed(progress: float)
@warning_ignore("unused_signal")
signal fight_tension_changed(tension: float)
@warning_ignore("unused_signal")
signal fight_phase_changed(phase: int)
@warning_ignore("unused_signal")
signal fish_caught(fish_id: String)
@warning_ignore("unused_signal")
signal fish_escaped(fish_id: String)
@warning_ignore("unused_signal")
signal line_snapped
@warning_ignore("unused_signal")
signal bracket_position_changed(position: float, size: float)
@warning_ignore("unused_signal")
signal fish_track_position_changed(position: float)

# --- Consumables ---
@warning_ignore("unused_signal")
signal consumable_used(effect: int, duration: float)
@warning_ignore("unused_signal")
signal consumable_effect_started(effect: int)
@warning_ignore("unused_signal")
signal consumable_effect_ended(effect: int)

# --- Fish Spawning ---
@warning_ignore("unused_signal")
signal fish_spawned(fish_id: String, position: Vector2)
@warning_ignore("unused_signal")
signal school_spawned(fish_id: String, school_size: int, position: Vector2)
@warning_ignore("unused_signal")
signal school_scattered(position: Vector2)
@warning_ignore("unused_signal")
signal school_member_caught(fish_data: Resource, remaining: int)
@warning_ignore("unused_signal")
signal fish_despawned(fish_id: String)

# --- Economy ---
@warning_ignore("unused_signal")
signal coins_changed(previous: int, current: int)
@warning_ignore("unused_signal")
signal gems_changed(previous: int, current: int)
@warning_ignore("unused_signal")
signal fish_sold(fish_id: String, coins_earned: int)
@warning_ignore("unused_signal")
signal currency_animation_requested(amount: int, currency_type: String, source_position: Vector2)

# --- Equipment ---
@warning_ignore("unused_signal")
signal equipment_changed(slot: int)
@warning_ignore("unused_signal")
signal equipment_item_acquired(uuid: String, item_id: String, quality: int)
@warning_ignore("unused_signal")
signal equipment_merged(uuid: String, item_id: String, from_quality: int, to_quality: int)
@warning_ignore("unused_signal")
signal equipment_leveled_up(uuid: String, new_level: int)

# --- Progression ---
@warning_ignore("unused_signal")
signal xp_gained(amount: int)
@warning_ignore("unused_signal")
signal level_up(new_level: int)
@warning_ignore("unused_signal")
signal milestone_reached(milestone_id: String)
@warning_ignore("unused_signal")
signal collection_updated(fish_id: String, total_caught: int)
@warning_ignore("unused_signal")
signal depth_zone_unlocked(zone: int)

# --- Gacha ---
@warning_ignore("unused_signal")
signal tackle_box_pull_started(pack_id: String)
@warning_ignore("unused_signal")
signal tackle_box_pull_completed(results: Array)
@warning_ignore("unused_signal")
signal daily_free_pull_available

# --- IAP ---
@warning_ignore("unused_signal")
signal purchase_started(product_id: String)
@warning_ignore("unused_signal")
signal purchase_completed(product_id: String)
@warning_ignore("unused_signal")
signal purchase_failed(product_id: String, reason: String)

# --- UI ---
@warning_ignore("unused_signal")
signal show_notification(text: String, color: Color)
@warning_ignore("unused_signal")
signal show_floating_text(text: String, position: Vector2, color: Color)
@warning_ignore("unused_signal")
signal tab_should_change(tab_index: int)
@warning_ignore("unused_signal")
signal set_tabs_enabled(enabled: bool)

# --- Input ---
@warning_ignore("unused_signal")
signal reel_input_started
@warning_ignore("unused_signal")
signal reel_input_ended
@warning_ignore("unused_signal")
signal cast_input_started
@warning_ignore("unused_signal")
signal cast_input_ended

# --- Save/Load ---
@warning_ignore("unused_signal")
signal save_requested
@warning_ignore("unused_signal")
signal save_completed
@warning_ignore("unused_signal")
signal load_completed
