extends Weapon

@export var projectile_scene: PackedScene = preload("res://Projectile.tscn")
@export var projectile_speed: float = 300.0
@export var projectile_count: int = 1

func attack():
	super.attack()
	
	if not projectile_scene: return
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	var breakables = get_tree().get_nodes_in_group("breakables")
	var targets = enemies + breakables
	if targets.is_empty(): return
	
	# Sort by distance
	targets.sort_custom(func(a, b): 
		return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
	)
	
	for i in range(min(projectile_count, targets.size())):
		var proj = projectile_scene.instantiate()
		get_tree().current_scene.add_child(proj)
		proj.global_position = global_position
		
		var target = targets[i].global_position
		var dir = (target - global_position).normalized()
		
		# Assuming Projectile.gd has a setup method
		if proj.has_method("setup"):
			proj.setup(dir, projectile_speed, damage)

func apply_upgrade(upgrade_name: String):
	super.apply_upgrade(upgrade_name)
	match upgrade_name:
		"projectile_speed":
			projectile_speed += 100.0
		"projectile_count":
			projectile_count += 1
