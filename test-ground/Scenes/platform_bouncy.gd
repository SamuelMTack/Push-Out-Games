# bouncy_platform.gd
extends StaticBody2D

@export var platform_size: Vector2 = Vector2(200, 30)
@export var platform_color: Color = Color.ORANGE
@export var bounce_force: float = -800.0  # Negative for upward bounce

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
	
	# Connect body entered signal
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if body.has_method("apply_bounce"):
		body.apply_bounce(bounce_force)
	elif body is CharacterBody2D:
		# Apply bounce directly to velocity
		body.velocity.y = bounce_force
