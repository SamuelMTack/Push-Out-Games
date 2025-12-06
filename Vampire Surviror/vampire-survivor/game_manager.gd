extends Node

# Game state
var current_level = 1
var completed_levels = []
var unlocked_levels = [1]  # Level 1 is unlocked by default
var coins = 0
var purchased_upgrades = {} # Format: {"upgrade_id": level}

# Player stats tracking
var total_enemies_defeated = 0
var total_experience_gained = 0

# Character Selection
var selected_character = "knight" # Default
var characters = {
	"knight": {
		"name": "Knight",
		"description": "Balanced stats. Starts with Sword.",
		"weapon": "res://weapons/Sword.tscn",
		"stats": {"max_health": 120, "speed": 200, "might": 1.0, "cooldown_mult": 1.0}
	},
	"mage": {
		"name": "Mage",
		"description": "High damage, low health. Starts with Wand.",
		"weapon": "res://weapons/Wand.tscn",
		"stats": {"max_health": 80, "speed": 190, "might": 1.3, "cooldown_mult": 0.9}
	},
	"ranger": {
		"name": "Ranger",
		"description": "Fast, fragile. Starts with Boomerang.",
		"weapon": "res://weapons/Boomerang.tscn",
		"stats": {"max_health": 90, "speed": 230, "might": 0.9, "cooldown_mult": 0.95}
	}
}

# Save file path
const SAVE_PATH = "user://savegame.dat"

signal coins_updated(new_amount)

func _ready():
	load_game()

func unlock_level(level: int):
	if level not in unlocked_levels and level <= 10:
		unlocked_levels.append(level)
		save_game()

func complete_level(level: int):
	if level not in completed_levels:
		completed_levels.append(level)
		# Unlock next level
		if level < 10:
			unlock_level(level + 1)
		save_game()

func add_coins(amount: int):
	coins += amount
	emit_signal("coins_updated", coins)
	# Auto-save on coin gain might be too frequent, maybe only on level end or purchase?
	# For safety, let's save on significant events or periodically. 
	# For now, we'll rely on level completion or shop exit to save, 
	# but maybe save every 100 coins or something?
	# Let's just save on level complete/fail for now to avoid disk spam.

func purchase_upgrade(upgrade_id: String, cost: int) -> bool:
	if coins >= cost:
		coins -= cost
		if upgrade_id not in purchased_upgrades:
			purchased_upgrades[upgrade_id] = 0
		purchased_upgrades[upgrade_id] += 1
		emit_signal("coins_updated", coins)
		save_game()
		return true
	return false

func get_upgrade_level(upgrade_id: String) -> int:
	return purchased_upgrades.get(upgrade_id, 0)

func save_game():
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if save_file:
		var save_data = {
			"completed_levels": completed_levels,
			"unlocked_levels": unlocked_levels,
			"total_enemies_defeated": total_enemies_defeated,
			"total_experience_gained": total_experience_gained,
			"coins": coins,
			"purchased_upgrades": purchased_upgrades
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
				coins = save_data.get("coins", 0)
				purchased_upgrades = save_data.get("purchased_upgrades", {})
			save_file.close()

func reset_progress():
	completed_levels = []
	unlocked_levels = [1]
	total_enemies_defeated = 0
	total_experience_gained = 0
	coins = 0
	purchased_upgrades = {}
	save_game()
