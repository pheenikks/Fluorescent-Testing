// Drop-ceiling: 2x2 ft (0.6 m) acoustic tiles held by a metal T-bar grid.
// Uses world-space XZ so any ceiling mesh lines up with the light-fixture grid.
shader_type spatial;

uniform vec3 tile_color : source_color = vec3(0.86, 0.84, 0.76);
uniform vec3 grid_color : source_color = vec3(0.74, 0.72, 0.64);
uniform float tile_size = 0.6;
uniform float grid_width = 0.024;
uniform sampler2D speckle : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform float speckle_scale = 0.8;
uniform sampler2D stains : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform float stain_scale = 0.05;
uniform vec3 stain_color : source_color = vec3(0.62, 0.54, 0.36);

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 p = world_pos.xz / tile_size;
	vec2 g = abs(fract(p) - 0.5);
	// Distance in meters to the nearest grid line.
	float edge_dist = (0.5 - max(g.x, g.y)) * tile_size;
	float aa = fwidth(edge_dist);
	float grid = 1.0 - smoothstep(grid_width * 0.5 - aa, grid_width * 0.5 + aa, edge_dist);
	// Slight shading where the tile meets the T-bar.
	float bevel = smoothstep(grid_width * 0.5, grid_width * 2.0, edge_dist);

	float n = texture(speckle, world_pos.xz * speckle_scale).r;
	float s = texture(stains, world_pos.xz * stain_scale).r;
	vec3 tile = tile_color * mix(0.9, 1.04, n) * mix(0.85, 1.0, bevel);
	tile = mix(tile, stain_color, smoothstep(0.62, 0.85, s) * 0.45);

	ALBEDO = mix(tile, grid_color, grid);
	ROUGHNESS = mix(0.95, 0.45, grid);
	METALLIC = grid * 0.4;
}
