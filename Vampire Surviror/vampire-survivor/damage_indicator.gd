extends Node2D

@onready var label = $Label

var speed = 30.0
var friction = 15.0
var shift_direction = Vector2.ZERO

func _ready():
	shift_direction = Vector2(randf_range(-1, 1), -1).normalized()

func setup(amount: int, start_pos: Vector2):
	global_position = start_pos
	if label:
		label.text = str(amount)
	
	# Animate
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 1.0).set_delay(0.5)
	tween.tween_callback(queue_free).set_delay(1.5)

func _process(delta):
	global_position += shift_direction * speed * delta
	speed = max(0, speed - friction * delta)
