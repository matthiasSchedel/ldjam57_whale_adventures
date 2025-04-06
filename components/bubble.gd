extends Node2D

var sprite: Sprite2D
var speed = Vector2(0, -50) # Bubbles float upward
var random_x_movement = 0.0
var lifetime = 3.0 # Bubble exists for 3 seconds

func _ready():
	# Get the sprite node
	sprite = get_node("Sprite2D")
	if !sprite:
		push_error("Bubble sprite not found!")
		queue_free()
		return
	
	# Add some random horizontal movement
	random_x_movement = randf_range(-20, 20)
	speed.x = random_x_movement
	
	# Setup lifetime timer
	var timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.connect("timeout", queue_free)
	add_child(timer)
	timer.start()

func _process(delta):
	# Move the bubble
	position += speed * delta
	
	# Optional: Add some wobble
	position.x += sin(Time.get_ticks_msec() * 0.005) * 0.5
