
# =============================================================================
# PLAYER.GD - Player Controller
# =============================================================================
extends CharacterBody2D

const MOVE_SPEED := 300.0
const JUMP_VELOCITY := -650.0
const DOUBLE_JUMP_VELOCITY := -550.0
const GRAVITY := 1500.0
const SCREEN_WIDTH := 480

var has_double_jump: bool = false


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_jump()
	_handle_movement()
	_handle_screen_wrap()
	move_and_slide()


func _apply_gravity(delta: float) -> void:
	velocity.y += GRAVITY * delta


func _handle_jump() -> void:
	# Reset double jump when landing on floor
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
		has_double_jump = true
	# Double jump in air when space is pressed
	elif Input.is_action_just_pressed("ui_accept") and has_double_jump:
		velocity.y = DOUBLE_JUMP_VELOCITY
		has_double_jump = false


func _handle_movement() -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * MOVE_SPEED


func _handle_screen_wrap() -> void:
	if position.x < 0:
		position.x = SCREEN_WIDTH
	elif position.x > SCREEN_WIDTH:
		position.x = 0 
