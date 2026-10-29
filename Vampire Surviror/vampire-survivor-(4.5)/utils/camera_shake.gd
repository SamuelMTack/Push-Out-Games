extends Node

# How quickly the shaking stops [0, 1].
@export var decay = 0.8
# Maximum hor/ver shake in pixels.
@export var max_offset = Vector2(100, 75)
# Maximum rotation in radians (use sparingly).
@export var max_roll = 0.1

var trauma = 0.0  # Current shake strength [0, 1]
var trauma_power = 2  # Trauma exponent. Use [2, 3].

@onready var camera = get_parent()

func _ready():
	pass

func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)

func _process(delta):
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()

func shake():
	var amount = pow(trauma, trauma_power)
	camera.rotation = max_roll * amount * randf_range(-1, 1)
	camera.offset.x = max_offset.x * amount * randf_range(-1, 1)
	camera.offset.y = max_offset.y * amount * randf_range(-1, 1)
