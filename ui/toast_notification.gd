extends PanelContainer

signal finished

@onready var label = $MarginContainer/Label

var duration: float = 3.0
var fade_time: float = 0.5

func _ready():
	modulate.a = 0
	show()

func show_message(message: String, show_duration: float = 3.0):
	label.text = message
	duration = show_duration
	
	# Fade in
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_time)
	tween.tween_interval(duration - (2 * fade_time))
	# Fade out
	tween.tween_property(self, "modulate:a", 0.0, fade_time)
	tween.tween_callback(func(): emit_signal("finished"))
	tween.tween_callback(queue_free)