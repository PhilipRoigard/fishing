shader_type canvas_item;
render_mode blend_add;

// Underwater caustics - organic dappled light using Voronoi cells

uniform float time = 0.0;

// World-space uniforms for per-pixel depth fade
uniform float camera_world_x = 0.0;           // Camera center X in world coordinates (for horizontal parallax)
uniform float camera_world_y = 0.0;           // Camera center Y in world coordinates
uniform float viewport_world_height = 648.0;  // Viewport height in world units (accounts for zoom)
uniform float surface_y = 0.0;                // World Y position of water surface
uniform float caustics_fade_depth = 300.0;    // Depth in world units where caustics fully disappear
uniform float horizontal_parallax = 0.002;    // How much caustics shift with camera X
uniform float vertical_parallax = 0.001;      // How much caustics shift with camera Y

uniform float ray_intensity : hint_range(0.0, 1.0) = 0.2;
uniform float ray_speed : hint_range(0.0, 2.0) = 0.4;
uniform float ray_scale : hint_range(1.0, 50.0) = 25.0;
uniform vec3 ray_color : source_color = vec3(1.0, 1.0, 0.95);

// Random vector for Voronoi
vec2 random2(vec2 p) {
	return fract(sin(vec2(
		dot(p, vec2(127.1, 311.7)),
		dot(p, vec2(269.5, 183.3))
	)) * 43758.5453);
}

// Voronoi distance - creates organic cell patterns
float voronoi(vec2 uv, float t) {
	vec2 i_uv = floor(uv);
	vec2 f_uv = fract(uv);
	
	float min_dist = 1.0;
	
	// Check neighboring cells
	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 neighbor = vec2(float(x), float(y));
			vec2 point = random2(i_uv + neighbor);
			
			// Animate the points
			point = 0.5 + 0.5 * sin(t + 6.2831 * point);
			
			vec2 diff = neighbor + point - f_uv;
			float dist = length(diff);
			min_dist = min(min_dist, dist);
		}
	}
	
	return min_dist;
}

// Layered caustics using multiple Voronoi scales
float caustics(vec2 uv, float t) {
	float c = 0.0;
	
	// Layer 1: larger cells
	c += voronoi(uv, t * 0.8) * 0.5;
	
	// Layer 2: medium cells, offset position and time
	c += voronoi(uv * 1.5 + 10.0, t * 1.1 + 3.0) * 0.3;
	
	// Layer 3: smaller detail cells
	c += voronoi(uv * 2.2 + 25.0, t * 0.6 + 7.0) * 0.2;
	
	// Invert so cell centers are bright, edges are dark
	c = 1.0 - c;
	
	// Soft power curve for gentle highlights
	c = pow(c, 2.0);
	
	return c;
}

void fragment() {
	// Apply parallax offset based on camera position
	vec2 parallax_uv = UV;
	parallax_uv.x += camera_world_x * horizontal_parallax;
	parallax_uv.y += camera_world_y * vertical_parallax;
	
	// Scale UV for pattern size
	vec2 scaled_uv = parallax_uv * ray_scale;
	
	// Calculate per-pixel world Y position
	// UV.y goes from 0 (top) to 1 (bottom), camera is centered
	float pixel_offset_from_center = (UV.y - 0.5) * viewport_world_height;
	float pixel_world_y = camera_world_y + pixel_offset_from_center;
	
	// Calculate depth from surface (positive = underwater)
	float pixel_depth = max(0.0, pixel_world_y - surface_y);
	
	// Per-pixel depth fade: 1.0 at surface, 0.0 at caustics_fade_depth
	float depth_fade = 1.0 - smoothstep(0.0, caustics_fade_depth, pixel_depth);
	
	// Animated time
	float t = time * ray_speed;
	
	// Get caustic pattern
	float c = caustics(scaled_uv, t);
	
	// Apply intensity and depth fade
	float final_intensity = c * ray_intensity * depth_fade;
	
	// Output
	COLOR = vec4(ray_color * final_intensity, 1.0);
}
