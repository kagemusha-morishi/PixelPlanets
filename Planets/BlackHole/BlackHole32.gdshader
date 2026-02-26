shader_type canvas_item;
render_mode blend_mix;

uniform float pixels : hint_range(10,100) = 100.0;
uniform vec4 colors[32] : source_color;
uniform float radius : hint_range(0.0,0.5) = 0.5;
uniform float light_width : hint_range(0.0, 0.5) = 0.05;

vec4 sample_gradient(float t) {
	t = clamp(t, 0.0, 1.0);
	float scaled = t * 31.0;
	int idx = int(floor(scaled));
	int idx_next = min(idx + 1, 31);
	float blend = fract(scaled);
	return mix(colors[idx], colors[idx_next], blend);
}

void fragment() {
	vec2 uv = floor(UV*pixels)/pixels;
	float d_to_center = distance(uv, vec2(0.5));
	
	// Use gradient based on distance
	float t = smoothstep(radius - light_width, radius, d_to_center);
	vec4 col = sample_gradient(t);
	
	float a = step(d_to_center, radius);
	COLOR = vec4(col.rgb, a * col.a);
}