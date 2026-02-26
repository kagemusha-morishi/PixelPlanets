shader_type canvas_item;
render_mode blend_mix;

uniform float pixels : hint_range(10,100);
uniform float rotation : hint_range(0.0, 6.28) = 0.0;
uniform vec2 light_origin = vec2(0.39, 0.39);
uniform float time_speed : hint_range(-2.0, 3.0) = 0.2;
uniform float river_cutoff : hint_range(0.0, 1.0);
uniform vec4 colors[32] : source_color;
uniform float size = 50.0;
uniform int OCTAVES : hint_range(0, 20, 1);
uniform float seed: hint_range(1, 10);
uniform float time = 0.0;

float rand(vec2 coord) {
	coord = mod(coord, vec2(2.0,1.0)*round(size));
	return fract(sin(dot(coord.xy ,vec2(12.9898,78.233))) * 15.5453 * seed);
}

float noise(vec2 coord){
	vec2 i = floor(coord);
	vec2 f = fract(coord);
	float a = rand(i);
	float b = rand(i + vec2(1.0, 0.0));
	float c = rand(i + vec2(0.0, 1.0));
	float d = rand(i + vec2(1.0, 1.0));
	vec2 cubic = f * f * (3.0 - 2.0 * f);
	return mix(a, b, cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y;
}

float fbm(vec2 coord){
	float value = 0.0;
	float scale = 0.5;
	for(int i = 0; i < OCTAVES ; i++){
		value += noise(coord) * scale;
		coord *= 2.0;
		scale *= 0.5;
	}
	return value;
}

vec2 spherify(vec2 uv) {
	vec2 centered= uv *2.0-1.0;
	float z = sqrt(1.0 - dot(centered.xy, centered.xy));
	vec2 sphere = centered/(z + 1.0);
	return sphere * 0.5+0.5;
}

vec2 rotate(vec2 coord, float angle){
	coord -= 0.5;
	coord *= mat2(vec2(cos(angle),-sin(angle)),vec2(sin(angle),cos(angle)));
	return coord + 0.5;
}

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
	
	float d_light = distance(uv , light_origin);
	float d_circle = distance(uv, vec2(0.5));
	
	uv = rotate(uv, rotation);
	uv = spherify(uv);
	
	float fbm1 = fbm(uv*size+vec2(time*time_speed,0.0));
	float river_fbm = fbm(uv + fbm1*2.5);
	
	d_light = pow(d_light, 2.0)*0.4;
	d_light -= d_light * river_fbm;
	
	river_fbm = step(river_cutoff, river_fbm);
	
	// Use gradient based on fbm and lighting
	float gradient_t = clamp(fbm1 * 0.5 + d_light, 0.0, 1.0);
	vec4 col = sample_gradient(gradient_t);
	
	float a = step(river_cutoff, river_fbm) * step(d_circle, 0.5);
	COLOR = vec4(col.rgb, a * col.a);
}