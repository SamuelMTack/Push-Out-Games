extends Area2D

signal player_hit

@export var wall_type: String = "vertical"
@export var wall_side: String = "left"

@onready var collision_shape = $WallTrapCollision
@onready var visual = $WallTrapVisual

func _ready():
	body_entered.connect(_on_player_entered)

	if visible:
		get_tree().create_timer(3.0).timeout.connect(queue_free)

func setup_wall():
	# Wait for nodes to be ready
	await get_tree().process_frame

	if not collision_shape or not is_instance_valid(collision_shape):
		collision_shape = get_node_or_null("WallTrapCollision")
	if not visual or not is_instance_valid(visual):
		visual = get_node_or_null("WallTrapVisual")

	if not collision_shape or not collision_shape.shape:
		return

	var shape = collision_shape.shape
	if not shape is RectangleShape2D:
		return

	var rect_shape = shape as RectangleShape2D

	match wall_type:
		"vertical":
			rect_shape.size = Vector2(40, 600)
			visual.size = Vector2(40, 600)
			visual.position = Vector2(-20, -300)

			match wall_side:
				"left":
					position = Vector2(20, 300)
				"right":
					position = Vector2(980, 300)

		"horizontal":
			rect_shape.size = Vector2(1000, 40)
			visual.size = Vector2(1000, 40)
			visual.position = Vector2(-500, -20)

			match wall_side:
				"top":
					position = Vector2(500, 20)
				"bottom":
					position = Vector2(500, 580)

func _on_player_entered(body):
	if body.name.contains("Player"):
		player_hit.emit()