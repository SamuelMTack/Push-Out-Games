extends Area2D

var damage = 30.0

func _ready():
	# Play animation then deal damage
	# For now, just a timer
	await get_tree().create_timer(0.2).timeout
	
	# Damage overlapping enemies
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.has_method("take_damage"):
			body.take_damage(damage)
	
	await get_tree().create_timer(0.3).timeout
	queue_free()
