extends StaticBody2D

@export var pickup_scene: PackedScene = preload("res://pickups/Pickup.tscn")

func _ready():
	add_to_group("breakables")

func take_damage(amount):
	# Break instantly
	die()

func die():
	if pickup_scene:
		var pickup = pickup_scene.instantiate()
		get_parent().call_deferred("add_child", pickup)
		pickup.global_position = global_position
		
		# Randomize type
		pickup.type = randi() % 4 # 0 to 3
		pickup.update_visuals()
	
	queue_free()
