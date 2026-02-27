extends "res://Planets/Planet.gd"

var relative_scale = 2.0
var gui_zoom = 2.0

func set_pixels(amount):
	$Blobs.material.set_shader_parameter("pixels", amount*relative_scale)
	$Star.material.set_shader_parameter("pixels", amount)
	$StarFlares.material.set_shader_parameter("pixels", amount*relative_scale)

	$Star.size = Vector2(amount, amount)
	$StarFlares.size = Vector2(amount, amount)*relative_scale
	$Blobs.size = Vector2(amount, amount)*relative_scale

	$StarFlares.position = Vector2(-amount, -amount) * 0.5
	$Blobs.position = Vector2(-amount, -amount) * 0.5

func set_light(_pos):
	pass

func set_seed(sd):
	var converted_seed = sd%1000/100.0
	$Blobs.material.set_shader_parameter("seed", converted_seed)
	$Star.material.set_shader_parameter("seed", converted_seed)
	$StarFlares.material.set_shader_parameter("seed", converted_seed)

func set_rotates(r):
	$Blobs.material.set_shader_parameter("rotation", r)
	$Star.material.set_shader_parameter("rotation", r)
	$StarFlares.material.set_shader_parameter("rotation", r)

func update_time(t):
	$Blobs.material.set_shader_parameter("time", t * get_multiplier($Blobs.material) * 0.01)
	$Star.material.set_shader_parameter("time", t * get_multiplier($Star.material) * 0.005)
	$StarFlares.material.set_shader_parameter("time", t * get_multiplier($StarFlares.material) * 0.015)

func set_custom_time(t):
	$Blobs.material.set_shader_parameter("time", t * get_multiplier($Blobs.material))
	$Star.material.set_shader_parameter("time", t * (1.0 / $Star.material.get_shader_parameter("time_speed")))
	$StarFlares.material.set_shader_parameter("time", t * get_multiplier($StarFlares.material))

func set_dither(d):
	$Star.material.set_shader_parameter("should_dither", d)
	$StarFlares.material.set_shader_parameter("should_dither", d)

func get_dither():
	return $Star.material.get_shader_parameter("should_dither")

func get_colors():
	return get_colors_from_shader($Blobs.material) + get_colors_from_shader($Star.material) + get_colors_from_shader($StarFlares.material)

func set_colors(colors):
	set_colors_on_shader($Blobs.material, colors.slice(0, 1))
	set_colors_on_shader($Star.material, colors.slice(1, 33))
	set_colors_on_shader($StarFlares.material, colors.slice(33, 65))

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
	# Blobs - single bright color (1 color)
	var blob_color = Color.from_hsv(randf_range(0.08, 0.15), randf_range(0.7, 1.0), randf_range(0.9, 1.0))
	
	# Star surface - 32 colors, warm gradient
	var num_star_stops = randi() % 4 + 3
	var star_hue = randf_range(0.0, 0.15)
	var star_stops = []
	for i in range(num_star_stops):
		var h = fmod(star_hue + float(i) / float(num_star_stops) * 0.1, 1.0)
		var s = randf_range(0.6, 1.0)
		var v = randf_range(0.4 + float(i) / float(num_star_stops) * 0.6, 1.0)
		star_stops.append(Color.from_hsv(h, s, v))
	var star_gradient = generate_multi_gradient(star_stops, 32)
	
	# Flares - 32 colors, bright to edge
	var flare_hue = star_hue + 0.05
	var flare_stops = []
	for i in range(randi() % 3 + 2):
		var h = fmod(flare_hue + float(i) * 0.02, 1.0)
		var s = randf_range(0.5, 0.9)
		var v = randf_range(0.7 + float(i) * 0.15, 1.0)
		flare_stops.append(Color.from_hsv(h, s, v))
	var flare_gradient = generate_multi_gradient(flare_stops, 32)
	
	set_colors([blob_color] + star_gradient + flare_gradient)