shader_type canvas_item;

// Depth-based ocean background shader with animated noise distortion and vignette

uniform vec3 surface_color : source_color = vec3(0.0, 0.88, 0.95);
uniform vec3 mid_depth_color : source_color = vec3(0.0, 0.4, 0.7);
uniform vec3 deep_color : source_color = vec3(0.0, 0.15, 0.25);
uniform float time = 0.0;

// World-space uniforms for per-pixel depth calculation
uniform float camera_world_y = 0.0;           // Camera center Y in world coordinates
uniform float viewport_world_height = 648.0;  // Viewport height in world units (accounts for zoom)
uniform float surface_y = 0.0;                // World Y position of water surface
uniform float max_depth = 2000.0;             // Maximum ocean depth in world units

// Vignette settings
uniform float vignette_base_intensity : hint_range(0.0, 1.0) = 0.1;
uniform float vignette_depth_multiplier : hint_range(0.0, 2.0) = 0.6;
uniform float vignette_softness : hint_range(0.0, 1.0) = 0.4;

// Noise distortion settings
uniform float distortion_base_strength : hint_range(0.0, 0.5) = 0.08;
uniform float distortion_depth_strength : hint_range(0.0, 0.5) = 0.20;

// Procedural noise function for organic texture
float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i + vec2(0.0, 0.0)), hash(i + vec2(1.0, 0.0)), u.x),
	           mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

// Layered noise for more organic appearance
float layered_noise(vec2 uv) {
	float value = 0.0;
	float amplitude = 1.0;
	for (int i = 0; i < 3; i++) {
		value += noise(uv) * amplitude;
		uv *= 2.0;
		amplitude *= 0.5;
	}
	return value;
}

// Vignette effect - darker edges that increase with depth
float vignette(vec2 uv, float intensity, float softness) {
	vec2 centered = uv - 0.5;
	float dist = length(centered) * 1.414; // Normalize so corners = 1.0
	return smoothstep(1.0 - softness, 1.0, dist) * intensity;
}

void fragment() {
	// Calculate per-pixel world Y position
	// UV.y goes from 0 (top) to 1 (bottom), camera is centered
	float pixel_offset_from_center = (UV.y - 0.5) * viewport_world_height;
	float pixel_world_y = camera_world_y + pixel_offset_from_center;
	
	// Calculate depth from surface (positive = underwater)
	float pixel_depth = max(0.0, pixel_world_y - surface_y);
	
	// Per-pixel depth factor: 0.0 at surface, 1.0 at max_depth
	float depth_factor = clamp(pixel_depth / max_depth, 0.0, 1.0);
	
	// Depth-based color gradient: cyan/blue at surface -> dark blue/green at depth
	vec3 color;
	if (depth_factor < 0.5) {
		// Interpolate between surface and mid depth
		color = mix(surface_color, mid_depth_color, depth_factor * 2.0);
	} else {
		// Interpolate between mid depth and deep
		color = mix(mid_depth_color, deep_color, (depth_factor - 0.5) * 2.0);
	}
	
	// Add green tint at greater depths (murky water effect)
	if (depth_factor > 0.5) {
		color.g += (depth_factor - 0.5) * 0.1;
	}
	
	// Add procedural texture distortion with slow animation
	vec2 distorted_uv = UV;
	distorted_uv += vec2(time * 0.02, time * 0.015);  // Slow drift
	
	// Create organic splotches at different scales
	float distortion = layered_noise(distorted_uv * 3.0);       // Large features
	distortion += layered_noise(distorted_uv * 8.0) * 0.5;      // Medium details
	distortion += layered_noise(distorted_uv * 15.0) * 0.25;    // Fine grain
	distortion /= 1.75;  // Normalize
	
	// Apply distortion with depth-based strength
	float distortion_strength = mix(distortion_base_strength, distortion_depth_strength, depth_factor);
	color += (distortion - 0.5) * distortion_strength;
	
	// Apply vignette that intensifies with depth
	float vignette_intensity = vignette_base_intensity + (depth_factor * vignette_depth_multiplier);
	float vignette_value = vignette(UV, vignette_intensity, vignette_softness);
	color = mix(color, vec3(0.0), vignette_value);
	
	COLOR = vec4(color, 1.0);
}
