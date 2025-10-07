# player.gd
# Example player script that works with all platform types
extends CharacterBody2D

@export var base_speed: float = 300.0
@export var jump_velocity: float = -400.0

var current_speed: float = base_speed
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	set_meta("base_speed", base_speed)
	set_meta("current_speed", current_speed)

func _physics_process(delta):
	# Update current speed from metadata (for platform effects)
	if has_meta("current_speed"):
		current_speed = get_meta("current_speed")
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
	
	# Handle horizontal movement
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
	
	move_and_slide()

# Optional: Custom method for bounce platform
func apply_bounce(force: float):
	velocity.y = force

# Optional: Custom methods for speed platforms
func apply_speed_boost(multiplier: float, duration: float):
	current_speed = base_speed * multiplier
	set_meta("current_speed", current_speed)
	await get_tree().create_timer(duration).timeout
	current_speed = base_speed
	set_meta("current_speed", current_speed)

func apply_slow(multiplier: float, duration: float):
	current_speed = base_speed * multiplier
	set_meta("current_speed", current_speed)
	await get_tree().create_timer(duration).timeout
	current_speed = base_speed
	set_meta("current_speed", current_speed)