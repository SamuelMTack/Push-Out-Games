extends Area2D

var direction = Vector2.ZERO
var speed = 300.0
var damage = 15.0
var lifetime = 4.0
var pierce_count = 1  # How many enemies it can hit
var hits_remaining = 1  # Remaining hits before destruction


func _ready():
	body_entered.connect(_on_body_entered)

func setup(dir: Vector2, spd: float, dmg: float):
	direction = dir
	speed = spd
	damage = dmg
#	pierce_count = pierce
#	hits_remaining = pierce
	
	# Scale the projectile visual
#	scale = Vector2(size_scale, size_scale)
	
	# Destroy after lifetime
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		body.take_damage(damage)
		
		# Reduce remaining hits
		hits_remaining -= 1
		
		# Only destroy if no hits remaining
		if hits_remaining <= 0:
			queue_free()
