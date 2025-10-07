extends StaticBody2D
class_name PlatformBase

@export var platform_color: Color = Color.GRAY

@onready var sprite: ColorRect = $ColorRect
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready():
	if sprite:
		sprite.color = platform_color

func _on_body_entered(body: Node2D):
	# Override in child classes
	pass