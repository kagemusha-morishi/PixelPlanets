extends "res://Planets/Planet.gd"

func set_pixels(amount):
	$Lava.material.set_shader_parameter("pixels", amount)
	$Lava.size = Vector2(amount, amount)

func set_light(pos):
	$Lava.material.set_shader_parameter("light_origin", pos)

func set_seed(sd):
	var converted_seed = sd%1000/100.0
	$Lava.material.set_shader_parameter("seed", converted_seed)

func set_rotates(r):
	$Lava.material.set_shader_parameter("rotation", r)
	
func update_time(t):
	$Lava.material.set_shader_parameter("time", t * get_multiplier($Lava.material) * 0.02)
	
func set_custom_time(t):
	$Lava.material.set_shader_parameter("time", t * get_multiplier($Lava.material))

func set_dither(d):
	$Lava.material.set_shader_parameter("should_dither", d)

func get_dither():
	return $Lava.material.get_shader_parameter("should_dither")

func get_colors():
	return get_colors_from_shader($Lava.material)

func set_colors(colors):
	set_colors_on_shader($Lava.material, colors)

static func generate_gradient(color1: Color, color2: Color, steps: int) -> Array:
	var gradient = []
	for i in range(steps):
		var t = float(i) / float(steps - 1)
		gradient.append(color1.lerp(color2, t))
	return gradient

static func generate_multi_gradient(stops: Array, total_steps: int) -> Array:
	if stops.size() < 2:
		return []
	var gradient = []
	var steps_per_segment = total_steps / (stops.size() - 1)
	for i in range(stops.size() - 1):
		var segment = generate_gradient(stops[i], stops[i + 1], steps_per_segment)
		gradient.append_array(segment)
	while gradient.size() > total_steps:
		gradient.pop_back()
	while gradient.size() < total_steps:
		gradient.append(gradient.back())
	return gradient

func randomize_colors():
	var num_stops = randi() % 4 + 3
	var hue_base = randf_range(0.0, 0.1) # Red to orange range for lava
	var stops = []
	for i in range(num_stops):
		var hue = fmod(hue_base + float(i) / float(num_stops) * 0.05, 1.0)
		var sat = randf_range(0.7, 1.0)
		var val = randf_range(0.2 + float(i) / float(num_stops) * 0.8, 1.0)
		stops.append(Color.from_hsv(hue, sat, val))
	var gradient = generate_multi_gradient(stops, 32)
	set_colors(gradient)