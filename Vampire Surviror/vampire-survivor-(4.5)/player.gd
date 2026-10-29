extends CharacterBody2D

@export var speed = 200.0
@export var max_health = 100.0

var health = max_health
var experience = 0.0
var exp_to_next_level = 10.0
var current_level = 1

# Player stats
var pickup_range = 50.0  # Range for auto-collecting experience
var health_regen = 0.0  # Health regeneration per second
var might = 1.0 # Damage multiplier
var area = 1.0 # Area/Size multiplier
var speed_mult = 1.0 # Projectile speed multiplier
var cooldown_mult = 1.0 # Cooldown reduction multiplier (lower is better)
var amount = 0 # Extra projectiles
var luck = 1.0 # Luck multiplier for crits/drops

var passives = {} # Dictionary to track owned passives and their levels

# Weapon container
var weapons_container: Node2D
var camera_shake


signal player_died

func _ready():
	add_to_group("player")
	
	# Create weapons container
	weapons_container = Node2D.new()
	weapons_container.name = "Weapons"
	add_child(weapons_container)
	
	# Add camera shake
	if has_node("Camera2D"):
		var cam = get_node("Camera2D")
		var shake_script = load("res://utils/camera_shake.gd")
		camera_shake = shake_script.new()
		cam.add_child(camera_shake)
	
	# Load Character Data
	if has_node("/root/GameManager"):
		var gm = get_node("/root/GameManager")
		if "selected_character" in gm and "characters" in gm:
			var char_data = gm.characters[gm.selected_character]
			
			# Apply Stats
			max_health = char_data["stats"]["max_health"]
			health = max_health
			speed = char_data["stats"]["speed"]
			might = char_data["stats"]["might"]
			cooldown_mult = char_data["stats"]["cooldown_mult"]
			
			# Add Starting Weapon
			var weapon_path = char_data["weapon"]
			if ResourceLoader.exists(weapon_path):
				var weapon_scene = load(weapon_path)
				var weapon = weapon_scene.instantiate()
				add_weapon(weapon)
			else:
				# Fallback
				var wand = preload("res://weapons/Wand.tscn").instantiate()
				add_weapon(wand)
	else:
		# Fallback if no GameManager (e.g. testing scene directly)
		var wand = preload("res://weapons/Wand.tscn").instantiate()
		add_weapon(wand)

	# Apply Permanent Upgrades from Shop
	if has_node("/root/GameManager"):
		var gm = get_node("/root/GameManager")
		
		# Might
		var might_level = gm.get_upgrade_level("might")
		if might_level > 0:
			might += might_level * 0.1 # +10% per level
			
		# Speed
		var speed_level = gm.get_upgrade_level("speed")
		if speed_level > 0:
			speed += speed_level * 10.0 # +10 speed per level
			
		# Max Health
		var health_level = gm.get_upgrade_level("max_health")
		if health_level > 0:
			max_health += health_level * 10.0 # +10 health per level
			health = max_health # Heal to new max
			
		# Cooldown
		var cooldown_level = gm.get_upgrade_level("cooldown")
		if cooldown_level > 0:
			cooldown_mult *= pow(0.95, cooldown_level) # -5% per level (multiplicative)
			
		# Amount
		var amount_level = gm.get_upgrade_level("amount")
		if amount_level > 0:
			amount += amount_level # +1 projectile per level
			
		# Magnet
		var magnet_level = gm.get_upgrade_level("magnet")
		if magnet_level > 0:
			pickup_range += magnet_level * 10.0 # +10 range per level
			
		# Regen
		var regen_level = gm.get_upgrade_level("regen")
		if regen_level > 0:
			health_regen += regen_level * 0.2 # +0.2 regen per level

func _physics_process(delta):
	# Movement
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("ui_left", "ui_right")
	input_vector.y = Input.get_axis("ui_up", "ui_down")
	
	# Add WASD support
	if Input.is_key_pressed(KEY_A):
		input_vector.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		input_vector.x += 1.0
	if Input.is_key_pressed(KEY_W):
		input_vector.y -= 1.0
	if Input.is_key_pressed(KEY_S):
		input_vector.y += 1.0
	
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		velocity = input_vector * speed
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()
	
	# Health regeneration
	if health_regen > 0 and health < max_health:
		health += health_regen * delta
		if health > max_health:
			health = max_health
		get_tree().call_group("ui", "update_health", health, max_health)

func add_weapon(weapon_instance):
	weapons_container.add_child(weapon_instance)
	# Apply player stats to weapon
	if weapon_instance.has_method("update_stats"):
		weapon_instance.update_stats(self)
	elif weapon_instance is Weapon:
		# Manual application if update_stats missing
		weapon_instance.damage *= might
		weapon_instance.scale *= area
		weapon_instance.cooldown *= cooldown_mult

func add_experience(amount):
	experience += amount
	
	# Track total experience for stats
	var main = get_tree().current_scene
	if main and main.has_method("register_experience_gain"):
		main.register_experience_gain(amount)
	
	# Update UI
	get_tree().call_group("ui", "update_experience", experience, exp_to_next_level)
	
	if experience >= exp_to_next_level:
		level_up()

func level_up():
	current_level += 1
	
	# Reset experience
	experience = 0.0
	exp_to_next_level += 5.0 * current_level # Scale exp requirement
	
	# Full heal
	health = max_health
	get_tree().call_group("ui", "update_health", health, max_health)
	
	# Check for special reward every 10 levels
	if current_level % 10 == 0:
		get_tree().call_group("ui", "show_special_reward_panel")
	else:
		# Show normal level up panel
		get_tree().call_group("ui", "show_level_up_panel")

func take_damage(amount):
	# Apply armor reduction
	# amount = max(1, amount - armor) # If armor implemented
	
	health -= amount
	
	# Shake camera
	if camera_shake:
		camera_shake.add_trauma(0.5)
	
	# Update UI
	get_tree().call_group("ui", "update_health", health, max_health)
	
	if health <= 0:
		die()

func die():
	# Emit death signal
	emit_signal("player_died")
	
	# Notify main scene
	var main = get_tree().current_scene
	if main and main.has_method("_on_player_died"):
		main._on_player_died()
	else:
		# Fallback: just restart
		get_tree().paused = false
		get_tree().reload_current_scene()

func apply_upgrade(upgrade_name: String):
	# Check if it's a passive item upgrade
	if upgrade_name in ["passive_spinach", "passive_empty_tome", "passive_armor", "passive_candelabrador", "passive_bracer", "passive_duplicator"]:
		apply_passive(upgrade_name)
		return

	match upgrade_name:
		"player_speed":
			speed += 30.0
			print("Player speed increased to ", speed)
		"max_health":
			max_health += 20.0
			health += 20.0  # Also heal for the increase
			print("Max health increased to ", max_health)
		"health_regen":
			health_regen += 1.0
			print("Health regen increased to ", health_regen, "/sec")
		"pickup_range":
			pickup_range += 20.0
			print("Pickup range increased to ", pickup_range)
		_:
			# Pass other upgrades to all weapons
			for weapon in weapons_container.get_children():
				if weapon.has_method("apply_upgrade"):
					weapon.apply_upgrade(upgrade_name)
				elif weapon is Weapon:
					# Generic weapon upgrade logic if specific method missing
					if upgrade_name == "projectile_damage":
						weapon.damage += 5.0
					elif upgrade_name == "attack_speed":
						weapon.cooldown *= 0.9

func apply_passive(passive_id: String):
	if passive_id not in passives:
		passives[passive_id] = 0
	passives[passive_id] += 1
	
	match passive_id:
		"passive_spinach": # Might
			might += 0.1
			print("Might increased to ", might)
		"passive_empty_tome": # Cooldown
			cooldown_mult *= 0.9
			print("Cooldown mult reduced to ", cooldown_mult)
		"passive_armor": # Defense (not implemented yet, but good to have)
			# damage_reduction += 1
			pass
		"passive_candelabrador": # Area
			area += 0.1
			print("Area increased to ", area)
		"passive_bracer": # Projectile Speed
			speed_mult += 0.1
			print("Projectile Speed mult increased to ", speed_mult)
		"passive_duplicator": # Amount
			amount += 1
			print("Amount increased to ", amount)
		"passive_pummarola": # Regen
			health_regen += 0.5
			print("Health regen increased to ", health_regen)
		"passive_clover": # Luck
			luck += 0.1
			print("Luck increased to ", luck)
	
	# Re-apply stats to all weapons
	for weapon in weapons_container.get_children():
		if weapon.has_method("update_stats"):
			weapon.update_stats(self)

func get_luck() -> float:
	return 1.0 + (passives.get("passive_clover", 0) * 0.1) # Base 1.0 + 10% per clover level

