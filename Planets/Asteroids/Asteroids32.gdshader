shader_type canvas_item;
render_mode blend_mix;

uniform float pixels : hint_range(10,100);
uniform float rotation : hint_range(0.0, 6.28) = 1.0;
uniform vec2 light_origin = vec2(0.39, 0.39);
uniform float time_speed : hint_range(0.0, 1.0) = 0.2;
uniform vec4 colors[32] : source_color;
uniform float size = 50.0;
uniform int octaves : hint_range(0, 20, 1);
uniform float seed: hint_range(1, 10);
uniform bool should_dither = true;

float rand(vec2 coord) {
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

	for(int i = 0; i < octaves ; i++){
		value += noise(coord) * scale;
		coord *= 2.0;
		scale *= 0.5;
	}
	return value;
}

bool dither(vec2 uv1, vec2 uv2) {
	return mod(uv1.x+uv2.y,2.0/pixels) <= 1.0 / pixels;
}

vec2 rotate(vec2 coord, float angle){
	coord -= 0.5;
	coord *= mat2(vec2(cos(angle),-sin(angle)),vec2(sin(angle),cos(angle)));
	return coord + 0.5;
}

// by Leukbaars from https://www.shadertoy.com/view/4tK3zR
float circleNoise(vec2 uv) {
    float uv_y = floor(uv.y);
    uv.x += uv_y*.31;
    vec2 f = fract(uv);
	float h = rand(vec2(floor(uv.x),floor(uv_y)));
    float m = (length(f-0.25-(h*0.5)));
    float r = h*0.25;
    return m = smoothstep(r-.10*r,r,m);
}

float crater(vec2 uv) {
	float c = 1.0;
	for (int i = 0; i < 2; i++) {
		c *= circleNoise((uv * size) + (float(i+1)+10.));
	}
	return 1.0 - c;
}

// Sample gradient from 32 color palette
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
	bool dith = dither(uv, UV);
	float d = distance(uv, vec2(0.5));
	uv = rotate(uv, rotation);
	
	float n = fbm(uv * size);
	float n2 = fbm(uv * size + (rotate(light_origin, rotation)-0.5) * 0.5);
	
	float n_step = step(0.2, n - d);
	float n2_step = step(0.2, n2 - d);
	
	float noise_rel = (n2_step + n2) - (n_step + n);
	
	float c1 = crater(uv);
	float c2 = crater(uv + (light_origin-0.5)*0.03);

	// Use gradient sampling
	float gradient_t = (noise_rel + 1.0) * 0.5; // Map -1..1 to 0..1
	gradient_t += (c1 - 0.5) * 0.2; // Add crater influence
	
	vec4 col = sample_gradient(clamp(gradient_t, 0.0, 1.0));
	
	// Adjust for craters
	if (c1 > 0.4) {
		col = sample_gradient(0.5 + (c1 - 0.4) * 0.3);
	}
	if (c2 < c1) {
		col = sample_gradient(0.7 + (c1 - c2) * 0.3);
	}
	
	COLOR = vec4(col.rgb, n_step * col.a);
}