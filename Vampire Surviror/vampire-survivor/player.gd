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

# Weapon container
var weapons_container: Node2D

signal player_died

func _ready():
	add_to_group("player")
	
	# Create weapons container
	weapons_container = Node2D.new()
	weapons_container.name = "Weapons"
	add_child(weapons_container)
	
	# Add default weapon (Projectile/Wand - we need to keep the original one or make a new one)
	# For now, let's give them the Orbit weapon as a starter since we have it, 
	# OR we can wrap the old projectile logic into a "Wand" weapon.
	# Let's give them the Orbit weapon for now to test the new system.
	# Actually, the user asked for "new levels... make new levels unlockable... make more unique enemys... Add different attacks that can be earned every 10 levels".
	# It implies the base game still exists. I should probably keep the base shooting logic OR convert it to a "Wand" weapon.
	# Converting to Wand weapon is cleaner but might break things if I don't do it right.
	# Let's keep the base shooting logic for now as a "default attack" and add the new ones as extras.
	# Wait, the plan said "Remove hardcoded shooting logic". I should stick to the plan.
	# I'll create a simple "Wand" weapon that does what the old code did.
	
	# Add a default Wand weapon
	var wand = preload("res://weapons/Wand.tscn").instantiate()
	add_weapon(wand)

func _physics_process(delta):
	# Movement
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("ui_left", "ui_right")
	input_vector.y = Input.get_axis("ui_up", "ui_down")
	
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
	# Apply player stats to weapon if needed

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
	health -= amount
	if health < 0:
		health = 0
	
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
	match upgrade_name:
		"player_speed":
			speed += 30.0
			print("Player speed increased to ", speed)
		"max_health":
			max_health += 20.0
			health += 20.0  # Also heal for the increase
			print("Max health increased to ", max_health)
		"health_regen":
			health_regen += 2.0
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
