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
		bomb.setup(damage, explosion_radius, fuse_time)
