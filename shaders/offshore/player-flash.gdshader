shader_type canvas_item;

// Player flash shader for catch mechanic visual feedback
// Blends sprite toward white based on intensity uniforms

uniform float flash_intensity : hint_range(0.0, 1.0) = 0.0;     // Instant flash on catch
uniform float recharge_intensity : hint_range(0.0, 1.0) = 0.0;  // Gradual recharge glow

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	
	// Use the max of flash and recharge for final white blend
	float intensity = max(flash_intensity, recharge_intensity);
	
	// Blend toward white based on intensity
	vec3 white = vec3(1.0, 1.0, 1.0);
	vec3 blended = mix(tex_color.rgb, white, intensity);
	
	COLOR = vec4(blended, tex_color.a);
}
