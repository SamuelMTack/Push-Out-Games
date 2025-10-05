extends CharacterBody2D

@export var move_up_action := "ui_up"
@export var move_down_action := "ui_down"
@export var speed := 400.0

func _physics_process(delta):
	var direction = 0.0
	
	if Input.is_action_pressed(move_up_action):
		direction -= 1.0
	if Input.is_action_pressed(move_down_action):
		direction += 1.0
	
	velocity = Vector2(0, direction * speed)
	move_and_slide()
	
	# Keep paddle within screen bounds
	position.y = clamp(position.y, 40, 560)