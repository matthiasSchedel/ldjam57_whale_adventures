extends Node

class_name SoundManager

# Sound configuration
const SOUND_CONFIG = {
	"bubble": {
		"stream": preload("res://assets/audio/bubbles.ogg"),
		"volume_idle": - 10,
		"volume_active": - 1
	},
	"eat": {
		"stream": preload("res://assets/audio/fish_Eat.ogg"),
		"volume": - 5
	},
	"grow": {
		"stream": preload("res://assets/audio/grow_siz.ogg"),
		"volume": - 5
	},
	"enemy_die": {
		"stream": preload("res://assets/audio/Enmy_DIE.ogg"),
		"volume": - 5
	}
}

var sounds: Dictionary = {}

func _ready() -> void:
	_setup_sounds()

func _setup_sounds() -> void:
	for sound_name in SOUND_CONFIG.keys():
		var player = AudioStreamPlayer.new()
		player.stream = SOUND_CONFIG[sound_name]["stream"]
		player.volume_db = SOUND_CONFIG[sound_name].get("volume", -5)
		add_child(player)
		sounds[sound_name] = player

func play_sound(sound_name: String) -> void:
	if sounds.has(sound_name):
		sounds[sound_name].play()

func stop_sound(sound_name: String) -> void:
	if sounds.has(sound_name):
		sounds[sound_name].stop()

func set_bubble_volume(is_moving: bool) -> void:
	if sounds.has("bubble"):
		sounds["bubble"].volume_db = SOUND_CONFIG["bubble"]["volume_active" if is_moving else "volume_idle"]
		if !sounds["bubble"].playing:
			sounds["bubble"].play()

func play_eat() -> void:
	play_sound("eat")

func play_grow() -> void:
	play_sound("grow")