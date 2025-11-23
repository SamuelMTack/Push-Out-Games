extends "res://weapons/weapon.gd"

@export var projectile_scene: PackedScene = preload("res://weapons/projectiles/KnifeProjectile.tscn")

func attack():
	if not projectile_scene: return
	
	# Fire in facing direction
	var direction = Vector2.RIGHT
	# Try to get player facing direction if possible, or just aim at nearest enemy
	# Knives usually aim at nearest enemy or facing direction. 
	# In VS, they aim at facing direction.
	
	# Let's assume player has a "last_movement_vector" or similar, or we use mouse?
	# VS uses movement direction.
	if player and "velocity" in player:
		if player.velocity.length() > 0:
			direction = player.velocity.normalized()
		else:
			# If standing still, use last known or default
			# We can store last_dir in player
			pass
			
	# Spawn projectile
	var proj = projectile_scene.instantiate()
	get_tree().current_scene.add_child(proj)
	proj.global_position = global_position
	proj.rotation = direction.angle()
	proj.direction = direction
	proj.damage = damage
	
	# Apply size
	proj.scale = Vector2(scale.x, scale.y)
	
	super.attack()
