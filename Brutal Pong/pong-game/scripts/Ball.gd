extends CharacterBody2D

@export var speed := 600.0
@export var player_score: Label
@export var ai_score: Label

var direction := Vector2.LEFT
var initial_position := Vector2.ZERO
var external_force := Vector2.ZERO
var force_decay := 0.95
var min_speed := 300.0
var max_speed := 1200.0
var is_resetting := false

func _ready():
	initial_position = position
	start_ball()

func start_ball():
	position = initial_position
	# Random direction either left or right
	direction = Vector2.LEFT if randf() > 0.5 else Vector2.RIGHT
	# Add some random vertical movement
	direction.y = randf_range(-0.3, 0.3)
	direction = direction.normalized()
	
	# Don't reset scores - they persist across rounds

func _physics_process(delta):
	# Don't process physics if ball is resetting
	if is_resetting:
		return

	# Apply external forces and decay them
	direction += external_force * delta
	external_force *= force_decay
	direction = direction.normalized()

	# Clamp speed to reasonable bounds
	speed = clamp(speed, min_speed, max_speed)
	velocity = direction * speed

	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()

		if collider is CharacterBody2D and collider.name.contains("Player"):
			# Handle both Player1 (left) and Player2 (right) paddles correctly
			var paddle_center = collider.position

			# Determine which paddle and bounce accordingly
			if collider.name == "Player1":
				# Player1 is on the left - ball should always bounce right
				direction.x = abs(direction.x)
			elif collider.name == "Player2":
				# Player2 is on the right - ball should always bounce left
				direction.x = -abs(direction.x)
			else:
				# Generic player - determine by position
				if paddle_center.x < 500:  # Left side paddle
					direction.x = abs(direction.x)  # Bounce right
				else:  # Right side paddle
					direction.x = -abs(direction.x)  # Bounce left

			# Add some angle based on where the ball hit the paddle
			var paddle_y_center = collider.position.y + 50
			var ball_relative = position.y - paddle_y_center
			direction.y += ball_relative * 0.008  # Reduced influence
			direction = direction.normalized()

			# Increase speed slightly
			speed = min(speed * 1.05, max_speed)

			# Move ball away from paddle to prevent multiple collisions
			var separation_distance = 20
			position += direction * separation_distance

			# Ensure ball stays within valid game bounds after paddle collision
			position.x = clamp(position.x, 10, 990)
			position.y = clamp(position.y, 20, 580)
		elif collider.name == "Ceiling" or collider.name == "Floor":
			# Bounce off ceiling/floor
			direction.y = -direction.y
		elif collider is StaticBody2D and (collider.name.contains("Spike") or collider.get_class() == "StaticBody2D"):
			# Spike collision - work exactly like paddle
			var collision_normal = collision.get_normal()

			# If collision normal is invalid, calculate manually
			if collision_normal.length() < 0.1:
				var spike_center = collider.position
				collision_normal = (position - spike_center).normalized()

			# Bounce using collision normal - exactly like paddle
			direction = direction.bounce(collision_normal)
			direction = direction.normalized()

			# Speed boost like paddle
			speed = min(speed * 1.2, max_speed)

			# Move ball away from spike
			position += collision_normal * 25

			# Ensure ball stays within valid game bounds after spike collision
			position.x = clamp(position.x, 10, 990)
			position.y = clamp(position.y, 20, 580)

			# Update velocity
			velocity = direction * speed

			# Clear external forces
			external_force = Vector2.ZERO

	# IMPORTANT: Only check for reset AFTER all collision handling is done
	# This prevents reset logic from interfering with spike bounces

	# Additional safety: if ball somehow stops moving, give it a push
	if velocity.length() < 50:  # Very slow or stopped
		direction = direction.normalized()
		if direction.length() < 0.1:  # Direction also corrupted
			direction = Vector2(1, 0)  # Default right
		speed = max(speed, min_speed)
		velocity = direction * speed

	# Check for scoring - use velocity instead of direction for accurate movement detection
	var current_velocity_x = velocity.x

	# Check for scoring - only if ball reaches way past the actual edges AND is actually moving away
	if position.x < -200 and current_velocity_x < 0:  # Ball going left way past left edge
		get_parent().ai_scored()
		reset_ball()
	elif position.x > 1200 and current_velocity_x > 0:  # Ball going right way past right edge
		get_parent().player_scored()
		reset_ball()

	# Safety check: if ball gets to edges but moving wrong way, correct it
	elif position.x < -200 and current_velocity_x > 0:
		position.x = 50  # Move back into play area
	elif position.x > 1200 and current_velocity_x < 0:
		position.x = 950  # Move back into play area

func apply_force(force: Vector2):
	external_force += force

func reset_ball():
	is_resetting = true  # Disable physics during reset
	position = initial_position
	speed = 600.0
	velocity = Vector2.ZERO  # Stop all movement
	external_force = Vector2.ZERO  # Clear any external forces
	# Give a short pause before restarting
	await get_tree().create_timer(1.0).timeout
	is_resetting = false  # Re-enable physics
	start_ball()
