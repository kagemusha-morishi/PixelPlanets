shader_type canvas_item;
render_mode blend_mix;

uniform float pixels : hint_range(10,300) = 100.0;
uniform float rotation : hint_range(0.0, 6.28) = 0.0;
uniform vec2 light_origin = vec2(0.39, 0.39);
uniform float time_speed : hint_range(-1.0, 1.0) = 0.2;
uniform float disk_width : hint_range(0.0, 0.15) = 0.1;
uniform float ring_perspective = 4.0;
uniform bool should_dither = true;
uniform vec4 colors[32] : source_color;
uniform int n_colors : hint_range(1, 32) = 32;

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

float circleNoise(vec2 uv) {
    float uv_y = floor(uv.y);
    uv.x += uv_y*.31;
    vec2 f = fract(uv);
	float h = rand(vec2(floor(uv.x),floor(uv_y)));
    float m = (length(f-0.25-(h*0.5)));
    float r = h*0.25;
    return smoothstep(0.0, r, m*0.75);
}

bool dither(vec2 uv_pixel, vec2 uv_real) {
	return mod(uv_pixel.x+uv_real.y,2.0/pixels) <= 1.0 / pixels;
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

void fragment() {
	vec2 uv = floor(UV*pixels)/pixels;
	bool dith = dither(UV, uv);
	
	uv = rotate(uv, rotation);
	vec2 uv2 = uv;
	
	uv.x -= 0.5;
	uv.x *= 1.3;
	uv.x += 0.5;
	uv = rotate(uv, sin(time * time_speed * 2.0) * 0.01);
	
	vec2 l_origin = vec2(0.5);
	float d_width = disk_width;
	
	if (uv.y < 0.5) { 
		uv.y += smoothstep(distance(vec2(0.5), uv), 0.5, 0.2);
		d_width += smoothstep(distance(vec2(0.5), uv), 0.5, 0.3);
		l_origin.y -= smoothstep(distance(vec2(0.5), uv), 0.5, 0.2);
	} 
	else if (uv.y > 0.53) {
		uv.y -= smoothstep(distance(vec2(0.5), uv), 0.4, 0.17);
		d_width += smoothstep(distance(vec2(0.5), uv), 0.5, 0.2);
		l_origin.y += smoothstep(distance(vec2(0.5), uv), 0.5, 0.2);
	}
	
	float light_d = distance(uv2 * vec2(1.0, ring_perspective), l_origin * vec2(1.0, ring_perspective)) * 0.3;
	vec2 uv_center = uv - vec2(0.0, 0.5);
	uv_center *= vec2(1.0, ring_perspective);
	float center_d = distance(uv_center,vec2(0.5, 0.0));
	
	float disk = smoothstep(0.1-d_width*2.0, 0.5-d_width, center_d);
	disk *= smoothstep(center_d-d_width, center_d, 0.4);
	
	uv_center = rotate(uv_center+vec2(0, 0.5), time*time_speed*3.0);
	disk *= pow(fbm(uv_center*size), 0.5);
	
	if (dith || !should_dither) {
		disk *= 1.2;
	}
	
	// Posterized color selection (same logic as original)
	float n_posterized = float(n_colors - 1);
	float posterized = floor((disk+light_d)*n_posterized);
	posterized = min(posterized, n_posterized);
	vec4 col = colors[int(posterized)];
	
	float disk_a = step(0.15, disk);
	COLOR = vec4(col.rgb, disk_a * col.a);
}