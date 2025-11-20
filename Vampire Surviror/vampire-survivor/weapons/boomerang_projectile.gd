extends Area2D

var damage: float = 0.0
var speed: float = 0.0
var max_distance: float = 0.0
var return_speed: float = 0.0
var owner_weapon: Node2D

var start_pos: Vector2
var direction: Vector2
var returning: bool = false
var distance_traveled: float = 0.0

func setup(dmg, spd, dist, ret_spd, owner_ref):
	damage = dmg
	speed = spd
	max_distance = dist
	return_speed = ret_spd
	owner_weapon = owner_ref
	
	start_pos = global_position
	direction = Vector2.RIGHT.rotated(rotation)
	
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	var current_speed = return_speed if returning else speed
	
	if returning:
		if is_instance_valid(owner_weapon) and is_instance_valid(owner_weapon.player):
			var target = owner_weapon.player.global_position
			direction = (target - global_position).normalized()
			position += direction * current_speed * delta
			
			if global_position.distance_to(target) < 20:
				queue_free()
		else:
			queue_free()
	else:
		position += direction * current_speed * delta
		distance_traveled += current_speed * delta
		
		if distance_traveled >= max_distance:
			returning = true

	rotation += 10.0 * delta

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
