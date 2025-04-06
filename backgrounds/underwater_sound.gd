extends Node

# Add this to your main scene script

var ambient_player: AudioStreamPlayer

func _ready():
	# Create the audio player when the node is ready
	ambient_player = AudioStreamPlayer.new()
	add_child(ambient_player)

	# Set up the audio stream
	var noise = AudioStreamGenerator.new()
	noise.mix_rate = 44100.0
	noise.buffer_length = 0.1 # 100ms buffer
	ambient_player.stream = noise
	ambient_player.volume_db = -20

func create_underwater_sound():
	if ambient_player and not ambient_player.playing:
		ambient_player.play()

func stop_underwater_sound():
	if ambient_player and ambient_player.playing:
		ambient_player.stop()
