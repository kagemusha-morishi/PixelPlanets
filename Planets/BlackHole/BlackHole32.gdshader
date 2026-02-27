shader_type canvas_item;
render_mode blend_mix;

uniform float pixels : hint_range(10,100) = 100.0;
uniform vec4 colors[32] : source_color;
uniform float radius : hint_range(0.0,0.5) = 0.5;
uniform float light_width : hint_range(0.0, 0.5) = 0.05;

void fragment() {
	vec2 uv = floor(UV*pixels)/pixels;
	float d_to_center = distance(uv, vec2(0.5));
	
	// Map original 3-color logic to 32 colors:
	// colors[0] (inner) -> colors[0] (center, darkest)
	// colors[1] (middle ring) -> colors[10] (transition)
	// colors[2] (outer ring) -> colors[20] (edge, brightest)
	
	vec4 col = colors[0];	
	if (d_to_center > radius - light_width) {
		col = colors[10];
	}	
	if (d_to_center > radius - light_width * 0.5) {
		col = colors[20];
	}
	
	float a = step(d_to_center, radius);
	COLOR = vec4(col.rgb, a * col.a);
}