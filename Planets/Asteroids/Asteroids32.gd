extends "res://Planets/Planet.gd"

func set_pixels(amount):
	$Asteroid.material.set_shader_parameter("pixels", amount)
	$Asteroid.size = Vector2(amount, amount)

func set_light(pos):
	$Asteroid.material.set_shader_parameter("light_origin", pos)

func set_seed(sd):
	var converted_seed = sd%1000/100.0
	$Asteroid.material.set_shader_parameter("seed", converted_seed)

func set_rotates(r):
	$Asteroid.material.set_shader_parameter("rotation", r)

func update_time(_t):
	pass

func set_custom_time(t):
	$Asteroid.material.set_shader_parameter("rotation", t * PI * 2.0)

func set_dither(d):
	$Asteroid.material.set_shader_parameter("should_dither", d)

func get_dither():
	return $Asteroid.material.get_shader_parameter("should_dither")

func get_colors():
	return get_colors_from_shader($Asteroid.material)

func set_colors(colors):
	set_colors_on_shader($Asteroid.material, colors)

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
	var hue_base = randf()
	var saturation = randf_range(0.3, 0.7)
	
	var stops = []
	for i in range(num_stops):
		var hue = fmod(hue_base + float(i) / float(num_stops) * 0.2, 1.0)
		var sat = saturation * randf_range(0.8, 1.0)
		var val = randf_range(0.2, 0.9)
		stops.append(Color.from_hsv(hue, sat, val))
	
	var gradient = generate_multi_gradient(stops, 32)
	set_colors(gradient)