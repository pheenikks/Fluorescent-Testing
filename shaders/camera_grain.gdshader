// Subtle camcorder-ish finish: luminance-aware film grain, vignette, and slight
// chromatic aberration toward the frame edges.
shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform float grain_amount = 0.045;
uniform float vignette_strength = 0.45;
uniform float aberration = 0.004;

float hash(vec2 p) {
	p = fract(p * vec2(443.897, 441.423));
	p += dot(p, p.yx + 19.19);
	return fract((p.x + p.y) * p.x);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 d = uv - 0.5;
	float r2 = dot(d, d);

	vec2 off = d * r2 * aberration * 4.0;
	vec3 col = vec3(
		texture(screen_tex, uv + off).r,
		texture(screen_tex, uv).g,
		texture(screen_tex, uv - off).b);

	float lum = dot(col, vec3(0.299, 0.587, 0.114));
	float grain = hash(FRAGCOORD.xy + fract(TIME * 13.7) * 1000.0) - 0.5;
	col += grain * grain_amount * mix(1.4, 0.6, lum);

	col *= 1.0 - vignette_strength * smoothstep(0.05, 0.55, r2 * 2.0);
	COLOR = vec4(col, 1.0);
}
