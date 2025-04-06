extends Node2D

@onready var sprite = $Sprite2D

var speed = 50.0
var lifetime = 3.0
var elapsed_time = 0.0
var horizontal_movement = 0.0

func _ready():
	# Add random horizontal movement
	horizontal_movement = randf_range(-20.0, 20.0)
	
	# Randomize initial scale slightly
	var random_scale = randf_range(0.8, 1.2)
	scale *= random_scale

func _process(delta):
	# Move upward with slight horizontal drift
	position.y -= speed * delta
	position.x += horizontal_movement * delta
	
	# Update lifetime
	elapsed_time += delta
	if elapsed_time >= lifetime:
		queue_free()
	
	# Fade out near end of lifetime
	var fade_start = lifetime * 0.7
	if elapsed_time > fade_start:
		var alpha = 1.0 - (elapsed_time - fade_start) / (lifetime - fade_start)
		modulate.a = alpha