extends CharacterBody2D

@export var ball_path: NodePath
@export var speed := 300.0

var ball: CharacterBody2D
var middle_line := 500.0
var screen_width := 1000.0
var ai_side_boundary := 500.0  # AI can move left to middle line

func _ready():
	# Try multiple ways to get the ball reference
	if ball_path != NodePath():
		ball = get_node(ball_path)
	else:
		# Fallback: find ball by name
		ball = get_parent().get_node("Ball")

	if not ball:
		print("AI: Could not find ball!")
	else:
		print("AI: Found ball at ", ball.position)

func _physics_process(delta):
	# Always try to find ball if we don't have it
	if not ball:
		ball = get_parent().get_node_or_null("Ball")
		if not ball:
			return

	# Complex AI movement - move in all directions like player
	var movement_direction := Vector2.ZERO

	# Get ball and AI positions
	var ball_pos = ball.position
	var ai_center = position + Vector2(10, 50)  # Account for paddle center

	# Predict ball trajectory
	var predicted_ball_pos = ball_pos
	if ball.velocity.x > 0:  # Ball coming toward AI
		var time_to_reach = (ai_center.x - ball_pos.x) / ball.velocity.x
		if time_to_reach > 0 and time_to_reach < 3.0:
			predicted_ball_pos = ball_pos + (ball.velocity * time_to_reach)

	# Vertical movement (primary) - follow predicted ball Y position
	var y_difference = predicted_ball_pos.y - ai_center.y
	if abs(y_difference) > 15:  # Movement threshold
		movement_direction.y = sign(y_difference)

	# Horizontal movement (secondary) - strategic positioning
	var optimal_x = 750  # Preferred X position for defense
	var x_difference = optimal_x - ai_center.x

	# Move horizontally for better positioning
	if abs(x_difference) > 30:
		movement_direction.x = sign(x_difference) * 0.6  # Slower horizontal movement

	# If ball is very close, move more aggressively toward it
	if ball_pos.distance_to(ai_center) < 150 and ball.velocity.x > 0:
		var direct_to_ball = (ball_pos - ai_center).normalized()
		movement_direction = movement_direction * 0.5 + direct_to_ball * 0.5

	# Apply movement
	velocity = movement_direction * speed
	move_and_slide()

	# Keep AI on right side of court and within screen bounds
	position.x = clamp(position.x, ai_side_boundary + 20, screen_width - 40)
	position.y = clamp(position.y, 40, 560)