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
		var nearest = get_nearest_enemy()
		if nearest:
			direction = (nearest.global_position - global_position).normalized()
			
		proj.setup(damage, speed, range_distance, return_speed, self)

func apply_upgrade(upgrade_name: String):
	super.apply_upgrade(upgrade_name)
	match upgrade_name:
		"projectile_speed":
			speed += 100.0
			return_speed += 100.0
		"projectile_count":
			# Maybe add more boomerangs? For now just speed/damage
			pass
