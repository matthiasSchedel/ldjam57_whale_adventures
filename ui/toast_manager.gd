extends Node

var toast_scene = preload("res://ui/toast_notification.tscn")
var current_toast = null

func show_toast(message: String, duration: float = 3.0):
	if current_toast:
		current_toast.queue_free()
	
	current_toast = toast_scene.instantiate()
	add_child(current_toast)
	current_toast.connect("finished", func(): current_toast = null)
	current_toast.show_message(message, duration)

func show_first_fish_eaten():
	show_toast("You ate your first fish! Keep eating to grow bigger!", 4.0)

func show_first_growth():
	show_toast("You've grown bigger! As you grow, you can eat larger fish and swim faster!", 5.0)