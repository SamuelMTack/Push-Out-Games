extends CharacterBody2D

@export var move_up_action := "ui_up"
@export var move_down_action := "ui_down"
@export var move_left_action := "ui_left"
@export var move_right_action := "ui_right"
@export var speed := 400.0
@export var is_player := true

var screen_width := 1000.0
var middle_line := 500.0
var attack_range := 100.0
var attack_force := 300.0

func _physics_process(_delta):
	var direction := Vector2.ZERO

	# Vertical movement
	if Input.is_action_pressed(move_up_action):
		direction.y -= 1.0
	if Input.is_action_pressed(move_down_action):
		direction.y += 1.0

	# Horizontal movement with middle line restriction
	if is_player:
		if Input.is_action_pressed(move_left_action):
			direction.x -= 1.0
		if Input.is_action_pressed(move_right_action) and position.x < middle_line - 20:
			direction.x += 1.0

	velocity = direction * speed

	# Store previous position to prevent ball from pushing paddle
	var prev_position = position
	move_and_slide()

	# Ensure paddle only moves based on input, not collisions
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider.name == "Ball":
			# Reset position if ball tries to push paddle
			position = prev_position
			break

	# Keep paddle within screen bounds
	position.y = clamp(position.y, 40, 560)

	# Keep player on their side of the court
	if is_player:
		position.x = clamp(position.x, 20, middle_line - 20)

func distance_attack(direction_vector: Vector2):
	var ball = get_parent().get_node("Ball")
	if ball and global_position.distance_to(ball.global_position) <= attack_range:
		if ball.has_method("apply_force"):
			ball.apply_force(direction_vector * attack_force)
