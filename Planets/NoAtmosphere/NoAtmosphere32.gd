extends "res://Planets/Planet.gd"

func set_pixels(amount):
	$Ground.material.set_shader_parameter("pixels", amount)
	$Craters.material.set_shader_parameter("pixels", amount)
	$Ground.size = Vector2(amount, amount)
	$Craters.size = Vector2(amount, amount)

func set_light(pos):
	$Ground.material.set_shader_parameter("light_origin", pos)
	$Craters.material.set_shader_parameter("light_origin", pos)

func set_seed(sd):
	var converted_seed = sd%1000/100.0
	$Ground.material.set_shader_parameter("seed", converted_seed)
	$Craters.material.set_shader_parameter("seed", converted_seed)

func set_rotates(r):
	$Ground.material.set_shader_parameter("rotation", r)
	$Craters.material.set_shader_parameter("rotation", r)

func update_time(_t):
	pass

func set_custom_time(t):
	set_rotates(t * PI * 2.0)

func set_dither(d):
	$Ground.material.set_shader_parameter("should_dither", d)
	$Craters.material.set_shader_parameter("should_dither", d)

func get_dither():
	return $Ground.material.get_shader_parameter("should_dither")

func get_colors():
	return get_colors_from_shader($Ground.material) + get_colors_from_shader($Craters.material)

func set_colors(colors):
	set_colors_on_shader($Ground.material, colors.slice(0, 32))
	set_colors_on_shader($Craters.material, colors.slice(32, 64))

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
	var hue = randf_range(0.0, 0.15) # Gray to brown range
	var ground_stops = []
	for i in range(randi() % 4 + 3):
		var v = randf_range(0.2 + float(i) * 0.1, 0.6)
		ground_stops.append(Color.from_hsv(hue, randf_range(0.0, 0.3), v))
	var ground_gradient = generate_multi_gradient(ground_stops, 32)
	
	var crater_stops = []
	for i in range(randi() % 3 + 2):
		var v = randf_range(0.15, 0.4)
		crater_stops.append(Color.from_hsv(hue, randf_range(0.0, 0.2), v))
	var crater_gradient = generate_multi_gradient(crater_stops, 32)
	
	set_colors(ground_gradient + crater_gradient)