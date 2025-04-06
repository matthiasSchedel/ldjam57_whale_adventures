extends Node2D

@onready var player = $Player
@onready var game_ui = $GameUI
@onready var fish_spawner = $FishSpawner
@onready var small_fish_spawner = $SmallFishSpawner
@onready var squid_spawner = $SquidSpawner
@onready var background_music = $BackgroundMusic

func _ready():
	# Initialize game state
	player.connect("health_changed", _on_player_health_changed)
	player.connect("size_changed", _on_player_size_changed)

func _on_player_health_changed(new_health: float):
	game_ui.update_health(new_health)

func _on_player_size_changed(new_size: float):
	game_ui.update_size(new_size)
