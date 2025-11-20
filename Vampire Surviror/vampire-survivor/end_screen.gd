extends Control

@onready var title_label = %TitleLabel
@onready var time_label = %TimeLabel
@onready var enemies_label = %EnemiesLabel
@onready var level_label = %LevelLabel
@onready var exp_label = %ExpLabel
@onready var next_level_button = %NextLevelButton
@onready var level_select_button = %LevelSelectButton
@onready var main_menu_button = %MainMenuButton

var stats = {
	"time_survived": 0.0,
	"enemies_defeated": 0,
	"player_level": 1,
	"experience_gained": 0,
	"current_level": 1,
	"victory": true
}

func _ready():
	# Connect buttons
	next_level_button.pressed.connect(_on_next_level_pressed)
	level_select_button.pressed.connect(_on_level_select_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	
	# Set initial focus
	next_level_button.grab_focus()
	
	# Process mode to always so it works when paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func show_stats(game_stats: Dictionary):
	stats = game_stats
	
	# Update title based on victory/defeat
	if stats.get("victory", true):
		title_label.text = "LEVEL COMPLETE!"
		title_label.modulate = Color.GREEN
		next_level_button.visible = true
		
		# Unlock next level
		if has_node("/root/GameManager"):
			var game_manager = get_node("/root/GameManager")
			game_manager.unlock_level(stats.current_level + 1)
	else:
		title_label.text = "GAME OVER"
		title_label.modulate = Color.RED
		next_level_button.visible = false
	
	# Update stats labels
	var minutes = int(stats.time_survived / 60)
	var seconds = int(stats.time_survived) % 60
	time_label.text = "Time Survived: %02d:%02d" % [minutes, seconds]
	enemies_label.text = "Enemies Defeated: " + str(stats.enemies_defeated)
	level_label.text = "Player Level: " + str(stats.player_level)
	exp_label.text = "Experience Gained: " + str(stats.experience_gained)
	
	# Disable next level button if it's the last level
	if stats.current_level >= 6:
		next_level_button.visible = false

func _on_next_level_pressed():
	# Store next level in global
	if has_node("/root/GameManager"):
		get_node("/root/GameManager").current_level = stats.current_level + 1
	
	# Load next level
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main.tscn")

func _on_level_select_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://level_select.tscn")

func _on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://title_screen.tscn")
