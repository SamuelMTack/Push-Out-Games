extends Area2D

@export var speed = 300.0
@export var damage = 10.0
@export var lifetime = 5.0

var direction = Vector2.RIGHT

func _ready():
	# Delete after lifetime
	await get_tree().create_timer(lifetime).timeout
	queue_free()
	
	connect("body_entered", _on_body_entered)

func set_direction(dir: Vector2):
	direction = dir
	rotation = dir.angle()

func _process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
	elif body.is_in_group("walls"): # Optional
		queue_free()
