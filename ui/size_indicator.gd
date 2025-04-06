extends HBoxContainer

@onready var icon = $Icon
@onready var size_label = $SizeLabel

func _ready():
	# Load fish icon texture
	icon.texture = preload("res://assets/images/player/idle.png")
	# Get player reference and connect to size changes
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.connect("size_changed", _on_size_changed)
		# Set initial size
		_on_size_changed(player.scale.x)

func _on_size_changed(new_size: float):
	size_label.text = "x%.1f" % new_size