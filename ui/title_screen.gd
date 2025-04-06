extends Control

@onready var underwater_sound = preload("res://backgrounds/underwater_sound.gd").new()

func _ready():
	# Add the underwater sound node to the scene
	add_child(underwater_sound)

	# Set up keyboard shortcut for starting the game
	if not InputMap.has_action("start_game"):
		InputMap.add_action("start_game")
		var event = InputEventKey.new()
		event.keycode = KEY_ENTER
		InputMap.action_add_event("start_game", event)

func _input(event):
	if event.is_action_pressed("start_game"):
		_on_start_button_pressed()

func _on_start_button_pressed():
	# Start the underwater sound
	if underwater_sound:
		underwater_sound.create_underwater_sound()

	# Change to the main scene
	var scene = load("res://scenes/main.tscn")
	get_tree().change_scene_to_packed(scene)
