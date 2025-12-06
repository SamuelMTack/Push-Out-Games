extends "res://weapons/weapon.gd"

@export var projectile_scene: PackedScene = preload("res://weapons/projectiles/AxeProjectile.tscn")

func attack():
	if not projectile_scene: return
	
	# Fire upwards with random X spread
	var direction = Vector2.UP
	
	# Spawn projectile
	var proj = projectile_scene.instantiate()
	get_tree().current_scene.add_child(proj)
	proj.global_position = global_position
	proj.damage = damage
	proj.scale = Vector2(scale.x, scale.y)
	
	# Axe logic handled in projectile
	
	super.attack()
