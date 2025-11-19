
# =============================================================================
# PLATFORM.GD - Platform (Simple)
# =============================================================================
extends StaticBody2D

const MOVE_SPEED := 80.0
const MOVE_RANGE := 60.0

var is_moving: bool = false
var start_y: float = 0.0
var time: float = 0.0


func _ready() -> void:
	start_y = position.y


func _process(delta: float) -> void:
	if is_moving:
		time += delta
		position.y = start_y + sin(time * 2.0) * MOVE_RANGE


func set_moving(moving: bool) -> void:
	is_moving = moving
	
	# Visual indicator for moving platforms (optional)
	if is_moving and has_node("Sprite2D"):
		$Sprite2D.modulate = Color(1.0, 0.7, 0.7)  # Slightly reddish tint
