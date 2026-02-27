extends "res://Planets/Planet.gd"

func set_pixels(amount):	
	$Water.material.set_shader_parameter("pixels", amount)
	$Land.material.set_shader_parameter("pixels", amount)
	$Cloud.material.set_shader_parameter("pixels", amount)
	
	$Water.size = Vector2(amount, amount)
	$Land.size = Vector2(amount, amount)
	$Cloud.size = Vector2(amount, amount)

func set_light(pos):
	$Cloud.material.set_shader_parameter("light_origin", pos)
	$Water.material.set_shader_parameter("light_origin", pos)
	$Land.material.set_shader_parameter("light_origin", pos)

func set_seed(sd):
	var converted_seed = sd%1000/100.0
	$Cloud.material.set_shader_parameter("seed", converted_seed)
	$Water.material.set_shader_parameter("seed", converted_seed)
	$Land.material.set_shader_parameter("seed", converted_seed)
	$Cloud.material.set_shader_parameter("cloud_cover", randf_range(0.35, 0.6))

func set_rotates(r):
	$Cloud.material.set_shader_parameter("rotation", r)
	$Water.material.set_shader_parameter("rotation", r)
	$Land.material.set_shader_parameter("rotation", r)

func update_time(t):
	$Cloud.material.set_shader_parameter("time", t * get_multiplier($Cloud.material) * 0.01)
	$Water.material.set_shader_parameter("time", t * get_multiplier($Water.material) * 0.02)
	$Land.material.set_shader_parameter("time", t * get_multiplier($Land.material) * 0.02)

func set_custom_time(t):
	$Cloud.material.set_shader_parameter("time", t * get_multiplier($Cloud.material))
	$Water.material.set_shader_parameter("time", t * get_multiplier($Water.material))
	$Land.material.set_shader_parameter("time", t * get_multiplier($Land.material))

func set_dither(d):
	$Water.material.set_shader_parameter("should_dither", d)

func get_dither():
	return $Water.material.get_shader_parameter("should_dither")

func get_colors():
	return get_colors_from_shader($Water.material) + get_colors_from_shader($Land.material) + get_colors_from_shader($Cloud.material)

func set_colors(colors):
	set_colors_on_shader($Water.material, colors.slice(0, 32))
	set_colors_on_shader($Land.material, colors.slice(32, 64))
	set_colors_on_shader($Cloud.material, colors.slice(64, 96))

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
	
	# Water colors (32) - ocean depths
	var water_stops = []
	for i in range(4):
		var h = fmod(0.55 + float(i) * 0.03, 1.0)  # Blue range
		var s = randf_range(0.5, 0.8)
		var v = randf_range(0.3 + float(i) * 0.2, 0.9)
		water_stops.append(Color.from_hsv(h, s, v))
	var water_gradient = generate_multi_gradient(water_stops, 32)
	
	# Land colors (32) - landmasses
	var land_stops = []
	for i in range(4):
		var h = fmod(seed_colors[0].h + float(i) * 0.02, 1.0)
		var s = randf_range(0.4, 0.7)
		var v = randf_range(0.3 + float(i) * 0.15, 0.8)
		land_stops.append(Color.from_hsv(h, s, v))
	var land_gradient = generate_multi_gradient(land_stops, 32)
	
	# Cloud colors (32)
	var cloud_stops = []
	for i in range(4):
		var h = fmod(seed_colors[2].h + float(i) * 0.01, 1.0)
		var s = randf_range(0.1, 0.4)
		var v = randf_range(0.6 + float(i) * 0.15, 1.0)
		cloud_stops.append(Color.from_hsv(h, s, v))
	var cloud_gradient = generate_multi_gradient(cloud_stops, 32)
	
	set_colors(water_gradient + land_gradient + cloud_gradient)