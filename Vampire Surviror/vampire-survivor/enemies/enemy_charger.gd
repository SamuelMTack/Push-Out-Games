extends "res://enemy.gd"

enum State { CHASE, PREPARE, CHARGE, COOLDOWN }
var state = State.CHASE

var charge_speed = 400.0
var normal_speed = 80.0
var charge_direction = Vector2.ZERO
var timer = 0.0

func _ready():
	super._ready()
	speed = normal_speed

func _physics_process(delta):
	if not player: return
	
	match state:
		State.CHASE:
			# Normal movement
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * speed
			move_and_slide()
			
			# Check distance to start charge
			if global_position.distance_to(player.global_position) < 200.0:
				state = State.PREPARE
				timer = 0.5 # Warning time
				modulate = Color.RED # Visual warning
				velocity = Vector2.ZERO
				
		State.PREPARE:
			timer -= delta
			if timer <= 0:
				state = State.CHARGE
				timer = 1.0 # Charge duration
				charge_direction = (player.global_position - global_position).normalized()
				speed = charge_speed
				
		State.CHARGE:
			velocity = charge_direction * speed
			move_and_slide()
			
			timer -= delta
			if timer <= 0:
				state = State.COOLDOWN
				timer = 1.5 # Cooldown
				speed = normal_speed
				modulate = Color.WHITE
				
		State.COOLDOWN:
			# Rest a bit
			velocity = Vector2.ZERO
			timer -= delta
			if timer <= 0:
				state = State.CHASE
	
	# Handle collision damage (inherited from base, but we might want extra damage on charge)
	if state == State.CHARGE:
		# Check collisions manually or rely on base class
		pass
