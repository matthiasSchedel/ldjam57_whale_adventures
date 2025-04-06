# Player movement script (attach to player scene)
extends RigidBody2D

signal health_changed(new_health: float)
signal size_changed(new_size: float)

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var sound_manager = $SoundManager
@onready var particle_manager = $ParticleManager
@onready var growth_manager = $GrowthManager

# Preload scenes and resources
var idle_texture = preload("res://assets/images/player/idle.png")
var swimming_texture = preload("res://assets/images/player/swimming.png")
var diving_texture = preload("res://assets/images/player/diving.png")
var bubble_texture = preload("res://assets/images/bubbles.png")

# Base stats
var base_speed = 600
var base_oxygen = 100
var base_health = 100

# Current stats
var speed = base_speed
var oxygen = base_oxygen
var max_oxygen = base_oxygen
var health = base_health
var max_health = base_health

# Movement
var target_velocity = Vector2.ZERO
var current_direction = Vector2.ZERO

# Bubble spawning timers
var idle_bubble_timer: Timer
var moving_bubble_timer: Timer

# Health regeneration
var regen_enabled = true
var regen_rate = 10.0 # Health per second
var regen_delay = 3.0 # Seconds before regeneration starts
var regen_timer = 0.0

func _ready():
	add_to_group("player")
	# Connect growth signals
	growth_manager.connect("food_collected", _on_food_collected)
	growth_manager.connect("growth_level_reached", _on_growth_level_reached)

	# Start with idle sprite and animation
	sprite.texture = idle_texture
	animation_player.play("idle")

	# Setup bubble timers
	_setup_bubble_timers()

	# Connect body detection
	var fish_detector = $FishDetector
	fish_detector.body_entered.connect(_on_body_entered)

func _setup_bubble_timers():
	idle_bubble_timer = Timer.new()
	idle_bubble_timer.name = "IdleBubbleTimer"
	add_child(idle_bubble_timer)

	moving_bubble_timer = Timer.new()
	moving_bubble_timer.name = "MovingBubbleTimer"
	add_child(moving_bubble_timer)

	idle_bubble_timer.wait_time = 2.0
	idle_bubble_timer.connect("timeout", spawn_bubble)
	idle_bubble_timer.start()

	moving_bubble_timer.wait_time = 1.0
	moving_bubble_timer.connect("timeout", spawn_bubble)

func _physics_process(_delta):
	var direction = _get_input_direction()
	_handle_movement(direction, _delta)
	_handle_animation(direction)
	_handle_oxygen(_delta)
	_handle_regeneration(_delta)

func _get_input_direction() -> Vector2:
	return Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	).normalized()

func _handle_movement(direction: Vector2, delta: float) -> void:
	var depth_factor = get_depth_factor()

	# Calculate target velocity
	target_velocity = direction * speed * depth_factor

	# Smoothly interpolate current velocity towards target
	linear_velocity = linear_velocity.lerp(target_velocity, 10.0 * delta)

	# Update current direction for animation
	if direction.length() > 0:
		current_direction = direction

	# Handle sound and bubble effects based on movement
	var is_moving = direction.length() > 0
	sound_manager.set_bubble_volume(is_moving)

	if is_moving:
		if moving_bubble_timer.is_stopped():
			moving_bubble_timer.start()
		regen_timer = 0.0 # Reset regeneration timer when moving
	else:
		moving_bubble_timer.stop()

func _handle_animation(direction: Vector2) -> void:
	if direction.length() > 0:
		if abs(direction.x) > abs(direction.y):
			# Primarily horizontal movement
			sprite.texture = swimming_texture
			sprite.flip_h = direction.x < 0
			sprite.flip_v = false
			animation_player.play("swim")
		else:
			# Primarily vertical movement
			sprite.texture = diving_texture
			sprite.flip_v = direction.y < 0
			if direction.x != 0:
				sprite.flip_h = direction.x < 0
			animation_player.play("dive")
	else:
		sprite.texture = idle_texture
		sprite.flip_v = false
		animation_player.play("idle")

func _handle_oxygen(_delta: float) -> void:
	# Keeping position.y access since it might be used later when oxygen system is re-enabled
	# var depth = position.y / 600.0
	# oxygen = max(0, oxygen - delta * (1 + depth * 2))
	# if oxygen <= 0:
	#	take_damage(delta * 10) # Take damage when out of oxygen
	pass

func _handle_regeneration(delta: float) -> void:
	if !regen_enabled or linear_velocity.length() > 0.1:
		regen_timer = 0.0
		return

	regen_timer += delta
	if regen_timer >= regen_delay:
		heal(regen_rate * delta)

func get_depth_factor() -> float:
	var depth = global_position.y / 600.0
	return max(0.5, 1.0 - depth * 0.5)

func spawn_bubble() -> void:
	var bubble = Node2D.new()
	var bubble_sprite = Sprite2D.new()
	bubble_sprite.name = "Sprite2D"
	bubble_sprite.texture = bubble_texture
	bubble_sprite.hframes = 4
	bubble_sprite.vframes = 2
	bubble_sprite.frame = randi() % (bubble_sprite.hframes * bubble_sprite.vframes)
	bubble_sprite.scale = Vector2(0.333, 0.333)

	bubble.add_child(bubble_sprite)
	bubble.position = _get_bubble_spawn_position()
	bubble.set_script(load("res://scripts/bubble.gd"))
	get_parent().add_child(bubble)

func _get_bubble_spawn_position() -> Vector2:
	var spawn_pos = global_position
	var head_offset = _get_head_offset()
	spawn_pos += head_offset
	spawn_pos += Vector2(randf_range(-3, 3), randf_range(-2, 2))
	return spawn_pos

func _get_head_offset() -> Vector2:
	var offset = Vector2(30, -5)

	if sprite.texture == diving_texture:
		offset = Vector2(0, -15 if !sprite.flip_v else 15)
	elif sprite.flip_h:
		offset.x *= -1

	return offset

func take_damage(amount: float) -> void:
	health = max(0, health - amount)
	emit_signal("health_changed", health)
	if health <= 0:
		_handle_death()

func heal(amount: float) -> void:
	health = min(max_health, health + amount)
	emit_signal("health_changed", health)

func _handle_death() -> void:
	set_physics_process(false)
	var game_over = get_tree().get_first_node_in_group("game_over")
	if game_over:
		game_over.show_game_over()

func _on_area_entered(area: Area2D) -> void:
	var collider = area.get_parent()
	if collider.is_in_group("food"):
		print("[Player] Collided with food fish")
		if collider.has_method("take_damage"):
			collider.take_damage(100) # Instant kill small fish
			print("[Player] Damaging food fish")
			growth_manager.collect_food()
			particle_manager.spawn_eat_particles(collider.global_position)
			sound_manager.play_eat()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		print("[Player] Collided with enemy")
		take_damage(10) # Take damage when colliding with enemy fish

func _on_food_collected() -> void:
	emit_signal("size_changed", growth_manager.get_size())
	particle_manager.spawn_eat_particles(global_position)
	sound_manager.play_eat()

func _on_growth_level_reached() -> void:
	sound_manager.play_grow()
	particle_manager.spawn_grow_particles(global_position)

	# Update stats based on growth
	var stats = growth_manager.get_current_stats()
	scale = Vector2(stats.size, stats.size)

	max_health = base_health * stats.health_multiplier
	health = max_health

	max_oxygen = base_oxygen * stats.oxygen_multiplier
	# oxygen = max_oxygen

	speed = base_speed * stats.speed_multiplier
