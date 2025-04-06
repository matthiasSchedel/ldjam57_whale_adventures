extends Node

class_name TestGameStartup

var required_scenes = [
	"res://scenes/main.tscn",
	"res://ui/game_ui.tscn",
	"res://ui/game_over.tscn",
	"res://backgrounds/infinite_background.tscn",
	"res://player/player.tscn",
	"res://ui/size_indicator.tscn",
	"res://ui/toast_notification.tscn"
]

var required_scripts = [
	"res://player/player.gd",
	"res://components/sound_manager.gd",
	"res://components/particle_manager.gd",
	"res://components/growth_manager.gd",
	"res://ui/game_ui.gd",
	"res://components/health_bar.gd",
	"res://ui/size_indicator.gd",
	"res://ui/toast_notification.gd",
	"res://ui/toast_manager.gd"
]

var required_shaders = [
	"res://shaders/water_background.gdshader",
	"res://backgrounds/background_gradient.gdshader"
]

var required_audio = [
	"res://assets/audio/fish_Eat.ogg",
	"res://assets/audio/grow_siz.ogg",
	"res://assets/audio/Enmy_DIE.ogg",
	"res://assets/audio/bubbles.ogg"
]

func _ready():
	print("Starting game startup tests...")
	run_tests()

func run_tests():
	var all_passed = true
	
	print("\nTesting scene loading...")
	for scene_path in required_scenes:
		var result = test_load_scene(scene_path)
		all_passed = all_passed and result
	
	print("\nTesting script loading...")
	for script_path in required_scripts:
		var result = test_load_script(script_path)
		all_passed = all_passed and result
	
	print("\nTesting shader compilation...")
	var shader_result = test_shaders()
	all_passed = all_passed and shader_result

	print("\nTesting audio files...")
	for audio_path in required_audio:
		var result = test_load_audio(audio_path)
		all_passed = all_passed and result
	
	if !all_passed:
		print("\nSome tests failed. Please check the following:")
		print("1. All files exist in their correct locations")
		print("2. No script references are broken")
		print("3. All resources have been imported")
		print("\nTry opening the project in the Godot editor to reimport resources.")
	
	print("\nTest Results: ", "PASSED" if all_passed else "FAILED")
	get_tree().quit()

func test_load_scene(path: String) -> bool:
	print("Testing scene: ", path)
	var scene = load(path)
	if scene == null:
		push_error("Failed to load scene: " + path)
		return false
	print("✓ Scene loaded successfully: ", path)
	return true

func test_load_script(path: String) -> bool:
	print("Testing script: ", path)
	var script = load(path)
	if script == null:
		push_error("Failed to load script: " + path)
		return false
	print("✓ Script loaded successfully: ", path)
	return true

func test_shaders() -> bool:
	var all_passed = true
	for path in required_shaders:
		print("Testing shader: ", path)
		var shader = load(path)
		if shader == null:
			push_error("Failed to load shader: " + path)
			all_passed = false
			continue
		print("✓ Shader loaded successfully: ", path)
	
	return all_passed

func test_load_audio(path: String) -> bool:
	print("Testing audio: ", path)
	var audio = load(path)
	if audio == null:
		push_error("Failed to load audio: " + path)
		return false
	print("✓ Audio loaded successfully: ", path)
	return true