extends Node2D

@onready var ui = $UI
@onready var player = $Player
@onready var enemy_spawner = $EnemySpawner

# Track game statistics
var enemies_defeated = 0
var total_experience_gained = 0
var game_time = 0.0

# End screen scene
var end_screen_scene = preload("res://end_screen.tscn")
var end_screen_instance

func _ready():
	# Connect UI level completed signal
	ui.level_completed.connect(_on_level_completed)
	
	# Set current level from GameManager if it exists
	if has_node("/root/GameManager"):
		var game_manager = get_node("/root/GameManager")
		# You can use game_manager.current_level to adjust difficulty, enemy types, etc.
		print("Starting Level: ", game_manager.current_level)
		
		# Adjust spawn rate based on level
		if enemy_spawner:
			enemy_spawner.spawn_interval = max(0.5, 2.0 - (game_manager.current_level - 1) * 0.2)

func _on_level_completed():
	print("Level completed! Showing end screen...")
	_show_end_screen(true)

func _on_player_died():
	print("Player died! Showing end screen...")
	_show_end_screen(false)

func _show_end_screen(victory: bool):
	# Create end screen instance
	end_screen_instance = end_screen_scene.instantiate()
	ui.add_child(end_screen_instance)
	
	# Gather stats
	var stats = {
		"time_survived": ui.game_time,
		"enemies_defeated": enemies_defeated,
		"player_level": ui.current_level,
		"experience_gained": total_experience_gained,
		"current_level": 1,  # Default
		"victory": victory
	}
	
	# Get current level from GameManager
	if has_node("/root/GameManager"):
		var game_manager = get_node("/root/GameManager")
		stats.current_level = game_manager.current_level
		
		# Mark level as completed if victory
		if victory:
			game_manager.complete_level(stats.current_level)
			game_manager.total_enemies_defeated += enemies_defeated
			game_manager.total_experience_gained += total_experience_gained
			game_manager.save_game()
	
	# Show the end screen with stats
	end_screen_instance.show_stats(stats)

# Track enemy defeats
func register_enemy_defeat():
	enemies_defeated += 1

# Track experience gains
func register_experience_gain(amount: float):
	total_experience_gained += int(amount)
