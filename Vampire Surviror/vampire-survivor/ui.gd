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

# Reuse level up panel for special rewards for simplicity, or create a new one if needed.
# For now, we'll reuse it but change the title/content.
var is_special_reward = false

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

# Special weapons
var special_weapons = [
	{"name": "Sword", "id": "weapon_sword", "scene": "res://weapons/Sword.tscn"},
	{"name": "Bomb", "id": "weapon_bomb", "scene": "res://weapons/Bomb.tscn"},
	{"name": "Boomerang", "id": "weapon_boomerang", "scene": "res://weapons/Boomerang.tscn"},
	{"name": "Orbit Orb", "id": "weapon_orbit", "scene": "res://weapons/OrbitWeapon.tscn"}
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
	
	_setup_cheat_menu()
	_setup_pause_menu()

var cheat_menu: PanelContainer
var pause_menu: PanelContainer

func _setup_pause_menu():
	pause_menu = PanelContainer.new()
	pause_menu.name = "PauseMenu"
	pause_menu.hide()
	# Ensure it processes input even when game is paused
	pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(pause_menu)
	
	# Center it
	pause_menu.anchors_preset = Control.PRESET_CENTER
	
	var vbox = VBoxContainer.new()
	pause_menu.add_child(vbox)
	
	var label = Label.new()
	label.text = "PAUSED"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(label)
	
	var btn_continue = Button.new()
	btn_continue.text = "Continue"
	btn_continue.pressed.connect(_on_pause_continue)
	vbox.add_child(btn_continue)
	
	var btn_level_select = Button.new()
	btn_level_select.text = "Level Select"
	btn_level_select.pressed.connect(_on_pause_level_select)
	vbox.add_child(btn_level_select)
	
	var btn_quit = Button.new()
	btn_quit.text = "Quit to Title"
	btn_quit.pressed.connect(_on_pause_quit)
	vbox.add_child(btn_quit)

func _setup_cheat_menu():
	cheat_menu = PanelContainer.new()
	cheat_menu.name = "CheatMenu"
	cheat_menu.hide()
	# Ensure it processes input even when game is paused
	cheat_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(cheat_menu)
	
	# Center it
	cheat_menu.anchors_preset = Control.PRESET_CENTER
	# cheat_menu.position = Vector2(get_viewport().size) / 2 # Anchors handle this
	
	var vbox = VBoxContainer.new()
	cheat_menu.add_child(vbox)
	
	var label = Label.new()
	label.text = "CHEAT MENU"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(label)
	
	var btn_unlock = Button.new()
	btn_unlock.text = "Unlock All Levels"
	btn_unlock.pressed.connect(_on_cheat_unlock_levels)
	vbox.add_child(btn_unlock)
	
	var btn_kill = Button.new()
	btn_kill.text = "Kill All Enemies"
	btn_kill.pressed.connect(_on_cheat_kill_enemies)
	vbox.add_child(btn_kill)
	
	var btn_levelup = Button.new()
	btn_levelup.text = "Level Up"
	btn_levelup.pressed.connect(_on_cheat_level_up)
	vbox.add_child(btn_levelup)
	
	var btn_heal = Button.new()
	btn_heal.text = "Heal (100%)"
	btn_heal.pressed.connect(_on_cheat_heal)
	vbox.add_child(btn_heal)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F1:
			if cheat_menu.visible:
				cheat_menu.hide()
				get_tree().paused = false
			else:
				cheat_menu.show()
				get_tree().paused = true
		elif event.keycode == KEY_ESCAPE:
			if pause_menu.visible:
				_on_pause_continue()
			else:
				pause_menu.show()
				get_tree().paused = true

func _on_pause_continue():
	pause_menu.hide()
	get_tree().paused = false

func _on_pause_level_select():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://level_select.tscn")

func _on_pause_quit():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://title_screen.tscn")

func _on_cheat_unlock_levels():
	if has_node("/root/GameManager"):
		var gm = get_node("/root/GameManager")
		for i in range(1, 7):
			gm.unlock_level(i)
		print("Cheats: All levels unlocked!")

func _on_cheat_kill_enemies():
	get_tree().call_group("enemies", "die")
	print("Cheats: All enemies killed!")

func _on_cheat_level_up():
	if player:
		player.level_up()
		print("Cheats: Level Up!")

func _on_cheat_heal():
	if player:
		player.health = player.max_health
		update_health(player.health, player.max_health)
		print("Cheats: Healed!")


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
			selected_button_index = available_upgrades.size() - 1  # Wrap to bottom
		_highlight_selected_button()
	
	# Down arrow - move selection down
	elif Input.is_action_just_pressed("ui_down"):
		selected_button_index += 1
		if selected_button_index >= available_upgrades.size():
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

func _pick_special_rewards():
	available_upgrades.clear()
	# Show all special weapons (up to 3 for now, or just pick random 3 if more)
	var shuffled = special_weapons.duplicate()
	shuffled.shuffle()
	
	for i in range(min(3, shuffled.size())):
		available_upgrades.append(shuffled[i])
		
	# Update button texts
	for i in range(3):
		if i < available_upgrades.size():
			upgrade_buttons[i].text = "NEW WEAPON: " + available_upgrades[i]["name"]
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
	is_special_reward = false
	current_level += 1
	level_label.text = "Level: " + str(current_level)
	
	# Pick 3 random upgrades
	_pick_random_upgrades()
	
	_show_panel_common()

func show_special_reward_panel():
	is_special_reward = true
	current_level += 1 # Still increment level
	level_label.text = "Level: " + str(current_level) + " - SPECIAL REWARD!"
	
	_pick_special_rewards()
	
	_show_panel_common()

func _show_panel_common():
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
	if is_special_reward:
		# Find the weapon scene path
		var weapon_scene_path = ""
		for w in special_weapons:
			if w["id"] == selected_upgrade:
				weapon_scene_path = w["scene"]
				break
		
		if weapon_scene_path != "":
			var weapon_scene = load(weapon_scene_path)
			if weapon_scene:
				var weapon = weapon_scene.instantiate()
				player.add_weapon(weapon)
				print("Added new weapon: ", selected_upgrade)
	else:
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
