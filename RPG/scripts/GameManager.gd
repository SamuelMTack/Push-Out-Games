extends Node

signal timer_updated(time_left)
signal gold_updated(current_gold)
signal level_updated(current_level)
signal game_over
signal game_won

var max_time: float = 30.0
var current_time: float = 30.0
var gold: int = 0
var level: int = 1
var xp: int = 0
var xp_to_next_level: int = 100
var extension_cost: int = 10
var is_game_active: bool = true

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	start_game()

func _process(delta):
	if is_game_active:
		current_time -= delta
		if current_time <= 0:
			current_time = 0
			trigger_game_over()
		emit_signal("timer_updated", current_time)

func start_game():
	current_time = max_time
	gold = 0
	level = 1
	xp = 0
	extension_cost = 10
	is_game_active = true
	# Reload main scene if needed, or reset positions
	# get_tree().reload_current_scene()

func add_gold(amount: int):
	gold += amount
	emit_signal("gold_updated", gold)

func add_xp(amount: int):
	xp += amount
	if xp >= xp_to_next_level:
		level_up()

func level_up():
	level += 1
	xp -= xp_to_next_level
	xp_to_next_level = int(xp_to_next_level * 1.5)
	emit_signal("level_updated", level)
	# Heal player or increase stats here if global handling is needed

func extend_time():
	if gold >= extension_cost:
		gold -= extension_cost
		current_time = max_time
		extension_cost = int(extension_cost * 1.5) # Increase cost
		emit_signal("gold_updated", gold)
		emit_signal("timer_updated", current_time)
		return true
	return false

func trigger_game_over():
	is_game_active = false
	emit_signal("game_over")
	print("Game Over!")

func trigger_win():
	is_game_active = false
	emit_signal("game_won")
	print("You Win!")
