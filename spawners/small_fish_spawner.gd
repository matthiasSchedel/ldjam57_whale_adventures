extends Node2D

# Small fish scene to spawn
@export var fish_scene: PackedScene
@export var max_fish: int = 15 # Total maximum fish
@export var min_spawn_distance: float = 600.0
@export var max_spawn_distance: float = 800.0
@export var despawn_distance: float = 1200.0
@export var spawn_check_interval: float = 1.0

var _player: Node2D = null
var active_fish: Array[Node] = []
var spawn_timer: Timer
var check_timer: Timer

func _ready():
	# Wait one frame to ensure player is ready
	call_deferred("_setup_spawner")

func _setup_spawner():
	# Get reference to player
	_player = get_tree().get_first_node_in_group("player")
	if not _player:
		push_error("Small fish spawner couldn't find player node!")
		# Try again in a moment if player not found
		await get_tree().create_timer(0.1).timeout
		_setup_spawner()
		return

	# Setup spawn timer
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_check_interval
	spawn_timer.connect("timeout", _on_spawn_timer_timeout)
	add_child(spawn_timer)
	spawn_timer.start()

	# Setup check timer for despawning
	check_timer = Timer.new()
	check_timer.wait_time = 3.0
	check_timer.connect("timeout", _check_fish_distances)
	add_child(check_timer)
	check_timer.start()

func _on_spawn_timer_timeout():
	_cleanup_invalid_fish()
	if active_fish.size() < max_fish:
		spawn_fish()

func spawn_fish():
	# Generate random angle and distance
	var angle = randf_range(0, 2 * PI)
	var distance = randf_range(min_spawn_distance, max_spawn_distance)

	# Calculate spawn position relative to player
	var spawn_pos = _player.global_position + Vector2(cos(angle), sin(angle)) * distance

	# Instance the fish
	var fish = fish_scene.instantiate()
	fish.global_position = spawn_pos

	# Connect to the tree_exiting signal to handle cleanup
	fish.tree_exiting.connect(_on_fish_tree_exiting.bind(fish))

	# Add to scene first so the fish is properly initialized
	get_parent().add_child(fish)

	# Now we can safely set the initial direction
	if fish.has_method("set_initial_direction"):
		var initial_angle = randf_range(0, 2 * PI)
		fish.set_initial_direction(Vector2(cos(initial_angle), sin(initial_angle)))

	active_fish.append(fish)
	print("[SmallFishSpawner] Spawned fish at:", spawn_pos)

func _check_fish_distances():
	if not _player:
		return

	_cleanup_invalid_fish()

	var fish_to_remove = []
	for fish in active_fish:
		if fish.global_position.distance_to(_player.global_position) > despawn_distance:
			fish_to_remove.append(fish)

	# Remove and free fish that are too far
	for fish in fish_to_remove:
		if is_instance_valid(fish):
			print("[SmallFishSpawner] Despawning fish due to distance")
			fish.queue_free()

func _cleanup_invalid_fish():
	active_fish = active_fish.filter(func(fish): return is_instance_valid(fish))

func _on_fish_tree_exiting(fish: Node):
	if fish in active_fish:
		active_fish.erase(fish)

# Optional: Pause/resume spawning
func pause_spawning():
	spawn_timer.paused = true

func resume_spawning():
	spawn_timer.paused = false
