// Level 0 wallpaper: faded yellow stripes with a small repeating chevron motif,
// grime, and damp staining wicking up from the carpet.
// World-space mapping so walls of any size/orientation line up seamlessly.
shader_type spatial;

uniform vec3 base_color : source_color = vec3(0.80, 0.74, 0.47);
uniform vec3 stripe_color : source_color = vec3(0.74, 0.67, 0.40);
uniform vec3 damp_color : source_color = vec3(0.42, 0.36, 0.20);
uniform float stripe_width = 0.06;
uniform float motif_spacing = 0.12;
uniform float damp_height = 0.35;
uniform sampler2D grime : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform sampler2D bump : hint_normal, filter_linear_mipmap, repeat_enable;

varying vec3 world_pos;
varying vec3 world_normal;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	// Horizontal coordinate along whichever axis this wall face runs.
	float u = abs(world_normal.x) > abs(world_normal.z) ? world_pos.z : world_pos.x;
	vec2 wp = vec2(u, world_pos.y);

	// Alternating vertical stripes.
	float stripe = step(0.5, fract(u / (stripe_width * 2.0)));

	// Small chevrons running up the centre of every other stripe.
	vec2 cell = vec2(fract(u / (stripe_width * 2.0)) - 0.25, fract(world_pos.y / motif_spacing) - 0.5);
	float chevron = abs(cell.y + abs(cell.x) * 2.0 - 0.15);
	float motif = (1.0 - smoothstep(0.03, 0.07, chevron)) * (1.0 - smoothstep(0.12, 0.2, abs(cell.x)));

	vec3 col = mix(base_color, stripe_color, stripe * 0.6);
	col = mix(col, stripe_color * 0.85, motif * 0.5);

	float g = texture(grime, wp * 0.15).r;
	col *= mix(0.82, 1.0, g);

	// Moisture wicking up from the carpet, with an uneven tide line.
	float tide = damp_height * mix(0.5, 1.5, texture(grime, vec2(u * 0.08, 0.37)).r);
	float damp = 1.0 - smoothstep(tide * 0.3, tide, world_pos.y);
	col = mix(col, damp_color, damp * 0.55);

	ALBEDO = col;
	ROUGHNESS = mix(0.85, 0.7, damp);
	NORMAL_MAP = texture(bump, wp * 0.6).rgb;
	NORMAL_MAP_DEPTH = 0.25;
}
