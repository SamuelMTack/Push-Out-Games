extends Weapon

@export var speed: float = 400.0
@export var range_distance: float = 300.0
@export var return_speed: float = 600.0

var boomerang_scene_ref = preload("res://weapons/BoomerangProjectile.tscn")

func attack():
	super.attack()
	
	if boomerang_scene_ref:
		var proj = boomerang_scene_ref.instantiate()
		get_tree().current_scene.add_child(proj)
		proj.global_position = global_position
		
		# Determine direction (nearest enemy or random)
		var direction = Vector2.RIGHT.rotated(randf() * TAU)
		var enemies = get_tree().get_nodes_in_group("enemies")
		if not enemies.is_empty():
			var nearest = enemies[0]
			var min_dist = global_position.distance_to(nearest.global_position)
			for e in enemies:
				var d = global_position.distance_to(e.global_position)
				if d < min_dist:
					min_dist = d
					nearest = e
			direction = (nearest.global_position - global_position).normalized()
			
		proj.setup(damage, speed, range_distance, return_speed, self)
