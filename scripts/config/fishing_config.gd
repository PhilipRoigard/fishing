class_name FishingConfig
extends Resource

@export_group("Casting")
@export var min_cast_depth: float = 50.0
@export var max_cast_depth_base: float = 500.0
@export var charge_duration: float = 1.5
@export var hook_fall_speed: float = 200.0
@export var hook_wobble_amplitude: float = 3.0

@export_group("Bite Detection")
@export var base_bite_radius: float = 20.0
@export var base_bite_chance: float = 0.15
@export var base_attract_range: float = 250.0
@export var bite_check_interval: float = 0.3
@export var attract_delay: float = 1.5
@export var force_attract_time: float = 5.0
@export var bite_delay_min: float = 3.0
@export var bite_delay_max: float = 8.0
@export var bite_window: float = 1.0

@export_group("Fish Curiosity")
@export var curiosity_range: float = 180.0
@export var curiosity_chance: float = 0.08
@export var curiosity_speed_mult: float = 0.8
@export var curiosity_target_offset: float = 5.0
@export var curiosity_duration_min: float = 3.0
@export var curiosity_duration_max: float = 8.0
@export var nibble_distance: float = 30.0

@export_group("Fight - Progress")
@export var starting_progress: float = 30.0
@export var catch_increase_rate: float = 40.0
@export var catch_decrease_rate: float = 20.0

@export_group("Fight - Tension")
@export var base_tension_rate: float = 25.0
@export var tension_relief_rate: float = 35.0
@export var tension_snap_threshold: float = 100.0
@export var tension_fighting_fish_multiplier: float = 1.5

@export_group("Fight - Fish AI")
@export var fish_speed_base: float = 64.0
@export var fish_change_interval: float = 0.5
@export var fish_stop_duration: float = 0.5
@export var fish_stop_interval_min: float = 1.0
@export var fish_stop_interval_max: float = 5.0

@export_group("Fight - Phases")
@export var desperate_phase_threshold: float = 60.0
@export var final_stand_phase_threshold: float = 85.0

@export_group("Consumable Defaults")
@export var stun_duration_small: float = 2.0
@export var stun_duration_large: float = 4.0
@export var line_wax_decay_multiplier: float = 0.5
@export var line_wax_duration: float = 8.0
@export var steel_thread_tension_bonus: float = 0.3
@export var steel_thread_duration: float = 12.0
@export var lucky_hook_gain_multiplier: float = 1.4
@export var lucky_hook_duration: float = 6.0
