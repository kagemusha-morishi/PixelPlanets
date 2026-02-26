extends "res://Planets/Planet.gd"

func set_pixels(amount):
	$BlackHole.material.set_shader_parameter("pixels", amount)
	$Disk.material.set_shader_parameter("pixels", amount*3.0)
	$BlackHole.size = Vector2(amount, amount)
	$Disk.position = Vector2(-amount, -amount)
	$Disk.size = Vector2(amount, amount)*3.0

func set_light(_pos):
	pass

func set_seed(sd):
	var converted_seed = sd%1000/100.0
	$Disk.material.set_shader_parameter("seed", converted_seed)

func set_rotates(r):
	$Disk.material.set_shader_parameter("rotation", r+0.7)

func update_time(t):
	$Disk.material.set_shader_parameter("time", t * 314.15 * 0.004)

func set_custom_time(t):
	$Disk.material.set_shader_parameter("time", t * 314.15 * $Disk.material.get_shader_parameter("time_speed") * 0.5)

func set_dither(d):
	$Disk.material.set_shader_parameter("should_dither", d)

func get_dither():
	return $Disk.material.get_shader_parameter("should_dither")

func get_colors():
	return get_colors_from_shader($BlackHole.material) + get_colors_from_shader($Disk.material)

func set_colors(colors):
	set_colors_on_shader($BlackHole.material, colors.slice(0, 32))
	set_colors_on_shader($Disk.material, colors.slice(32, 64))

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
	# Black hole center - dark gradient
	var hole_stops = [Color("000000"), Color("1a1a2e"), Color("16213e")]
	var hole_gradient = generate_multi_gradient(hole_stops, 32)
	
	# Accretion disk - bright energetic colors
	var num_stops = randi() % 4 + 4
	var hue_base = randf_range(0.0, 0.15) # Orange to red range, or purple
	var disk_stops = []
	for i in range(num_stops):
		var hue = fmod(hue_base + float(i) / float(num_stops) * 0.1, 1.0)
		var sat = randf_range(0.6, 1.0)
		var val = randf_range(0.3, 1.0)
		disk_stops.append(Color.from_hsv(hue, sat, val))
	var disk_gradient = generate_multi_gradient(disk_stops, 32)
	
	set_colors(hole_gradient + disk_gradient)