extends CharacterBody2D

@export var speed = 200.0
@export var max_health = 100.0
@export var projectile_scene: PackedScene

var health = max_health
var experience = 0.0
var exp_to_next_level = 10.0

# Weapon stats
var shoot_interval = 2.0  # Shoots every 2 seconds
var shoot_timer = 0.0
var projectile_damage = 15.0
var projectile_count = 1
var projectile_speed = 300.0

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
	
	# Auto-shoot timer
	shoot_timer -= delta
	if shoot_timer <= 0:
		shoot_projectiles()
		shoot_timer = shoot_interval

func shoot_projectiles():
	if not projectile_scene:
		return
	
	# Find nearest enemies
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return
	
	# Sort by distance to find nearest enemies
	enemies.sort_custom(func(a, b): 
		return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
	)
	
	# Shoot at nearest enemies (based on projectile count)
	for i in range(min(projectile_count, enemies.size())):
		var projectile = projectile_scene.instantiate()
		get_parent().add_child(projectile)
		projectile.global_position = global_position
		
		var direction = (enemies[i].global_position - global_position).normalized()
		projectile.setup(direction, projectile_speed, projectile_damage)

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

func apply_upgrade(upgrade_type: String):
	match upgrade_type:
		"faster":
			projectile_speed += 100.0
		"stronger":
			projectile_damage += 10.0
		"more":
			projectile_count += 1
