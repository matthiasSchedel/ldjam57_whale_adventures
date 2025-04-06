extends CharacterBody2D

# Animation states
enum AnimState {
	IDLE,
	SWIMMING,
	ATTACKING
}

# Node references
@onready var sprite = $Sprite2D
@onready var detection_area = $DetectionArea
@onready var direction_timer = $DirectionTimer
@onready var health_bar = $HealthBar
@onready var sound_manager = $SoundManager
@onready var head_area = $HeadArea
@onready var tentacle_area = $TentacleArea

# Movement parameters
@export var swimming_speed: float = 150.0
@export var pursuit_speed: float = 200.0
@export var detection_radius: float = 400.0
@export var min_direction_time: float = 3.0
@export var max_direction_time: float = 8.0
@export var min_depth: float = 800.0 # Minimum depth where squids can spawn

# Animation properties
@export var idle_frame: int = 0
@export var swim_frame_start: int = 0
@export var swim_frame_end: int = 2
@export var attack_frame: int = 2

# State variables
var current_animation: AnimState = AnimState.IDLE
var movement_direction: Vector2 = Vector2.RIGHT
var player: Node2D = null
var frame_timer: float = 0.0
var current_frame: int = 0
var animation_fps: float = 8.0
var attack_cooldown: float = 2.0
var attack_timer: float = 0.0

func _ready():
	# Set motion mode to floating (kinematic)
	motion_mode = MOTION_MODE_FLOATING

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
	health_bar.current_health = 150
	health_bar.max_health = 150

	# Setup damage zones
	_setup_damage_zones()

func _setup_damage_zones():
	# Setup head hitbox (vulnerable area)
	var head_shape = CollisionShape2D.new()
	var head_circle = CircleShape2D.new()
	head_circle.radius = 30 # Adjust based on sprite size
	head_shape.shape = head_circle
	head_shape.position = Vector2(0, -40) # Adjust based on sprite
	head_area.add_child(head_shape)
	head_area.collision_layer = 4 # Enemy vulnerable layer
	head_area.collision_mask = 2 # Player attack layer

	# Setup tentacle hitbox (damage dealing area)
	var tentacle_shape = CollisionShape2D.new()
	var tentacle_box = RectangleShape2D.new()
	tentacle_box.size = Vector2(80, 60) # Adjust based on sprite
	tentacle_shape.shape = tentacle_box
	tentacle_shape.position = Vector2(0, 20) # Adjust based on sprite
	tentacle_area.add_child(tentacle_shape)
	tentacle_area.collision_layer = 8 # Enemy attack layer
	tentacle_area.collision_mask = 1 # Player layer

func _physics_process(delta):
	attack_timer = max(0, attack_timer - delta)

	if player and global_position.y >= min_depth:
		# Move towards player
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * pursuit_speed
		movement_direction = direction

		# Attack if close enough and cooldown is ready
		if global_position.distance_to(player.global_position) < 100 and attack_timer <= 0:
			current_animation = AnimState.ATTACKING
			attack_timer = attack_cooldown
			# Damage is now handled through area collision
		else:
			current_animation = AnimState.SWIMMING
	else:
		# Normal swimming
		velocity = movement_direction * swimming_speed
		current_animation = AnimState.SWIMMING if velocity.length() > 0 else AnimState.IDLE

	# Update animation
	_update_animation(delta)

	# Apply movement
	move_and_slide()

func _update_animation(_delta):
	frame_timer += _delta
	if frame_timer >= 1.0 / animation_fps:
		frame_timer = 0.0

		match current_animation:
			AnimState.IDLE:
				current_frame = idle_frame
			AnimState.SWIMMING:
				current_frame = (current_frame + 1) % (swim_frame_end - swim_frame_start + 1) + swim_frame_start
			AnimState.ATTACKING:
				current_frame = attack_frame

		sprite.frame = current_frame

func _on_direction_timer_timeout():
	if !player: # Only change direction if not pursuing
		# Choose a random direction
		var angle = randf_range(0, 2 * PI)
		movement_direction = Vector2(cos(angle), sin(angle))

	# Set new random timer duration
	direction_timer.wait_time = randf_range(min_direction_time, max_direction_time)
	direction_timer.start()

func _on_detection_area_entered(body):
	if body.name == "Player" and global_position.y >= min_depth:
		player = body

func _on_detection_area_exited(body):
	if body.name == "Player":
		player = null

func take_damage(amount: float):
	# Only take damage if hit in the head area
	if head_area.get_overlapping_bodies().size() > 0:
		health_bar.take_damage(amount)
		if health_bar.current_health <= 0:
			if sound_manager:
				sound_manager.play_sound("enemy_die")
			queue_free()

func _on_tentacle_area_body_entered(body):
	if body.name == "Player" and body.has_method("take_damage"):
		body.take_damage(15)
		print("[DEBUG] Squid dealt damage to player through tentacles")
