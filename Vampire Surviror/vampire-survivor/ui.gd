extends CanvasLayer

@onready var health_bar = %HealthBar
@onready var exp_bar = %ExperienceBar
@onready var level_label = %LevelLabel
@onready var time_label = %TimeLabel
@onready var level_up_panel = %LevelUpPanel
@onready var upgrade_button1 = %LevelUpPanel/%UpgradeButton1
@onready var upgrade_button2 = %LevelUpPanel/%UpgradeButton2
@onready var upgrade_button3 = %LevelUpPanel/%UpgradeButton3
@onready var confirm_button = %LevelUpPanel/%ConfirmButton

var player: CharacterBody2D
var game_time = 0.0
var level_duration = 1200.0  # 20 minutes in seconds (1200 for production, can set to 30 for testing)
var current_level = 1
var selected_upgrade = ""  # Tracks which upgrade was selected
var selected_button_index = 0  # 0, 1, or 2 for the three upgrade buttons
var upgrade_buttons = []  # Array to hold the three upgrade buttons
var available_upgrades = []  # Currently available upgrade options
var level_complete = false  # Track if level is complete

# All possible upgrades with display names and internal IDs
var all_upgrades = [
	{"name": "Faster Projectiles", "id": "projectile_speed"},
	{"name": "More Damage", "id": "projectile_damage"},
	{"name": "Extra Projectile", "id": "projectile_count"},
	{"name": "Attack Speed", "id": "attack_speed"},
	{"name": "Move Speed", "id": "player_speed"},
	{"name": "Max Health", "id": "max_health"},
	{"name": "Health Regen", "id": "health_regen"},
	{"name": "Pickup Range", "id": "pickup_range"},
	{"name": "Projectile Pierce", "id": "projectile_pierce"},
	{"name": "Projectile Size", "id": "projectile_size"}
]

signal level_completed

func _ready():
	add_to_group("ui")
	
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		player = players[0]
		
		# Initialize bars
		health_bar.max_value = player.max_health
		health_bar.value = player.health
	
	level_up_panel.hide()
	
	# Store buttons in array for easy navigation
	upgrade_buttons = [upgrade_button1, upgrade_button2, upgrade_button3]
	
	# Connect upgrade buttons to selection (not immediate application)
	upgrade_button1.pressed.connect(_on_upgrade_button_pressed.bind(0))
	upgrade_button2.pressed.connect(_on_upgrade_button_pressed.bind(1))
	upgrade_button3.pressed.connect(_on_upgrade_button_pressed.bind(2))
	
	# Connect confirm button
	confirm_button.pressed.connect(_on_confirm_pressed)
	confirm_button.disabled = true  # Start disabled until upgrade selected

func _process(delta):
	if not get_tree().paused and not level_complete:
		game_time += delta
		
		# Calculate remaining time
		var time_remaining = level_duration - game_time
		
		if time_remaining <= 0:
			# Level complete!
			time_remaining = 0
			if not level_complete:
				level_complete = true
				_on_level_complete()
		
		# Update time label with countdown
		var minutes = int(time_remaining / 60)
		var seconds = int(time_remaining) % 60
		time_label.text = "Time: %02d:%02d" % [minutes, seconds]
		
		# Change color when time is running out
		if time_remaining <= 60:  # Last minute
			time_label.modulate = Color.RED
		elif time_remaining <= 300:  # Last 5 minutes
			time_label.modulate = Color.YELLOW
		else:
			time_label.modulate = Color.WHITE
	
	# Always handle input when panel is visible (even when paused)
	if level_up_panel.visible:
		_handle_level_up_input()

func _on_level_complete():
	print("Level Complete!")
	get_tree().paused = true
	emit_signal("level_completed")
	# The main scene will handle showing the end screen

func _handle_level_up_input():
	# Up arrow - move selection up
	if Input.is_action_just_pressed("ui_up"):
		selected_button_index -= 1
		if selected_button_index < 0:
			selected_button_index = 2  # Wrap to bottom
		_highlight_selected_button()
	
	# Down arrow - move selection down
	elif Input.is_action_just_pressed("ui_down"):
		selected_button_index += 1
		if selected_button_index > 2:
			selected_button_index = 0  # Wrap to top
		_highlight_selected_button()
	
	# Space bar - select the highlighted upgrade and confirm
	elif Input.is_action_just_pressed("ui_accept"):  # Space bar or Enter
		_select_current_upgrade()
		_on_confirm_pressed()

func _highlight_selected_button():
	# Reset all button colors
	for i in range(upgrade_buttons.size()):
		if i == selected_button_index:
			upgrade_buttons[i].modulate = Color.YELLOW  # Highlight selected
		else:
			upgrade_buttons[i].modulate = Color.WHITE  # Normal color

func _select_current_upgrade():
	# Select the upgrade based on current button index
	if selected_button_index < available_upgrades.size():
		selected_upgrade = available_upgrades[selected_button_index]["id"]
		confirm_button.disabled = false
		print("Upgrade selected: ", selected_upgrade)

func _pick_random_upgrades():
	# Shuffle and pick 3 random upgrades
	available_upgrades.clear()
	var shuffled = all_upgrades.duplicate()
	shuffled.shuffle()
	
	# Take first 3
	for i in range(min(3, shuffled.size())):
		available_upgrades.append(shuffled[i])
	
	# Update button texts
	for i in range(3):
		if i < available_upgrades.size():
			upgrade_buttons[i].text = available_upgrades[i]["name"]
			upgrade_buttons[i].visible = true
		else:
			upgrade_buttons[i].visible = false

func update_health(current: float, maximum: float):
	health_bar.max_value = maximum
	health_bar.value = current

func update_experience(current: float, maximum: float):
	exp_bar.max_value = maximum
	exp_bar.value = current

func show_level_up_panel():
	current_level += 1
	level_label.text = "Level: " + str(current_level)
	
	# Pick 3 random upgrades
	_pick_random_upgrades()
	
	# Reset selection
	selected_upgrade = ""
	selected_button_index = 0  # Start at first button
	confirm_button.disabled = true
	
	# Reset button colors and highlight first one
	_highlight_selected_button()
	
	level_up_panel.show()
	
	# Set process mode to always so UI can receive input while paused
	level_up_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	get_tree().paused = true
	print("Level up panel shown - Use arrow keys to select, space to confirm")

func _on_upgrade_button_pressed(button_index: int):
	# Store which button was clicked
	selected_button_index = button_index
	
	# Select the upgrade
	if button_index < available_upgrades.size():
		selected_upgrade = available_upgrades[button_index]["id"]
	
	# Highlight the selected button
	_highlight_selected_button()
	
	# Enable the confirm button
	confirm_button.disabled = false
	
	print("Upgrade selected: ", selected_upgrade, " - Press CONFIRM to apply!")

func _on_confirm_pressed():
	# Check that an upgrade was actually selected
	if selected_upgrade == "":
		print("Error: No upgrade selected!")
		return
	
	if not player:
		print("Error: Player not found!")
		return
	
	# NOW apply the upgrade (only when confirm is pressed)
	player.apply_upgrade(selected_upgrade)
	print("Upgrade applied: ", selected_upgrade)
	
	# Close the panel and resume the game
	level_up_panel.hide()
	
	# Reset process modes
	level_up_panel.process_mode = Node.PROCESS_MODE_INHERIT
	process_mode = Node.PROCESS_MODE_INHERIT
	
	get_tree().paused = false
	
	# Reset for next level up
	selected_upgrade = ""
