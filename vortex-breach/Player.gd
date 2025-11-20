extends CharacterBody3D

# Movement
const WALK_SPEED = 5.0
const SPRINT_MULTIPLIER = 1.5
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.003

# Stamina
var max_stamina = 100.0
var stamina = 100.0
var stamina_drain_rate = 20.0
var stamina_regen_rate = 15.0
var can_sprint = true

# Health
var max_health = 100.0
var health = 100.0

# Shooting
var max_ammo = 100
var current_ammo = 100
var base_bullet_damage = 10.0
var base_bullet_speed = 50.0
var base_fire_rate = 0.2
var base_bullet_range = 100.0
var base_bullet_spread = 0.0
var fire_rate_timer = 0.0

# Power-ups (multipliers)
var speed_multiplier = 1.0
var jump_multiplier = 1.0
var bullet_damage_multiplier = 1.0
var bullet_speed_multiplier = 1.0
var fire_rate_multiplier = 1.0
var bullet_spread_bonus = 0.0
var active_powerup = ""
var powerup_timer = 0.0

# Currency
var gold = 0

# References
@onready var camera = $Camera3D
@onready var gun = $Camera3D/Gun
@onready var muzzle = $Camera3D/Gun/Muzzle
@onready var raycast = $Camera3D/RayCast3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var bullet_scene = preload("res://Bullet.tscn")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta):
	# Fire rate timer
	if fire_rate_timer > 0:
		fire_rate_timer -= delta
	
	# Powerup timer
	if powerup_timer > 0:
		powerup_timer -= delta
		if powerup_timer <= 0:
			clear_powerup()
	
	# Shooting
	if Input.is_action_pressed("shoot") and fire_rate_timer <= 0:
		shoot()
		fire_rate_timer = base_fire_rate / fire_rate_multiplier

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY * jump_multiplier
	
	# Sprinting and Stamina
	var is_sprinting = Input.is_action_pressed("sprint") and can_sprint and stamina > 0
	var stamina_changed = false
	
	if is_sprinting:
		stamina -= stamina_drain_rate * delta
		stamina_changed = true
		if stamina <= 0:
			stamina = 0
			can_sprint = false
	else:
		if stamina < max_stamina:
			stamina += stamina_regen_rate * delta
			stamina_changed = true
			if stamina >= max_stamina:
				stamina = max_stamina
				can_sprint = true
	
	# Movement
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var current_speed = WALK_SPEED * speed_multiplier
	if is_sprinting:
		current_speed *= SPRINT_MULTIPLIER
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	move_and_slide()
	
	# Only update UI when stamina changes (not every frame)
	if stamina_changed:
		update_ui()

func shoot():
	var bullet_damage = base_bullet_damage * bullet_damage_multiplier
	var bullet_speed = base_bullet_speed * bullet_speed_multiplier
	var bullet_range = base_bullet_range
	var spread = base_bullet_spread + bullet_spread_bonus
	
	# Low ammo penalty
	if current_ammo <= 0:
		bullet_damage *= 0.3
		bullet_range *= 0.4
	else:
		current_ammo -= 1
	
	# Create bullet
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_transform.origin = muzzle.global_transform.origin
	
	# Apply spread
	var spread_offset = Vector3(
		randf_range(-spread, spread),
		randf_range(-spread, spread),
		0
	)
	var direction = -camera.global_transform.basis.z + spread_offset
	direction = direction.normalized()
	
	bullet.set_properties(direction, bullet_speed, bullet_damage, bullet_range)
	
	# Muzzle flash effect (you can add particles here)
	play_shoot_animation()

func play_shoot_animation():
	# Simple gun recoil animation
	var tween = create_tween()
	tween.tween_property(gun, "position", gun.position + Vector3(0, 0, 0.1), 0.05)
	tween.tween_property(gun, "position", gun.position, 0.1)

func take_damage(damage: float):
	health -= damage
	if health <= 0:
		health = 0
		die()
	update_ui()

func die():
	# Game over logic
	print("Player died!")
	get_tree().reload_current_scene()

func add_gold(amount: int):
	gold += amount
	update_ui()

func add_ammo(amount: int):
	current_ammo = min(current_ammo + amount, max_ammo)
	update_ui()

func apply_powerup(powerup_type: String, duration: float):
	clear_powerup()
	active_powerup = powerup_type
	powerup_timer = duration
	
	match powerup_type:
		"speed":
			speed_multiplier = 1.5
		"jump":
			jump_multiplier = 1.5
		"damage":
			bullet_damage_multiplier = 2.0
		"spread":
			bullet_spread_bonus = -0.05  # Tighter spread
		"bullet_speed":
			bullet_speed_multiplier = 1.5
		"fire_rate":
			fire_rate_multiplier = 2.0
	
	update_ui()

func clear_powerup():
	speed_multiplier = 1.0
	jump_multiplier = 1.0
	bullet_damage_multiplier = 1.0
	bullet_spread_bonus = 0.0
	bullet_speed_multiplier = 1.0
	fire_rate_multiplier = 1.0
	active_powerup = ""

func update_ui():
	var ui = get_node_or_null("/root/World/UI")
	if ui and ui.has_method("update_health"):
		ui.update_health(health, max_health)
		ui.update_stamina(stamina, max_stamina)
		ui.update_ammo(current_ammo, max_ammo)
		ui.update_gold(gold)
		ui.update_powerup(active_powerup, powerup_timer)
