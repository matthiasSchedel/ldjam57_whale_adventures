extends CharacterBody2D

# Animation states
enum AnimState {
	SWIMMING,
	ATTACKING
}

# Behavior states
enum BehaviorState {
	IDLE,
	WANDERING,
	PURSUING,
	ATTACKING
}

# Node references
@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var detection_area = $DetectionArea
@onready var direction_timer = $DirectionTimer
@onready var hunger_timer = $HungerTimer
@onready var sound_manager = $SoundManager
@onready var health_bar = $HealthBar
@onready var head_area = $HeadArea
@onready var body_area = $BodyArea

# Movement parameters
@export var swimming_speed: float = 200.0
@export var pursuit_speed: float = 300.0
@export var detection_radius: float = 300.0
@export var min_direction_time: float = 4.0
@export var max_direction_time: float = 10.0
@export var is_hostile: bool = true # Set false for prey fish
@export var min_hunger_time: float = 20.0
@export var max_hunger_time: float = 30.0

# Animation properties
@export var swim_frame_start: int = 0
@export var swim_frame_end: int = 2
@export var attack_frame_start: int = 3
@export var attack_frame_end: int = 5

# State variables
var current_behavior: BehaviorState = BehaviorState.WANDERING
var current_animation: AnimState = AnimState.SWIMMING
var movement_direction: Vector2 = Vector2.RIGHT
var target_velocity: Vector2 = Vector2.ZERO
var player: Node2D = null
var frame_timer: float = 0.0
var current_frame: int = 0
var animation_fps: float = 10.0
var is_hungry: bool = true

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

	# Setup hunger timer
	hunger_timer = Timer.new()
	add_child(hunger_timer)
	hunger_timer.wait_time = randf_range(min_hunger_time, max_hunger_time)
	hunger_timer.connect("timeout", _on_hunger_timer_timeout)
	hunger_timer.start()

	# Connect detection area signals
	detection_area.connect("body_entered", _on_detection_area_entered)
	detection_area.connect("body_exited", _on_detection_area_exited)

	# Setup damage zones
	_setup_damage_zones()

func _setup_damage_zones():
	# Setup head hitbox (protected area)
	var head_shape = CollisionShape2D.new()
	var head_circle = CircleShape2D.new()
	head_circle.radius = 20 # Adjust based on sprite size
	head_shape.shape = head_circle
	head_shape.position = Vector2(30 if !sprite.flip_h else -30, 0) # Adjust based on sprite
	head_area.add_child(head_shape)
	head_area.collision_layer = 4 # Enemy protected layer
	head_area.collision_mask = 2 # Player attack layer

	# Setup body hitbox (vulnerable area)
	var body_shape = CollisionShape2D.new()
	var body_box = RectangleShape2D.new()
	body_box.size = Vector2(40, 60) # Adjust based on sprite
	body_shape.shape = body_box
	body_shape.position = Vector2(-10 if !sprite.flip_h else 10, 0) # Adjust based on sprite
	body_area.add_child(body_shape)
	body_area.collision_layer = 8 # Enemy vulnerable layer
	body_area.collision_mask = 2 # Player attack layer

func _physics_process(delta):
	match current_behavior:
		BehaviorState.WANDERING:
			_handle_wandering(delta)
		BehaviorState.PURSUING:
			_handle_pursuing(delta)
		BehaviorState.ATTACKING:
			_handle_attacking(delta)

	# Update animation
	_update_animation(delta)

	# Update collision shapes based on direction
	_update_collision_shapes()

func _handle_wandering(_delta):
	velocity = movement_direction * swimming_speed
	move_and_slide()
	current_animation = AnimState.SWIMMING

func _handle_pursuing(_delta):
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * pursuit_speed
		move_and_slide()
		movement_direction = direction
		current_animation = AnimState.SWIMMING

		# Check if close enough to attack and is hungry
		if is_hostile and is_hungry and global_position.distance_to(player.global_position) < 50:
			current_behavior = BehaviorState.ATTACKING
			print("[DEBUG] Enemy fish starting attack - Distance: ", global_position.distance_to(player.global_position))

func _handle_attacking(_delta):
	if player:
		current_animation = AnimState.ATTACKING
		velocity = Vector2.ZERO
		move_and_slide()

		# Apply damage when in attack frame
		if current_frame >= attack_frame_start and current_frame <= attack_frame_end:
			if player.has_method("take_damage"):
				if player.name == "Player":
					player.take_damage(10)
					print("[DEBUG] Enemy fish dealt damage to player")
				elif player.is_in_group("food"):
					player.take_damage(100) # Instant kill small fish
					print("[DEBUG] Enemy fish ate small fish")

		# Reset to pursuing after attack animation
		if current_frame >= attack_frame_end:
			current_behavior = BehaviorState.PURSUING

func _update_animation(_delta):
	frame_timer += _delta
	if frame_timer >= 1.0 / animation_fps:
		frame_timer = 0.0

		match current_animation:
			AnimState.SWIMMING:
				current_frame = (current_frame + 1) % (swim_frame_end - swim_frame_start + 1) + swim_frame_start
			AnimState.ATTACKING:
				current_frame = (current_frame + 1) % (attack_frame_end - attack_frame_start + 1) + attack_frame_start

		sprite.frame = current_frame

	# Update sprite direction
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0

func _update_collision_shapes():
	# Update head area position based on direction
	var head_shape = head_area.get_child(0) as CollisionShape2D
	if head_shape:
		head_shape.position.x = 30 if !sprite.flip_h else -30

	# Update body area position based on direction
	var body_shape = body_area.get_child(0) as CollisionShape2D
	if body_shape:
		body_shape.position.x = -10 if !sprite.flip_h else 10

func _on_direction_timer_timeout():
	if current_behavior == BehaviorState.WANDERING:
		# Choose a random direction
		var angle = randf_range(0, 2 * PI)
		movement_direction = Vector2(cos(angle), sin(angle))

	# Set new random timer duration
	direction_timer.wait_time = randf_range(min_direction_time, max_direction_time)
	direction_timer.start()

func _on_hunger_timer_timeout():
	if player and global_position.distance_to(player.global_position) > detection_radius:
		is_hungry = !is_hungry
		print("[DEBUG] Enemy fish hunger state changed to: ", is_hungry)
		if !is_hungry and current_behavior == BehaviorState.PURSUING:
			current_behavior = BehaviorState.WANDERING
			player = null

	# Set new random timer duration
	hunger_timer.wait_time = randf_range(min_hunger_time, max_hunger_time)
	hunger_timer.start()

func _on_detection_area_entered(body):
	print("[DEBUG] Entity entered detection area: ", body.name)
	if body.name == "Player":
		player = body
		if is_hostile and is_hungry:
			current_behavior = BehaviorState.PURSUING
			print("[DEBUG] Enemy fish pursuing player - Hunger state: ", is_hungry)
	elif body.is_in_group("food") and is_hostile:
		player = body
		current_behavior = BehaviorState.PURSUING
		print("[DEBUG] Enemy fish pursuing food")

func _on_detection_area_exited(body):
	print("[DEBUG] Entity exited detection area: ", body.name)
	if body == player:
		player = null
		current_behavior = BehaviorState.WANDERING

func take_damage(amount: float):
	# Only take damage if hit in vulnerable areas (not the head)
	if !head_area.get_overlapping_bodies().size() > 0 and body_area.get_overlapping_bodies().size() > 0:
		health_bar.take_damage(amount)
		if health_bar.current_health <= 0:
			if sound_manager:
				sound_manager.play_sound("enemy_die")
			queue_free()
