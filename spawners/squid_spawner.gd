extends Node2D

# Squid scene to spawn
@export var squid_scene: PackedScene
@export var max_squids: int = 3
@export var min_spawn_distance: float = 800.0
@export var max_spawn_distance: float = 1200.0
@export var despawn_distance: float = 1500.0
@export var spawn_check_interval: float = 8.0
@export var min_depth: float = 800.0 # Minimum depth where squids can spawn
@export var disable_spawning: bool = true # Flag to disable squid spawning

var _player: Node2D = null
var active_squids: Array[Node] = []
var spawn_timer: Timer
var check_timer: Timer

func _ready():
	# Get reference to player
	_player = get_tree().get_first_node_in_group("player")
	if not _player:
		push_error("Squid spawner couldn't find player node!")
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
	check_timer.connect("timeout", _check_squid_distances)
	add_child(check_timer)
	check_timer.start()

func _on_spawn_timer_timeout():
	if disable_spawning:
		return
	_cleanup_invalid_squids()
	if active_squids.size() < max_squids and _player.position.y >= min_depth:
		spawn_squid()

func spawn_squid():
	# Generate random angle and distance
	var angle = randf_range(0, 2 * PI)
	var distance = randf_range(min_spawn_distance, max_spawn_distance)

	# Calculate spawn position relative to player
	var spawn_pos = _player.global_position + Vector2(cos(angle), sin(angle)) * distance

	# Only spawn if deep enough
	if spawn_pos.y >= min_depth:
		# Instance the squid
		var squid = squid_scene.instantiate()
		squid.global_position = spawn_pos

		# Connect to the tree_exiting signal to handle cleanup
		squid.tree_exiting.connect(_on_squid_tree_exiting.bind(squid))

		# Add to scene and track
		get_parent().add_child(squid)
		active_squids.append(squid)

func _check_squid_distances():
	if not _player:
		return

	_cleanup_invalid_squids()

	var squids_to_remove = []
	for squid in active_squids:
		if squid.global_position.distance_to(_player.global_position) > despawn_distance:
			squids_to_remove.append(squid)

	# Remove and free squids that are too far
	for squid in squids_to_remove:
		if is_instance_valid(squid):
			squid.queue_free()

func _cleanup_invalid_squids():
	active_squids = active_squids.filter(func(squid): return is_instance_valid(squid))

func _on_squid_tree_exiting(squid: Node):
	if squid in active_squids:
		active_squids.erase(squid)

# Optional: Pause/resume spawning
func pause_spawning():
	spawn_timer.paused = true

func resume_spawning():
	spawn_timer.paused = false
