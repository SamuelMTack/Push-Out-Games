extends CanvasLayer

@onready var health_bar = %HealthBar
@onready var exp_bar = %ExperienceBar
@onready var level_label = %LevelLabel
@onready var coin_label = %CoinLabel
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
	{"name": "Pickup Range", "id": "pickup_range"}
]

var all_passives = [
	{"name": "Spinach (Might)", "id": "passive_spinach"},
	{"name": "Empty Tome (Cooldown)", "id": "passive_empty_tome"},
	{"name": "Armor", "id": "passive_armor"},
	{"name": "Candelabrador (Area)", "id": "passive_candelabrador"},
	{"name": "Bracer (Speed)", "id": "passive_bracer"},
	{"name": "Duplicator (Amount)", "id": "passive_duplicator"},
	{"name": "Pummarola (Regen)", "id": "passive_pummarola"}
]

# Evolution Recipes: Weapon ID + Passive ID -> Evolved Weapon Scene
var evolutions = {
	"weapon_wand": {"passive": "passive_empty_tome", "result": "res://weapons/WandEvolved.tscn", "name": "Holy Wand"},
	"weapon_sword": {"passive": "passive_armor", "result": "res://weapons/SwordEvolved.tscn", "name": "Heaven Sword"},
	"weapon_bomb": {"passive": "passive_bracer", "result": "res://weapons/BombEvolved.tscn", "name": "Nuke"},
	"weapon_boomerang": {"passive": "passive_candelabrador", "result": "res://weapons/BoomerangEvolved.tscn", "name": "Death Spiral"},
	"weapon_orbit": {"passive": "passive_spinach", "result": "res://weapons/OrbitEvolved.tscn", "name": "Vesper"},
	"weapon_knife": {"passive": "passive_bracer", "result": "res://weapons/KnifeEvolved.tscn", "name": "Thousand Edge"},
	"weapon_axe": {"passive": "passive_candelabrador", "result": "res://weapons/AxeEvolved.tscn", "name": "Death Scythe"},
	"weapon_garlic": {"passive": "passive_pummarola", "result": "res://weapons/GarlicEvolved.tscn", "name": "Soul Eater"},
	"weapon_lightning": {"passive": "passive_duplicator", "result": "res://weapons/LightningEvolved.tscn", "name": "Thunder Loop"}
}

# Special weapons
var special_weapons = [
	{"name": "Sword", "id": "weapon_sword", "scene": "res://weapons/Sword.tscn"},
	{"name": "Bomb", "id": "weapon_bomb", "scene": "res://weapons/Bomb.tscn"},
	{"name": "Boomerang", "id": "weapon_boomerang", "scene": "res://weapons/Boomerang.tscn"},
	{"name": "Orbit Orb", "id": "weapon_orbit", "scene": "res://weapons/OrbitWeapon.tscn"},
	{"name": "Knife", "id": "weapon_knife", "scene": "res://weapons/Knife.tscn"},
	{"name": "Axe", "id": "weapon_axe", "scene": "res://weapons/Axe.tscn"},
	{"name": "Garlic", "id": "weapon_garlic", "scene": "res://weapons/Garlic.tscn"},
	{"name": "Lightning", "id": "weapon_lightning", "scene": "res://weapons/Lightning.tscn"}
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
	
	# Connect to GameManager for coins
	if has_node("/root/GameManager"):
		var gm = get_node("/root/GameManager")
		gm.coins_updated.connect(_on_coins_updated)
		_on_coins_updated(gm.coins) # Set initial value
	
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
	
	var btn_char_select = Button.new()
	btn_char_select.text = "Character Select"
	btn_char_select.pressed.connect(_on_pause_char_select)
	vbox.add_child(btn_char_select)
	
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

	var btn_coins = Button.new()
	btn_coins.text = "Add 9999 Coins"
	btn_coins.pressed.connect(_on_cheat_add_coins)
	vbox.add_child(btn_coins)

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

func _on_pause_char_select():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://character_select.tscn")

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

func _on_cheat_add_coins():
	if has_node("/root/GameManager"):
		get_node("/root/GameManager").add_coins(9999)
		print("Cheats: Added 9999 Coins!")


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
	# Check for evolutions first!
	var evolution_option = _check_for_evolution()
	if evolution_option:
		available_upgrades = [evolution_option]
		# Fill the rest with random upgrades
		var shuffled = all_upgrades + all_passives
		shuffled.shuffle()
		for i in range(2):
			available_upgrades.append(shuffled[i])
	else:
		available_upgrades.clear()
		var shuffled = all_upgrades + all_passives
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

func _on_coins_updated(amount: int):
	if coin_label:
		coin_label.text = "Coins: " + str(amount)

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
	elif selected_upgrade.begins_with("EVO_"):
		# Handle evolution
		var evo_data = available_upgrades[selected_button_index] # This is a bit risky if index changed, but usually safe in this flow
		if evo_data["id"] == selected_upgrade:
			var weapon_scene = load(evo_data["scene"])
			if weapon_scene:
				var weapon = weapon_scene.instantiate()
				# Remove old weapon? Or just add new one? 
				# Usually evolution replaces. For simplicity, let's just add it for now
				# Ideally we should find the old weapon and queue_free() it.
				# Let's try to find and remove the base weapon
				for child in player.weapons_container.get_children():
					if child.weapon_name == evo_data["base_weapon_name"]: # We need to ensure weapon_name matches
						child.queue_free()
						break
				
				player.add_weapon(weapon)
				print("Weapon Evolved!")
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

func _check_for_evolution():
	if not player: return null
	
	for weapon in player.weapons_container.get_children():
		if not weapon is Weapon: continue
		
		# Check if weapon is max level (assuming 8 is max)
		if weapon.level >= 8:
			# Check if we have a recipe for this weapon
			# We need a way to map weapon instance to ID. 
			# Let's assume weapon.name or a new property 'id'
			# For now, let's use a simple mapping based on weapon_name or script path
			var weapon_id = ""
			if "Wand" in weapon.name: weapon_id = "weapon_wand"
			elif "Sword" in weapon.name: weapon_id = "weapon_sword"
			elif "Bomb" in weapon.name: weapon_id = "weapon_bomb"
			elif "Boomerang" in weapon.name: weapon_id = "weapon_boomerang"
			elif "Orbit" in weapon.name: weapon_id = "weapon_orbit"
			elif "Knife" in weapon.name: weapon_id = "weapon_knife"
			elif "Axe" in weapon.name: weapon_id = "weapon_axe"
			elif "Garlic" in weapon.name: weapon_id = "weapon_garlic"
			elif "Lightning" in weapon.name: weapon_id = "weapon_lightning"
			
			if weapon_id in evolutions:
				var recipe = evolutions[weapon_id]
				var required_passive = recipe["passive"]
				
				# Check if player has the passive
				if required_passive in player.passives:
					return {
						"name": "EVOLVE: " + recipe["name"], 
						"id": "EVO_" + weapon_id, 
						"scene": recipe["result"],
						"base_weapon_name": weapon.weapon_name # Store this to remove old one
					}
	return null
