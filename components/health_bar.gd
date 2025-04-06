extends Node2D

@export var max_health: float = 100.0
@export var current_health: float = 100.0
@export var bar_width: float = 50.0
@export var bar_height: float = 4.0
@export var show_background: bool = true
@export var background_color: Color = Color(0.2, 0.2, 0.2, 0.8)
@export var bar_color: Color = Color(0.2, 0.8, 0.2, 0.8)
@export var regeneration_enabled: bool = false
@export var regeneration_rate: float = 5.0 # Health per second
@export var regeneration_delay: float = 2.0 # Seconds before regeneration starts

var regeneration_timer: Timer

func _ready():
	if regeneration_enabled:
		regeneration_timer = Timer.new()
		regeneration_timer.wait_time = regeneration_delay
		regeneration_timer.one_shot = true
		add_child(regeneration_timer)

func _process(_delta):
	queue_redraw()
	if regeneration_enabled and regeneration_timer and !regeneration_timer.is_stopped():
		current_health = min(current_health + regeneration_rate * _delta, max_health)

func _draw():
	if show_background:
		draw_rect(Rect2(-bar_width / 2, -bar_height / 2, bar_width, bar_height), background_color)

	var health_percentage = current_health / max_health
	var current_width = bar_width * health_percentage
	draw_rect(Rect2(-bar_width / 2, -bar_height / 2, current_width, bar_height), bar_color)

func take_damage(amount: float):
	current_health = max(0, current_health - amount)
	if regeneration_enabled:
		regeneration_timer.stop()

func heal(amount: float):
	current_health = min(max_health, current_health + amount)

func start_regeneration():
	if regeneration_enabled and regeneration_timer:
		regeneration_timer.start()

func stop_regeneration():
	if regeneration_enabled and regeneration_timer:
		regeneration_timer.stop()
