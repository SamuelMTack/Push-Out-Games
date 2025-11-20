extends Weapon

@export var explosion_radius: float = 100.0
@export var fuse_time: float = 2.0

var bomb_scene_ref = preload("res://weapons/BombProjectile.tscn")

func attack():
	super.attack()
	
	if bomb_scene_ref:
		var bomb = bomb_scene_ref.instantiate()
		get_tree().current_scene.add_child(bomb)
		bomb.global_position = global_position
		
		# Throw towards nearest enemy if exists
		var nearest = get_nearest_enemy()
		var target_pos = global_position
		if nearest:
			target_pos = nearest.global_position
			
		# If bomb has a throw mechanism, use it. 
		# For now, we'll just spawn it at player and let it explode, 
		# OR we can tween it to the target.
		# Let's assume we want to throw it.
		if nearest:
			var tween = create_tween()
			tween.tween_property(bomb, "global_position", target_pos, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		
		bomb.setup(damage, explosion_radius, fuse_time)

func apply_upgrade(upgrade_name: String):
	super.apply_upgrade(upgrade_name)
	match upgrade_name:
		"projectile_size":
			explosion_radius += 20.0
