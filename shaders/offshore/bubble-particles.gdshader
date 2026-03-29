shader_type particles;
render_mode keep_data;

// Movement settings
uniform float initial_velocity_min : hint_range(0.0, 500.0) = 80.0;
uniform float initial_velocity_max : hint_range(0.0, 500.0) = 150.0;
uniform float damping : hint_range(0.0, 200.0) = 75.0;
uniform float particle_lifetime : hint_range(0.1, 200.0) = 1.0;

// Scale settings
uniform float scale_min : hint_range(0.1, 10.0) = 2.0;
uniform float scale_max : hint_range(0.1, 10.0) = 5.0;

// Oscillation settings
uniform float oscillation_amplitude : hint_range(0.0, 200.0) = 100.0;
uniform float oscillation_frequency : hint_range(0.0, 20.0) = 2.0;

// Hash function for randomness based on particle index
float hash(float n) {
	return fract(sin(n) * 43758.5453123);
}

void start() {
	// Random angle for 360 degree spread
	float angle = hash(float(INDEX) * 1.23) * TAU;
	
	// Random speed between min and max
	float speed = mix(initial_velocity_min, initial_velocity_max, hash(float(INDEX) * 4.56));
	
	// Set initial velocity in random direction
	VELOCITY = vec3(cos(angle) * speed, sin(angle) * speed, 0.0);
	
	// Random scale between min and max
	float s = mix(scale_min, scale_max, hash(float(INDEX) * 7.89));
	TRANSFORM[0].x = s;
	TRANSFORM[1].y = s;
	TRANSFORM[2].z = 1.0;
	
	// Set initial position to emitter's world position
	TRANSFORM[3] = EMISSION_TRANSFORM[3];
	
	// Store random phase offset for oscillation in CUSTOM.x
	CUSTOM.x = hash(float(INDEX) * 2.34) * TAU;
	
	// Store initial perpendicular direction in CUSTOM.yz
	CUSTOM.y = -sin(angle);  // perpendicular x
	CUSTOM.z = cos(angle);   // perpendicular y
	
	// Store start time in CUSTOM.w for fade calculation
	CUSTOM.w = 0.0;
}

void process() {
	// Track age
	CUSTOM.w += DELTA;
	
	// Apply damping to slow down over time
	float speed = length(VELOCITY);
	if (speed > 0.1) {
		float damp_amount = damping * DELTA;
		float new_speed = max(speed - damp_amount, 0.0);
		VELOCITY = normalize(VELOCITY) * new_speed;
	}
	
	// Sine wave oscillation perpendicular to initial movement direction
	float wave = sin(CUSTOM.w * oscillation_frequency * TAU + CUSTOM.x) * oscillation_amplitude;
	float prev_wave = sin((CUSTOM.w - DELTA) * oscillation_frequency * TAU + CUSTOM.x) * oscillation_amplitude;
	float wave_delta = wave - prev_wave;
	
	// Apply oscillation offset (perpendicular to original velocity direction)
	TRANSFORM[3].x += CUSTOM.y * wave_delta;
	TRANSFORM[3].y += CUSTOM.z * wave_delta;
	
	// Fade out alpha over lifetime
	float life_ratio = CUSTOM.w / particle_lifetime;
	COLOR.a = 1.0 - clamp(life_ratio, 0.0, 1.0);
}
