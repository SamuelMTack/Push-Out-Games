extends CharacterBody2D

@export var speed := 600.0
@export var player_score: Label
@export var ai_score: Label

var direction := Vector2.LEFT
var initial_position := Vector2.ZERO

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
	
	# Reset scores if needed
	if player_score:
		player_score.text = "0"
	if ai_score:
		ai_score.text = "0"

func _physics_process(delta):
	velocity = direction * speed
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		
		if collider is CharacterBody2D and collider.name.contains("Player"):
			# Bounce off paddle
			direction.x = -direction.x
			# Add some angle based on where the ball hit the paddle
			var paddle_center = collider.position.y
			var ball_relative = position.y - paddle_center
			direction.y = ball_relative * 0.01
			direction = direction.normalized()
			# Increase speed slightly
			speed = min(speed * 1.05, 1000.0)
		elif collider.name == "Ceiling" or collider.name == "Floor":
			# Bounce off ceiling/floor
			direction.y = -direction.y
	
	# Check for scoring
	if position.x < -20:
		# AI scores
		if ai_score:
			ai_score.text = str(int(ai_score.text) + 1)
		reset_ball()
	elif position.x > 1020:
		# Player scores
		if player_score:
			player_score.text = str(int(player_score.text) + 1)
		reset_ball()

func reset_ball():
	position = initial_position
	speed = 600.0
	# Give a short pause before restarting
	await get_tree().create_timer(1.0).timeout
	start_ball()