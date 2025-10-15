extends CanvasLayer
@onready var exp_bar = $ExperienceBar
@onready var level_label = $LevelLabel
@onready var time_label = $TimeLabel
@onready var level_up_panel = $LevelUpPanel

var player: CharacterBody2D
var game_time = 0.0

func _ready():
	add_to_group("ui")
	
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		player = players[0]
	
	level_up_panel.hide()

func _process(delta):
	game_time += delta
	
	if player:
		# Update experience bar
		exp_bar.max_value = player.exp_to_next_level
		exp_bar.value = player.experience
		
		# Update level label
		level_label.text = "Level: " + str(player.level)
	
	# Update time
	var minutes = int(game_time / 60)
	var seconds = int(game_time) % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]

func show_level_up():
	get_tree().paused = true
	level_up_panel.show()
	
	# Create upgrade options (simplified - you'd want buttons here)
	# For now, just unpause after a moment
	await get_tree().create_timer(0.5).timeout
	
	# Auto-select random upgrade for demo
	var upgrades = ["attack_speed", "damage", "speed", "projectile_count", "health"]
	player.upgrade_stat(upgrades[randi() % upgrades.size()])
	
	level_up_panel.hide()
	get_tree().paused = false
