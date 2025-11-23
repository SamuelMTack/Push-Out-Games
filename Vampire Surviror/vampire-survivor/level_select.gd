extends Control

@onready var level1_button = %Level1Button
@onready var level2_button = %Level2Button
@onready var level3_button = %Level3Button
@onready var level4_button = %Level4Button
@onready var level5_button = %Level5Button
@onready var level6_button = %Level6Button
@onready var level7_button = %Level7Button
@onready var level8_button = %Level8Button
@onready var level9_button = %Level9Button
@onready var level10_button = %Level10Button
@onready var back_button = %BackButton

# Track unlocked levels (could be saved to a file)
var unlocked_levels = {
	1: true,
	2: false,
	3: false,
	4: false,
	5: false,
	6: false,
	7: false,
	8: false,
	9: false,
	10: false
}

func _ready():
	# Load progress (if you implement save system)
	_load_progress()
	
	# Connect button signals
	level1_button.pressed.connect(_on_level_button_pressed.bind(1))
	level2_button.pressed.connect(_on_level_button_pressed.bind(2))
	level3_button.pressed.connect(_on_level_button_pressed.bind(3))
	level4_button.pressed.connect(_on_level_button_pressed.bind(4))
	level5_button.pressed.connect(_on_level_button_pressed.bind(5))
	level6_button.pressed.connect(_on_level_button_pressed.bind(6))
	level7_button.pressed.connect(_on_level_button_pressed.bind(7))
	level8_button.pressed.connect(_on_level_button_pressed.bind(8))
	level9_button.pressed.connect(_on_level_button_pressed.bind(9))
	level10_button.pressed.connect(_on_level_button_pressed.bind(10))
	back_button.pressed.connect(_on_back_button_pressed)
	
	# Update button states
	_update_button_states()
	
	# Set initial focus
	level1_button.grab_focus()

func _load_progress():
	# Check if previous levels were completed (stored in global singleton or save file)
	# For now, check if a global exists
	if has_node("/root/GameManager"):
		var game_manager = get_node("/root/GameManager")
		if "completed_levels" in game_manager:
			for level in game_manager.completed_levels:
				if level < 10:  # Unlock next level
					unlocked_levels[level + 1] = true
		
		# Also check unlocked_levels from GameManager
		if "unlocked_levels" in game_manager:
			for level in game_manager.unlocked_levels:
				unlocked_levels[level] = true

func _update_button_states():
	level1_button.disabled = not unlocked_levels[1]
	level2_button.disabled = not unlocked_levels[2]
	level3_button.disabled = not unlocked_levels[3]
	level4_button.disabled = not unlocked_levels[4]
	level5_button.disabled = not unlocked_levels[5]
	level6_button.disabled = not unlocked_levels[6]
	level7_button.disabled = not unlocked_levels[7]
	level8_button.disabled = not unlocked_levels[8]
	level9_button.disabled = not unlocked_levels[9]
	level10_button.disabled = not unlocked_levels[10]
	
	# Show locked status
	if not unlocked_levels[2]: level2_button.text = "Level 2\n[LOCKED]"
	if not unlocked_levels[3]: level3_button.text = "Level 3\n[LOCKED]"
	if not unlocked_levels[4]: level4_button.text = "Level 4\n[LOCKED]"
	if not unlocked_levels[5]: level5_button.text = "Level 5\n[LOCKED]"
	if not unlocked_levels[6]: level6_button.text = "Level 6\n[LOCKED]"
	if not unlocked_levels[7]: level7_button.text = "Level 7\n[LOCKED]"
	if not unlocked_levels[8]: level8_button.text = "Level 8\n[LOCKED]"
	if not unlocked_levels[9]: level9_button.text = "Level 9\n[LOCKED]"
	if not unlocked_levels[10]: level10_button.text = "Level 10\n[LOCKED]"

func _on_level_button_pressed(level: int):
	# Store selected level in global if you have one
	if has_node("/root/GameManager"):
		get_node("/root/GameManager").current_level = level
	
	# Load the main game scene
	get_tree().change_scene_to_file("res://main.tscn")

func _on_back_button_pressed():
	# Go back to character select screen
	get_tree().change_scene_to_file("res://character_select.tscn")

func unlock_next_level(completed_level: int):
	if completed_level < 10:
		unlocked_levels[completed_level + 1] = true
		_update_button_states()
