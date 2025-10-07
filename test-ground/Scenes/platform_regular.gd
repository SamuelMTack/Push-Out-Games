# regular_platform.gd
extends StaticBody2D

@export var platform_size: Vector2 = Vector2(200, 30)
@export var platform_color: Color = Color.GRAY

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