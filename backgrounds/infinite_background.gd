extends ParallaxBackground

@onready var camera = get_node("/root/Main/Player/Camera2D")
@onready var far_layer = $FarLayer/Background
@onready var mid_layer = $MidLayer/Background
@onready var near_layer = $NearLayer/Background
var scroll_speed = Vector2(0.1, 0.1)
var last_camera_pos = Vector2.ZERO
var max_depth = 5000.0 # Maximum depth in pixels

func _ready():
	if camera:
		last_camera_pos = camera.get_screen_center_position()

	# Load and set up the shader
	var shader = load("res://backgrounds/background_gradient.gdshader")

	# Apply shader to all layers
	for bg_layer in [far_layer, mid_layer, near_layer]:
		if bg_layer and bg_layer.material == null:
			bg_layer.material = ShaderMaterial.new()
			bg_layer.material.shader = shader

func _process(_delta):
	if camera:
		var camera_pos = camera.get_screen_center_position()
		var camera_offset = camera_pos - last_camera_pos
		scroll_offset += camera_offset * scroll_speed
		last_camera_pos = camera_pos

		# Update shader depth value based on camera Y position
		var depth = clamp(camera_pos.y / max_depth, 0.0, 1.0)
		for bg_layer in [far_layer, mid_layer, near_layer]:
			if bg_layer and bg_layer.material:
				bg_layer.material.set_shader_parameter("depth", depth)

		# Ensure the background tiles seamlessly
		var viewport_size = get_viewport().get_visible_rect().size
		if abs(scroll_offset.x) >= viewport_size.x:
			scroll_offset.x = fmod(scroll_offset.x, viewport_size.x)
		if abs(scroll_offset.y) >= viewport_size.y:
			scroll_offset.y = fmod(scroll_offset.y, viewport_size.y)
