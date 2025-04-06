extends CanvasLayer

@onready var retry_button = $CenterContainer/VBoxContainer/RetryButton
@onready var water_overlay = get_node("/root/Main/GameUI/WaterOverlay")

func _ready():
	retry_button.pressed.connect(_on_retry_button_pressed)
	# Hide the overlay by default
	hide()

func show_game_over():
	show()
	if water_overlay and water_overlay.material:
		water_overlay.material.set_shader_parameter("darkness_overlay", 0.7)
	get_tree().paused = true

func _on_retry_button_pressed():
	if water_overlay and water_overlay.material:
		water_overlay.material.set_shader_parameter("darkness_overlay", 0.0)
	get_tree().paused = false
	get_tree().reload_current_scene()