extends Area2D

var speed = 600.0
var damage = 10.0
var direction = Vector2.RIGHT
var pierce = 0 # How many enemies it can hit before destroying

func _ready():
	# Delete after 3 seconds
	await get_tree().create_timer(3.0).timeout
	queue_free()
	
	connect("body_entered", _on_body_entered)

func _process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
		
		if pierce > 0:
			pierce -= 1
		else:
			queue_free()
