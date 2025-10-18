extends CanvasLayer

@onready var health_bar = $HealthBar
@onready var exp_bar = $ExperienceBar
@onready var level_label = $LevelLabel
@onready var time_label = $TimeLabel
@onready var level_up_panel = $LevelUpPanel
@onready var upgrade_button1 = $LevelUpPanel/UpgradeButton1
@onready var upgrade_button2 = $LevelUpPanel/UpgradeButton2
@onready var upgrade_button3 = $LevelUpPanel/UpgradeButton3

var player: CharacterBody2D
var game_time = 0.0
var current_level = 1

func _ready():
	add_to_group("ui")
	
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		player = players[0]
		
		# Initialize bars
		health_bar.max_value = player.max_health
		health_bar.value = player.health
	
	level_up_panel.hide()
	
	# Connect upgrade buttons
	upgrade_button1.pressed.connect(_on_upgrade_selected.bind("faster"))
	upgrade_button2.pressed.connect(_on_upgrade_selected.bind("stronger"))
	upgrade_button3.pressed.connect(_on_upgrade_selected.bind("more"))

func _process(delta):
	if not get_tree().paused:
		game_time += delta
		
		# Update time label
		var minutes = int(game_time / 60)
		var seconds = int(game_time) % 60
		time_label.text = "Time: %02d:%02d" % [minutes, seconds]

func update_health(current: float, maximum: float):
	health_bar.max_value = maximum
	health_bar.value = current

func update_experience(current: float, maximum: float):
	exp_bar.max_value = maximum
	exp_bar.value = current

func show_level_up_panel():
	current_level += 1
	level_label.text = "Level: " + str(current_level)
	
	level_up_panel.show()
	get_tree().paused = true

func _on_upgrade_selected(upgrade_type: String):
	if player:
		player.apply_upgrade(upgrade_type)
	
	level_up_panel.hide()
	get_tree().paused = false
