extends CharacterBody2D

const SPEED = 150
const JUMP_VELOCITY = -250
const friction = 600
const acceleration = 800
const gravity = 900

var animation_locked : bool
var direction : float 
var in_air : bool
var jump_score = 2
var jump_attack_playing : bool

@onready var animated_sprite = $AnimatedSprite2D2
@onready var hitbox_shape = $Hitbox/CollisionShape2D2

func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		in_air = true
	elif in_air == true:
		land()
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump()
		
	if Input.is_action_just_pressed("jump") and !is_on_floor():
		double_jump()
	
	if Input.is_action_just_pressed("Attack"):
		attack()
	
	# Get the input direction and handle the movement/deceleration.
	direction = Input.get_axis("move_left", "move_right")
		
		
	if direction != 0 and animated_sprite.animation != "land" and animated_sprite.animation != "attack":
		velocity.x = move_toward(velocity.x, direction * SPEED, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		
		#if direction != 0 and animated_sprite.animation != "land" and animated_sprite.animation != "attack":
		#velocity.x = move_toward(velocity.x, direction * SPEED, acceleration * delta)
	#else:
		#velocity.x = move_toward(velocity.x, 0, friction * delta)
		
	move_and_slide()
	update_animation()
		
	
func update_animation():
	if direction > 0:
		animated_sprite.flip_h = false
		hitbox_shape
	
	if direction < 0:
		animated_sprite.flip_h = true
		
		
	if direction == 0 and is_on_floor() and animation_locked == false:
		animated_sprite.play("idle")
	
	if direction != 0 and is_on_floor() and animation_locked == false:
		animated_sprite.play("run")
	
func jump():
	velocity.y = JUMP_VELOCITY
	animated_sprite.play("jump")
	jump_score = 1
	
	
func double_jump():
	if jump_score == 1:
		velocity.y = JUMP_VELOCITY
		animated_sprite.play("jump")
		jump_score = 0
		
		
func land():
	if animated_sprite.animation != "attack" and jump_score < 1:
		animated_sprite.play("land")
		animation_locked = true
		in_air = false
		jump_score = 2
	elif animated_sprite.animation == "attack":
		in_air = false
		
		
		
func attack():
	animated_sprite.play("attack")
	animation_locked = true
	hitbox_shape.disabled = false
	
	
func _on_animated_sprite_2d_2_animation_finished():
	if(animated_sprite.animation == "land"):
		animation_locked = false
	if(animated_sprite.animation == "attack"):
		animation_locked = false
		hitbox_shape.disabled = true
		


	
		
		
		
		
		
		
		
		
		
