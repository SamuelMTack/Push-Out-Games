extends Area2D

var damage = 20.0
var velocity = Vector2(100, -500) # Up and slightly right
var gravity = 800.0
var rotation_speed = 10.0

func _ready():
	# Randomize X velocity slightly
	velocity.x = randf_range(-150, 150)
	
	connect("body_entered", _on_body_entered)
	
	# Delete after 3 seconds
	await get_tree().create_timer(3.0).timeout
	queue_free()

func _process(delta):
	velocity.y += gravity * delta
	position += velocity * delta
	rotation += rotation_speed * delta

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
		# Axes usually pierce infinite enemies
