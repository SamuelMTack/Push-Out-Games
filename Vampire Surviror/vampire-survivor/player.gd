extends CharacterBody2D
@export var speed = 200.0
@export var max_health = 100.0
@export var projectile_scene: PackedScene

var health = max_health
var experience = 0
var level = 1
var exp_to_next_level = 5

# Weapon stats
var attack_cooldown = 1.0
var attack_timer = 0.0
var projectile_damage = 10.0
var projectile_count = 1
var projectile_speed = 300.0

func _ready():
	add_to_group("player")

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
	
	# Auto-attack
	attack_timer -= delta
	if attack_timer <= 0:
		shoot_projectiles()
		attack_timer = attack_cooldown

func shoot_projectiles():
	if not projectile_scene:
		return
	
	# Find nearest enemy
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return
	
	# Sort by distance
	enemies.sort_custom(func(a, b): 
		return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
	)
	
	# Shoot at nearest enemies
	for i in range(min(projectile_count, enemies.size())):
		var projectile = projectile_scene.instantiate()
		get_parent().add_child(projectile)
		projectile.global_position = global_position
		
		var direction = (enemies[i].global_position - global_position).normalized()
		projectile.setup(direction, projectile_speed, projectile_damage)

func add_experience(amount):
	experience += amount
	
	if experience >= exp_to_next_level:
		level_up()

func level_up():
	level += 1
	experience = 0
	exp_to_next_level = int(exp_to_next_level * 1.5)
	
	# Notify UI
	get_tree().call_group("ui", "show_level_up")

func take_damage(amount):
	health -= amount
	if health <= 0:
		die()

func die():
	get_tree().reload_current_scene()

func upgrade_stat(stat_name):
	match stat_name:
		"attack_speed":
			attack_cooldown *= 0.8
		"damage":
			projectile_damage += 5
		"speed":
			speed += 20
		"projectile_count":
			projectile_count += 1
		"health":
			max_health += 20
			health = max_health
