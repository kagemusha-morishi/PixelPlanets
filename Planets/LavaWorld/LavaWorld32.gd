extends "res://Planets/Planet.gd"

func set_pixels(amount):
	$Land.material.set_shader_parameter("pixels", amount)
	$Craters.material.set_shader_parameter("pixels", amount)
	$LavaRivers.material.set_shader_parameter("pixels", amount)
	
	$Land.size = Vector2(amount, amount)
	$Craters.size = Vector2(amount, amount)
	$LavaRivers.size = Vector2(amount, amount)
	
func set_light(pos):
	$Land.material.set_shader_parameter("light_origin", pos)
	$Craters.material.set_shader_parameter("light_origin", pos)
	$LavaRivers.material.set_shader_parameter("light_origin", pos)

func set_seed(sd):
	var converted_seed = sd%1000/100.0
	$Land.material.set_shader_parameter("seed", converted_seed)
	$Craters.material.set_shader_parameter("seed", converted_seed)
	$LavaRivers.material.set_shader_parameter("seed", converted_seed)

func set_rotates(r):
	$Land.material.set_shader_parameter("rotation", r)
	$Craters.material.set_shader_parameter("rotation", r)
	$LavaRivers.material.set_shader_parameter("rotation", r)

func update_time(t):	
	$Land.material.set_shader_parameter("time", t * get_multiplier($Land.material) * 0.02)
	$Craters.material.set_shader_parameter("time", t * get_multiplier($Craters.material) * 0.02)
	$LavaRivers.material.set_shader_parameter("time", t * get_multiplier($LavaRivers.material) * 0.02)

func set_custom_time(t):
	$Land.material.set_shader_parameter("time", t * get_multiplier($Land.material))
	$Craters.material.set_shader_parameter("time", t * get_multiplier($Craters.material))
	$LavaRivers.material.set_shader_parameter("time", t * get_multiplier($LavaRivers.material))

func set_dither(d):
	$Land.material.set_shader_parameter("should_dither", d)

func get_dither():
	return $Land.material.get_shader_parameter("should_dither")

func get_colors():
	return get_colors_from_shader($Land.material) + get_colors_from_shader($Craters.material) + get_colors_from_shader($LavaRivers.material)

func set_colors(colors):
	set_colors_on_shader($Land.material, colors.slice(0, 32))
	set_colors_on_shader($Craters.material, colors.slice(32, 64))
	set_colors_on_shader($LavaRivers.material, colors.slice(64, 96))

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
	var seed_colors = _generate_new_colorscheme(3, randf_range(0.6, 1.0), randf_range(0.7, 0.8))
	
	# Land colors (32) - rocky mars-like
	var land_stops = []
	for i in range(4):
		var h = fmod(seed_colors[0].h + float(i) * 0.02, 1.0)
		var s = randf_range(0.5, 0.8)
		var v = randf_range(0.3 + float(i) * 0.2, 0.9)
		land_stops.append(Color.from_hsv(h, s, v))
	var land_gradient = generate_multi_gradient(land_stops, 32)
	
	# Crater colors (32) - darker variation
	var crater_stops = []
	for i in range(3):
		var h = fmod(seed_colors[1].h, 1.0)
		var s = randf_range(0.4, 0.7)
		var v = randf_range(0.2 + float(i) * 0.15, 0.6)
		crater_stops.append(Color.from_hsv(h, s, v))
	var crater_gradient = generate_multi_gradient(crater_stops, 32)
	
	# Lava colors (32) - orange to red gradient
	var lava_stops = []
	for i in range(4):
		var h = fmod(0.05 + float(i) * 0.02, 1.0)
		var s = randf_range(0.7, 1.0)
		var v = randf_range(0.5 + float(i) * 0.15, 1.0)
		lava_stops.append(Color.from_hsv(h, s, v))
	var lava_gradient = generate_multi_gradient(lava_stops, 32)
	
	set_colors(land_gradient + crater_gradient + lava_gradient)