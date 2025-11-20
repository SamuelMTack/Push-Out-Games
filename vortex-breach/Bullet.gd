extends Area3D

var direction = Vector3.ZERO
var speed = 50.0
var damage = 10.0
var max_range = 100.0
var traveled_distance = 0.0

func _ready():
	body_entered.connect(_on_body_entered)

func set_properties(dir: Vector3, spd: float, dmg: float, rng: float):
	direction = dir
	speed = spd
	damage = dmg
	max_range = rng

func _process(delta):
	var movement = direction * speed * delta
	global_transform.origin += movement
	traveled_distance += movement.length()
	
	if traveled_distance >= max_range:
		queue_free()

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	# Don't destroy bullet if it hits player
	if not body.is_in_group("Player"):
		queue_free()
