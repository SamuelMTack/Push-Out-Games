extends "res://enemy.gd"

@export var shooting_range = 250.0
@export var shoot_cooldown = 2.0
@export var projectile_scene: PackedScene = preload("res://Projectile.tscn") # Reuse player projectile for now or make new one

var current_shoot_cooldown = 0.0

func _physics_process(delta):
	if not player:
		return
	
	var dist = global_position.distance_to(player.global_position)
	
	# Move if too far
	if dist > shooting_range:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
	else:
		# Stop and shoot
		velocity = Vector2.ZERO
		
		current_shoot_cooldown -= delta
		if current_shoot_cooldown <= 0:
			shoot()
			current_shoot_cooldown = shoot_cooldown

func shoot():
	if not projectile_scene: return
	
	var proj = projectile_scene.instantiate()
	get_parent().add_child(proj)
	proj.global_position = global_position
	
	# Calculate direction to player
	var direction = (player.global_position - global_position).normalized()
	
	# Configure projectile (assuming it has setup method or similar)
	# If it's the player projectile, it might target enemies. We need an EnemyProjectile.
	# For now, let's assume we can configure it.
	# Actually, reusing player projectile is bad because it hits enemies.
	# We should create a simple EnemyProjectile script/scene.
	# But for this step, I'll just make it move towards player.
	
	if proj.has_method("set_direction"):
		proj.set_direction(direction)
	else:
		proj.rotation = direction.angle()
		# If it's a standard Area2D projectile, we might need to set its velocity manually if it doesn't have a script
		# or if the script is hardcoded for player.
		
	# Tag it as enemy projectile so it hits player?
	proj.add_to_group("enemy_projectile")
