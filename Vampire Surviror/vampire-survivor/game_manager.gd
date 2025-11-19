extends Node

# Game state
var current_level = 1
var completed_levels = []
var unlocked_levels = [1]  # Level 1 is unlocked by default

# Player stats tracking
var total_enemies_defeated = 0
var total_experience_gained = 0

# Save file path
const SAVE_PATH = "user://savegame.dat"

func _ready():
	load_game()

func unlock_level(level: int):
	if level not in unlocked_levels and level <= 6:
		unlocked_levels.append(level)
		save_game()

func complete_level(level: int):
	if level not in completed_levels:
		completed_levels.append(level)
		# Unlock next level
		if level < 6:
			unlock_level(level + 1)
		save_game()

func save_game():
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if save_file:
		var save_data = {
			"completed_levels": completed_levels,
			"unlocked_levels": unlocked_levels,
			"total_enemies_defeated": total_enemies_defeated,
			"total_experience_gained": total_experience_gained
		}
		save_file.store_var(save_data)
		save_file.close()

func load_game():
	if FileAccess.file_exists(SAVE_PATH):
		var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if save_file:
			var save_data = save_file.get_var()
			if save_data:
				completed_levels = save_data.get("completed_levels", [])
				unlocked_levels = save_data.get("unlocked_levels", [1])
				total_enemies_defeated = save_data.get("total_enemies_defeated", 0)
				total_experience_gained = save_data.get("total_experience_gained", 0)
			save_file.close()

func reset_progress():
	completed_levels = []
	unlocked_levels = [1]
	total_enemies_defeated = 0
	total_experience_gained = 0
	save_game()
