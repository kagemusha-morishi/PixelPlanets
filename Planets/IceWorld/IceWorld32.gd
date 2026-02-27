extends "res://Planets/Planet.gd"

func set_pixels(amount):
	$Land.material.set_shader_parameter("pixels", amount)
	$Lakes.material.set_shader_parameter("pixels", amount)
	$Clouds.material.set_shader_parameter("pixels", amount)
	
	$Land.size = Vector2(amount, amount)
	$Lakes.size = Vector2(amount, amount)
	$Clouds.size = Vector2(amount, amount)

func set_light(pos):
	$Land.material.set_shader_parameter("light_origin", pos)
	$Lakes.material.set_shader_parameter("light_origin", pos)
	$Clouds.material.set_shader_parameter("light_origin", pos)

func set_seed(sd):
	var converted_seed = sd%1000/100.0
	$Land.material.set_shader_parameter("seed", converted_seed)
	$Lakes.material.set_shader_parameter("seed", converted_seed)
	$Clouds.material.set_shader_parameter("seed", converted_seed)

func set_rotates(r):
	$Land.material.set_shader_parameter("rotation", r)
	$Lakes.material.set_shader_parameter("rotation", r)
	$Clouds.material.set_shader_parameter("rotation", r)

func update_time(t):
	$Land.material.set_shader_parameter("time", t * get_multiplier($Land.material) * 0.02)
	$Lakes.material.set_shader_parameter("time", t * get_multiplier($Lakes.material) * 0.02)
	$Clouds.material.set_shader_parameter("time", t * get_multiplier($Clouds.material) * 0.01)

func set_custom_time(t):
	$Land.material.set_shader_parameter("time", t * get_multiplier($Land.material))
	$Lakes.material.set_shader_parameter("time", t * get_multiplier($Lakes.material))
	$Clouds.material.set_shader_parameter("time", t * get_multiplier($Clouds.material))

func set_dither(d):
	$Land.material.set_shader_parameter("should_dither", d)

func get_dither():
	return $Land.material.get_shader_parameter("should_dither")

func get_colors():
	return get_colors_from_shader($Land.material) + get_colors_from_shader($Lakes.material) + get_colors_from_shader($Clouds.material)

func set_colors(colors):
	set_colors_on_shader($Land.material, colors.slice(0, 32))
	set_colors_on_shader($Lakes.material, colors.slice(32, 64))
	set_colors_on_shader($Clouds.material, colors.slice(64, 96))

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
	var seed_colors = _generate_new_colorscheme(3, randf_range(0.7, 1.0), randf_range(0.45, 0.55))
	
	# Land colors (32) - icy/snowy surface
	var land_stops = []
	for i in range(4):
		var h = fmod(0.55 + float(i) * 0.02, 1.0)  # Blue-cyan tint
		var s = randf_range(0.1, 0.3)
		var v = randf_range(0.7 + float(i) * 0.1, 1.0)
		land_stops.append(Color.from_hsv(h, s, v))
	var land_gradient = generate_multi_gradient(land_stops, 32)
	
	# Lake colors (32) - frozen water
	var lake_stops = []
	for i in range(3):
		var h = fmod(0.55 + float(i) * 0.03, 1.0)
		var s = randf_range(0.3, 0.5)
		var v = randf_range(0.4 + float(i) * 0.2, 0.8)
		lake_stops.append(Color.from_hsv(h, s, v))
	var lake_gradient = generate_multi_gradient(lake_stops, 32)
	
	# Cloud colors (32) - misty clouds
	var cloud_stops = []
	for i in range(4):
		var h = fmod(0.55 + float(i) * 0.01, 1.0)
		var s = randf_range(0.1, 0.3)
		var v = randf_range(0.6 + float(i) * 0.15, 1.0)
		cloud_stops.append(Color.from_hsv(h, s, v))
	var cloud_gradient = generate_multi_gradient(cloud_stops, 32)
	
	set_colors(land_gradient + lake_gradient + cloud_gradient)