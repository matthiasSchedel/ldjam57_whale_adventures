extends CharacterBody2D

# Animation states
enum AnimState {
	SWIMMING,
	FLEEING
}

# Node references
@onready var sprite = $Sprite2D
@onready var detection_area = $DetectionArea
@onready var direction_timer = $DirectionTimer
@onready var health_bar = $HealthBar

# Movement parameters
@export var swimming_speed: float = 100.0
@export var flee_speed: float = 250.0
@export var detection_radius: float = 300.0
@export var min_direction_time: float = 2.0
@export var max_direction_time: float = 5.0

# Animation properties
@export var swim_frame_start: int = 0
@export var swim_frame_end: int = 2

# State variables
var current_animation: AnimState = AnimState.SWIMMING
var movement_direction: Vector2 = Vector2.RIGHT
var player_ref: Node2D = null
var frame_timer: float = 0.0
var current_frame: int = 0
var animation_fps: float = 5.0

func _ready():
	# Initialize detection area
	var collision_shape = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = detection_radius
	collision_shape.shape = circle_shape
	detection_area.add_child(collision_shape)

	# Setup direction change timer
	direction_timer.wait_time = randf_range(min_direction_time, max_direction_time)
	direction_timer.connect("timeout", _on_direction_timer_timeout)
	direction_timer.start()

	# Connect detection area signals
	detection_area.connect("body_entered", _on_detection_area_entered)
	detection_area.connect("body_exited", _on_detection_area_exited)

	# Initialize health
	health_bar.current_health = 50
	health_bar.max_health = 50
	print("[SmallFish] Initialized with health:", health_bar.current_health)

func set_initial_direction(direction: Vector2) -> void:
	movement_direction = direction.normalized()
	direction_timer.wait_time = randf_range(min_direction_time, max_direction_time)
	print("[SmallFish] Set initial direction:", movement_direction)

func _physics_process(delta: float):
	if player_ref:
		# Flee from player
		var flee_direction = (global_position - player_ref.global_position).normalized()
		velocity = flee_direction * flee_speed
		movement_direction = flee_direction
		current_animation = AnimState.FLEEING
	else:
		# Normal swimming
		velocity = movement_direction * swimming_speed
		current_animation = AnimState.SWIMMING

	# Update animation
	_update_animation(delta)

	# Apply movement
	move_and_slide()


func _update_animation(delta: float):
	frame_timer += delta
	if frame_timer >= 1.0 / animation_fps:
		frame_timer = 0.0
		current_frame = swim_frame_start + ((current_frame + 1 - swim_frame_start) % (swim_frame_end - swim_frame_start + 1))
		sprite.frame = current_frame

	# Update sprite direction
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0

func _on_direction_timer_timeout():
	if !player_ref: # Only change direction if not fleeing
		# Choose a random direction
		var angle = randf_range(0, 2 * PI)
		movement_direction = Vector2(cos(angle), sin(angle))
		print("[SmallFish] Changed direction to:", movement_direction)

	# Set new random timer duration
	direction_timer.wait_time = randf_range(min_direction_time, max_direction_time)
	direction_timer.start()

func _on_detection_area_entered(body: Node2D):
	if body.name == "Player":
		print("[SmallFish] Player entered detection area")
		player_ref = body

func _on_detection_area_exited(body: Node2D):
	if body.name == "Player":
		print("[SmallFish] Player exited detection area")
		player_ref = null

func take_damage(amount: float):
	print("[SmallFish] Taking damage:", amount, " Current health:", health_bar.current_health)
	health_bar.take_damage(amount)
	if health_bar.current_health <= 0:
		print("[SmallFish] Died from damage")
		queue_free()
