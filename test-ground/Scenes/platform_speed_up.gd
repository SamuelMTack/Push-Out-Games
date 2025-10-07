# speedup_platform.gd
extends StaticBody2D

@export var platform_size: Vector2 = Vector2(200, 30)
@export var platform_color: Color = Color.GREEN
@export var speed_multiplier: float = 1.5
@export var effect_duration: float = 3.0  # How long the effect lasts

var active_bodies: Dictionary = {}

func _ready():
	# Create visual representation
	var rect = ColorRect.new()
	rect.size = platform_size
	rect.position = -platform_size / 2
	rect.color = platform_color
	add_child(rect)
	
	# Create collision shape
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = platform_size
	collision.shape = shape
	add_child(collision)
	
	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D):
	if body.has_method("apply_speed_boost"):
		body.apply_speed_boost(speed_multiplier, effect_duration)
	elif body.has_meta("base_speed"):
		# Store original speed
		if not active_bodies.has(body):
			var base_speed = body.get_meta("base_speed")
			active_bodies[body] = base_speed
			body.set_meta("current_speed", base_speed * speed_multiplier)

func _on_body_exited(body: Node2D):
	# Start timer to remove speed boost after duration
	if active_bodies.has(body):
		await get_tree().create_timer(effect_duration).timeout
		if body and is_instance_valid(body):
			body.set_meta("current_speed", active_bodies[body])
			active_bodies.erase(body)
