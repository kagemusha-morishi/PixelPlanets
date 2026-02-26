extends "res://Planets/Planet.gd"

# GasPlanet with 32-color gradient support
# Each layer uses 32 colors for smooth gradient transitions

func set_pixels(amount):
	$Cloud.material.set_shader_parameter("pixels", amount)
	$Cloud2.material.set_shader_parameter("pixels", amount)
	$Cloud.size = Vector2(amount, amount)
	$Cloud2.size = Vector2(amount, amount)

func set_light(pos):
	$Cloud.material.set_shader_parameter("light_origin", pos)
	$Cloud2.material.set_shader_parameter("light_origin", pos)

func set_seed(sd):
	var converted_seed = sd%1000/100.0
	$Cloud.material.set_shader_parameter("seed", converted_seed)
	$Cloud2.material.set_shader_parameter("seed", converted_seed)
	$Cloud2.material.set_shader_parameter("cloud_cover", randf_range(0.28, 0.5))

func set_rotates(r):
	$Cloud.material.set_shader_parameter("rotation", r)
	$Cloud2.material.set_shader_parameter("rotation", r)
	
func update_time(t):
	$Cloud.material.set_shader_parameter("time", t * get_multiplier($Cloud.material) * 0.005)
	$Cloud2.material.set_shader_parameter("time", t * get_multiplier($Cloud2.material) * 0.005)
	
func set_custom_time(t):
	$Cloud.material.set_shader_parameter("time", t * get_multiplier($Cloud.material))
	$Cloud2.material.set_shader_parameter("time", t * get_multiplier($Cloud2.material))

func get_colors():
	return get_colors_from_shader($Cloud.material) + get_colors_from_shader($Cloud2.material)

func set_colors(colors):
	# Each layer gets 32 colors for gradient
	set_colors_on_shader($Cloud.material, colors.slice(0, 32))
	set_colors_on_shader($Cloud2.material, colors.slice(32, 64))

# Generate a smooth gradient palette
static func generate_gradient(color1: Color, color2: Color, steps: int) -> Array:
	var gradient = []
	for i in range(steps):
		var t = float(i) / float(steps - 1)
		gradient.append(color1.lerp(color2, t))
	return gradient

# Generate a multi-stop gradient from array of colors
static func generate_multi_gradient(stops: Array, total_steps: int) -> Array:
	if stops.size() < 2:
		return []
	
	var gradient = []
	var steps_per_segment = total_steps / (stops.size() - 1)
	
	for i in range(stops.size() - 1):
		var segment = generate_gradient(stops[i], stops[i + 1], steps_per_segment)
		gradient.append_array(segment)
	
	# Ensure we have exactly total_steps colors
	while gradient.size() > total_steps:
		gradient.pop_back()
	while gradient.size() < total_steps:
		gradient.append(gradient.back())
	
	return gradient

func randomize_colors():
	# Generate random gradient stops
	var num_stops = randi() % 4 + 3  # 3-6 color stops for variety
	
	var hue_base = randf()
	var saturation = randf_range(0.5, 1.0)
	
	var stops1 = []
	var stops2 = []
	
	for i in range(num_stops):
		var hue = fmod(hue_base + float(i) / float(num_stops) * 0.3, 1.0)
		var sat = saturation * randf_range(0.7, 1.0)
		var val = randf_range(0.3, 1.0)
		stops1.append(Color.from_hsv(hue, sat, val))
	
	# Second layer with different but harmonious colors
	var hue_base2 = fmod(hue_base + 0.5, 1.0)  # Complementary-ish
	for i in range(num_stops):
		var hue = fmod(hue_base2 + float(i) / float(num_stops) * 0.3, 1.0)
		var sat = saturation * randf_range(0.7, 1.0)
		var val = randf_range(0.2, 0.8)
		stops2.append(Color.from_hsv(hue, sat, val))
	
	# Generate 32-color gradients
	var gradient1 = generate_multi_gradient(stops1, 32)
	var gradient2 = generate_multi_gradient(stops2, 32)
	
	set_colors(gradient1 + gradient2)