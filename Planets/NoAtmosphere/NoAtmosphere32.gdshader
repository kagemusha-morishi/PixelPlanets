shader_type canvas_item;
render_mode blend_mix;

uniform float pixels : hint_range(10,100);
uniform float rotation : hint_range(0.0, 6.28) = 0.0;
uniform vec2 light_origin = vec2(0.39, 0.39);
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

vec2 spherify(vec2 uv) {
	vec2 centered= uv *2.0-1.0;
	float z = sqrt(1.0 - dot(centered.xy, centered.xy));
	vec2 sphere = centered/(z + 1.0);
	return sphere * 0.5+0.5;
}

float circleNoise(vec2 uv) {
    float uv_y = floor(uv.y);
    uv.x += uv_y*.31;
    vec2 f = fract(uv);
	float h = rand(vec2(floor(uv.x),floor(uv_y)));
    float m = (length(f-0.25-(h*0.5)));
    float r = h*0.25;
    return smoothstep(0.0, r, m);
}

float crater(vec2 uv) {
	float c = 1.0;
	for (int i = 0; i < 2; i++) {
		c *= circleNoise((uv * size) + (float(i+1)+10.));
	}
	return 1.0 - c;
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
	bool dith = dither(uv, UV);
	float a = step(length(uv-vec2(0.5)), 0.5);
	
	uv = rotate(uv, rotation);
	uv = spherify(uv);
	
	float n = fbm(uv*size);
	float c1 = crater(uv);
	float c2 = crater(uv + (light_origin-0.5)*0.05);
	
	float d_light = distance(uv, light_origin);
	
	float gradient_t = n;
	gradient_t += (c1 - 0.5) * 0.3;
	gradient_t += (1.0 - d_light) * 0.2;
	gradient_t = clamp(gradient_t, 0.0, 1.0);
	
	vec4 col = sample_gradient(gradient_t);
	
	COLOR = vec4(col.rgb, a * col.a);
}