# Player movement script (attach to player scene)
extends CharacterBody2D

var speed = 200
var size = 1
var oxygen = 100
var max_oxygen = 100

func _physics_process(delta):
	# Get input direction
	var direction = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	).normalized()

	# Apply movement and handle depth effects
	var depth_factor = get_depth_factor()
	velocity = direction * speed * depth_factor
	move_and_slide()

	# Update oxygen based on depth
	deplete_oxygen(delta)

func get_depth_factor():
	# Slow down in deeper water (based on Y position)
	var depth = position.y / 600.0  # Adjust based on your world size
	return max(0.5, 1.0 - depth * 0.5)

func deplete_oxygen(delta):
	# Oxygen depletes faster at greater depths
	var depth = position.y / 600.0
	oxygen -= delta * (1 + depth * 2)
