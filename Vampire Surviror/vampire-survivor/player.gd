extends CharacterBody2D

@export var speed = 200.0
@export var max_health = 100.0
@export var projectile_scene: PackedScene = preload("res://Projectile.tscn")

var health = max_health
var experience = 0.0
var exp_to_next_level = 10.0

# Weapon stats
var shoot_interval = 2.0  # Shoots every 2 seconds
var shoot_timer = 0.0
var projectile_damage = 15.0
var projectile_count = 1
var projectile_speed = 300.0
var projectile_pierce = 1  # How many enemies a projectile can hit
var projectile_size = 1.0  # Scale multiplier for projectiles


# Player stats
var pickup_range = 50.0  # Range for auto-collecting experience
var health_regen = 0.0  # Health regeneration per second


func _ready():
	add_to_group("player")
	shoot_timer = shoot_interval  # Start ready to shoot

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
	
	
	# Auto-shoot timer
	shoot_timer -= delta
	if shoot_timer <= 0:
		shoot_projectiles()
		shoot_timer = shoot_interval

func shoot_projectiles():
	
	if not projectile_scene:
		print("Error: projectile_scene not assigned!")
		return
	
	# Find all enemies
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return
	
	# Sort enemies by distance to find nearest ones
	enemies.sort_custom(func(a, b): 
		return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
	)
	
	# Shoot projectiles at nearest enemies (based on projectile_count)
	for i in range(min(projectile_count, enemies.size())):
		# Create new projectile instance
		var projectile = projectile_scene.instantiate()
		
		# Add to scene tree (same parent as player)
		get_parent().add_child(projectile)
		
		# Spawn projectile at player's position
		projectile.global_position = global_position
		
		# Calculate direction from player to enemy (locked at firing time)
		var target_position = enemies[i].global_position
		var direction = (target_position - global_position).normalized()
		
		# Initialize the projectile with direction and stats
		projectile.setup(direction, projectile_speed, projectile_damage)
		
		print("Projectile fired from ", global_position, " toward enemy at ", target_position)
		
func add_experience(amount):
	experience += amount
	
	# Update UI
	get_tree().call_group("ui", "update_experience", experience, exp_to_next_level)
	
	if experience >= exp_to_next_level:
		level_up()

func level_up():
	# Reset experience
	experience = 0.0
	exp_to_next_level += 5.0  # Increase requirement for next level
	
	# Full heal
	health = max_health
	get_tree().call_group("ui", "update_health", health, max_health)
	
	# Show level up panel
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
	# Game over - reload scene
	get_tree().paused = false
	get_tree().reload_current_scene()

func apply_upgrade(upgrade_name: String):
	match upgrade_name:
		"projectile_speed":
			projectile_speed += 100.0
			print("Projectile speed increased to ", projectile_speed)
		"projectile_damage":
			projectile_damage += 10.0
			print("Projectile damage increased to ", projectile_damage)
		"projectile_count":
			projectile_count += 1
			print("Projectile count increased to ", projectile_count)
		"attack_speed":
			shoot_interval = max(0.3, shoot_interval - 0.3)
			print("Attack speed increased, interval now ", shoot_interval)
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
		"projectile_pierce":
			projectile_pierce += 1
			print("Projectile pierce increased to ", projectile_pierce)
		"projectile_size":
			projectile_size += 0.3
			print("Projectile size increased to ", projectile_size)
	
	# Update health UI
	get_tree().call_group("ui", "update_health", health, max_health)
