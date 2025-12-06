extends "res://weapons/weapon.gd"

var projectile_scene = preload("res://weapons/projectiles/HolyWaterProjectile.tscn")

func attack():
	super.attack()
	
	# Find random enemy or random position
	var target_pos = Vector2.ZERO
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	if not enemies.is_empty():
		# Pick random enemy
		var enemy = enemies.pick_random()
		target_pos = enemy.global_position
	else:
		# Random position near player
		var offset = Vector2(randf_range(-100, 100), randf_range(-100, 100))
		target_pos = global_position + offset
		
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	
	# Calculate stats
	var final_damage = damage
	# Crit check could be here or in zone. Let's pass it to projectile -> zone
	
	projectile.setup(target_pos, final_damage, 3.0, scale.x, get_crit_chance(), get_crit_multiplier())
	get_tree().current_scene.add_child(projectile)
