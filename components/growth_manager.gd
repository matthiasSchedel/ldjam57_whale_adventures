extends Node

class_name GrowthManager

signal growth_level_reached
signal food_collected

const FOOD_TO_GROW = 9
const GROWTH_FACTOR = 1.3

var current_food: int = 0
var current_size: float = 1.0
var growth_level: int = 0

var food_bar: Node = null

func _ready() -> void:
	# Try to get the food bar, but don't error if it's not found
	food_bar = get_node_or_null("/root/Main/GameUI/MarginContainer/BottomUI/StatusBars/FoodBar")
	if food_bar:
		food_bar.value = 0
		food_bar.max_value = FOOD_TO_GROW

func collect_food() -> void:
	current_food += 1
	if food_bar:
		food_bar.value = current_food
	emit_signal("food_collected")

	if current_food >= FOOD_TO_GROW:
		grow()

func grow() -> void:
	growth_level += 1
	current_size *= GROWTH_FACTOR
	current_food = 0
	if food_bar:
		food_bar.value = 0
	emit_signal("growth_level_reached")

func get_current_stats() -> Dictionary:
	var growth_multiplier = pow(GROWTH_FACTOR, growth_level)
	return {
		"size": current_size,
		"health_multiplier": growth_multiplier,
		"oxygen_multiplier": growth_multiplier,
		"speed_multiplier": sqrt(growth_multiplier) # Smaller speed increase to maintain control
	}

func get_size() -> float:
	return current_size

func get_growth_level() -> int:
	return growth_level
