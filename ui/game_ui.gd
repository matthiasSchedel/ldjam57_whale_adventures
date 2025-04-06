extends CanvasLayer

@onready var depth_bar = $MarginContainer/BottomUI/StatusBars/DepthBar
@onready var food_bar = $MarginContainer/BottomUI/StatusBars/FoodBar
@onready var health_bar = $MarginContainer/BottomUI/StatusBars/HealthBar
@onready var pause_button = $MarginContainer/TopUI/PauseButton
@onready var toast_manager = $ToastManager
var score_label: Label

# Debug panel controls - make these optional
@onready var kill_player_btn = $Panel/VBoxContainer/KillPlayer if has_node("Panel/VBoxContainer/KillPlayer") else null
@onready var eat_fish_btn = $Panel/VBoxContainer/EatFish if has_node("Panel/VBoxContainer/EatFish") else null
@onready var damage_player_btn = $Panel/VBoxContainer/DamagePlayer if has_node("Panel/VBoxContainer/DamagePlayer") else null
@onready var toggle_hunger_btn = $Panel/VBoxContainer/ToggleHunger if has_node("Panel/VBoxContainer/ToggleHunger") else null

var player: Node2D = null
var max_depth: float = 2000.0
var regen_timer: float = 0.0
var regen_delay: float = 3.0
var regen_rate: float = 10.0
var has_eaten_first_fish = false
var has_grown_first_time = false
var total_fish_eaten = 0

# Bar color gradients
var health_colors = {
	"high": Color(0.0, 1.0, 0.0), # Green
	"medium": Color(1.0, 1.0, 0.0), # Yellow
	"low": Color(1.0, 0.0, 0.0) # Red
}

func _ready():
	# Make sure UI can process while game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Initialize score label
	score_label = Label.new()
	score_label.name = "ScoreLabel"
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_label.size_flags_horizontal = Control.SIZE_SHRINK_END
	score_label.custom_minimum_size = Vector2(150, 30)
	$MarginContainer/TopUI.add_child(score_label)
	update_score(0)

	pause_button.pressed.connect(_on_pause_button_pressed)

	# Connect debug panel buttons only if they exist
	if kill_player_btn:
		kill_player_btn.connect("pressed", _on_kill_player_pressed)
	if eat_fish_btn:
		eat_fish_btn.connect("pressed", _on_eat_fish_pressed)
	if damage_player_btn:
		damage_player_btn.connect("pressed", _on_damage_player_pressed)
	if toggle_hunger_btn:
		toggle_hunger_btn.connect("pressed", _on_toggle_hunger_pressed)

	# Find the player node
	player = get_tree().get_first_node_in_group("player")
	if not player:
		push_error("UI couldn't find player node!")
		return

	# Connect to player signals
	player.connect("health_changed", _on_player_health_changed)
	player.connect("size_changed", _on_player_size_changed)
	player.growth_manager.connect("food_collected", _on_food_collected)
	player.growth_manager.connect("growth_level_reached", _on_growth_level_reached)

	# Initialize bar properties
	_setup_progress_bars()

func _setup_progress_bars():
	# Set up health bar
	health_bar.min_value = 0
	health_bar.max_value = 100
	health_bar.value = 100
	health_bar.modulate = health_colors.high

	# Set up food bar
	food_bar.min_value = 0
	food_bar.max_value = 100
	food_bar.value = 100

	# Set up depth bar
	depth_bar.min_value = 0
	depth_bar.max_value = 100
	depth_bar.value = 0

func _process(delta):
	if not player:
		return

	# Update depth bar
	var depth = player.position.y
	var depth_percent = (depth / max_depth) * 100
	depth_bar.value = depth_percent

	# Update health bar with color
	var health_percent = (player.health / player.max_health) * 100
	health_bar.value = health_percent
	_update_bar_color(health_bar, health_percent, health_colors)

	# Handle health regeneration
	if player.linear_velocity.length() < 0.1: # Player is stationary
		regen_timer += delta
		if regen_timer >= regen_delay:
			player.heal(regen_rate * delta)
	else:
		regen_timer = 0.0

func _update_bar_color(bar: ProgressBar, percent: float, colors: Dictionary):
	if percent > 66:
		bar.modulate = colors.high
	elif percent > 33:
		bar.modulate = colors.medium
	else:
		bar.modulate = colors.low

func _on_pause_button_pressed():
	if get_tree().paused:
		get_tree().paused = false
		pause_button.text = "II"
	else:
		get_tree().paused = true
		pause_button.text = "▶"

func _on_player_health_changed(new_health: float):
	if health_bar and player:
		health_bar.value = (new_health / player.max_health) * 100
		_update_bar_color(health_bar, health_bar.value, health_colors)

func _on_player_size_changed(new_size: float):
	if player:
		player.scale = Vector2(new_size, new_size)
		# Increment score when fish is eaten
		update_score(1)

func update_health(new_health: float):
	if health_bar and player:
		health_bar.value = (new_health / player.max_health) * 100
		_update_bar_color(health_bar, health_bar.value, health_colors)

func update_size(new_size: float):
	if player:
		player.scale = Vector2(new_size, new_size)

# Debug panel functions
func _on_kill_player_pressed():
	var target_player = get_node("/root/Main/Player")
	if target_player and target_player.has_method("take_damage"):
		print("[DEBUG] Killing player via debug panel")
		target_player.take_damage(1000)

func _on_eat_fish_pressed():
	var small_fish = get_tree().get_nodes_in_group("food")
	if small_fish.size() > 0:
		print("[DEBUG] Removing random fish via debug panel")
		var target_player = get_node("/root/Main/Player")
		if target_player and target_player.has_method("_on_area_entered"):
			# Create a temporary area to simulate collision
			var area = Area2D.new()
			area.add_child(small_fish[0])
			target_player._on_area_entered(area)
		else:
			small_fish[0].queue_free()

func _on_damage_player_pressed():
	var target_player = get_node("/root/Main/Player")
	if target_player and target_player.has_method("take_damage"):
		print("[DEBUG] Damaging player via debug panel")
		target_player.take_damage(20)

func _on_toggle_hunger_pressed():
	var enemy_fish = get_tree().get_nodes_in_group("enemies")
	for fish in enemy_fish:
		if fish.has_method("_on_hunger_timer_timeout"):
			print("[DEBUG] Toggling fish hunger via debug panel")
			fish._on_hunger_timer_timeout()

func _on_food_collected():
	if not has_eaten_first_fish:
		has_eaten_first_fish = true
		toast_manager.show_first_fish_eaten()

func _on_growth_level_reached():
	if not has_grown_first_time:
		has_grown_first_time = true
		toast_manager.show_first_growth()

func update_score(fish_eaten: int):
	total_fish_eaten += fish_eaten
	score_label.text = "Score: %d" % (total_fish_eaten * 10)
