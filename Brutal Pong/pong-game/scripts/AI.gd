extends CharacterBody2D

@export var ball_path: NodePath
@export var speed := 300.0

var ball: CharacterBody2D

func _ready():
	ball = get_node(ball_path)

func _physics_process(delta):
	if not ball:
		return
	
	# Simple AI: follow the ball's y position
	var target_y = ball.position.y
	var current_y = position.y
	
	if abs(target_y - current_y) > 10:
		var direction = sign(target_y - current_y)
		velocity = Vector2(0, direction * speed)
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()
	
	# Keep paddle within screen bounds
	position.y = clamp(position.y, 40, 560)