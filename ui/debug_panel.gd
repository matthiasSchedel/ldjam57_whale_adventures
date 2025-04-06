extends Control

@onready var kill_player_btn = $Panel/VBoxContainer/KillPlayer
@onready var eat_fish_btn = $Panel/VBoxContainer/EatFish
@onready var damage_player_btn = $Panel/VBoxContainer/DamagePlayer
@onready var toggle_hunger_btn = $Panel/VBoxContainer/ToggleHunger

func _ready():
	# Set mouse filter mode to ignore when not over the panel
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Get the panel node
	var panel = $Panel
	if panel:
		# The panel itself should only handle input when directly hovered
		panel.mouse_filter = Control.MOUSE_FILTER_STOP
		
	# Connect button signals
	kill_player_btn.connect("pressed", _on_kill_player_pressed)
	eat_fish_btn.connect("pressed", _on_eat_fish_pressed)
	damage_player_btn.connect("pressed", _on_damage_player_pressed)
	toggle_hunger_btn.connect("pressed", _on_toggle_hunger_pressed)

func _on_kill_player_pressed():
	var player = get_node("/root/Main/Player")
	if player and player.has_method("take_damage"):
		print("[DEBUG] Killing player via debug panel")
		player.take_damage(1000)

func _on_eat_fish_pressed():
	var small_fish = get_tree().get_nodes_in_group("food")
	if small_fish.size() > 0:
		print("[DEBUG] Removing random fish via debug panel")
		var player = get_node("/root/Main/Player")
		if player and player.has_method("_on_area_entered"):
			# Create a temporary area to simulate collision
			var area = Area2D.new()
			area.add_child(small_fish[0])
			player._on_area_entered(area)
		else:
			small_fish[0].queue_free()

func _on_damage_player_pressed():
	var player = get_node("/root/Main/Player")
	if player and player.has_method("take_damage"):
		print("[DEBUG] Damaging player via debug panel")
		player.take_damage(20)

func _on_toggle_hunger_pressed():
	var enemy_fish = get_tree().get_nodes_in_group("enemies")
	for fish in enemy_fish:
		if fish.has_method("_on_hunger_timer_timeout"):
			print("[DEBUG] Toggling fish hunger via debug panel")
			fish._on_hunger_timer_timeout()