# Player.gd
# Attach this to a CharacterBody3D node
extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.003

@onready var camera = $Camera3D
@onready var raycast = $Camera3D/InteractRay
@onready var sword = $Camera3D/Sword
@onready var animation_player = $Camera3D/Sword/AnimationPlayer

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_attacking = false
var health = 100
var max_health = 100
var health_bar = null

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	setup_sword()
	setup_health_bar()
	update_health_bar()

func setup_health_bar():
	# Create UI layer if it doesn't exist
	var ui_layer = get_node_or_null("HealthBarUI")
	if not ui_layer:
		ui_layer = CanvasLayer.new()
		ui_layer.name = "HealthBarUI"
		add_child(ui_layer)
		
		# Create health bar background
		var bg = ColorRect.new()
		bg.color = Color(0.2, 0.2, 0.2, 0.8)
		bg.size = Vector2(210, 30)
		bg.position = Vector2(10, 10)
		ui_layer.add_child(bg)
		
		# Create health bar
		var health_bar_rect = ColorRect.new()
		health_bar_rect.name = "HealthBar"
		health_bar_rect.color = Color(0.8, 0.1, 0.1)
		health_bar_rect.size = Vector2(200, 20)
		health_bar_rect.position = Vector2(15, 15)
		ui_layer.add_child(health_bar_rect)
		health_bar = health_bar_rect  # Assign to our variable
		
		# Create health text
		var health_text = Label.new()
		health_text.name = "HealthText"
		health_text.position = Vector2(15, 15)
		health_text.add_theme_font_size_override("font_size", 16)
		health_text.text = str(health) + " / " + str(max_health)
		ui_layer.add_child(health_text)

func update_health_bar():
	if health_bar:
		var health_percent = float(health) / float(max_health)
		health_bar.size.x = 200 * health_percent
		
		# Change color based on health
		if health_percent > 0.5:
			health_bar.color = Color(0.1, 0.8, 0.1)  # Green
		elif health_percent > 0.25:
			health_bar.color = Color(0.9, 0.7, 0.1)  # Yellow
		else:
			health_bar.color = Color(0.8, 0.1, 0.1)  # Red
	
	# Update health text
	var health_text = get_node_or_null("HealthBarUI/HealthText")
	if health_text:
		health_text.text = str(health) + " / " + str(max_health)

func take_damage(amount):
	health -= amount
	health = max(health, 0)
	update_health_bar()
	print("Player health: ", health)
	
	if health <= 0:
		die()

func heal(amount):
	health = min(health + amount, max_health)
	update_health_bar()
	print("Player healed! Health: ", health)

func die():
	print("Game Over!")
	get_tree().reload_current_scene()

func setup_sword():
	# Create sword mesh if it doesn't exist
	if not sword:
		sword = MeshInstance3D.new()
		sword.name = "Sword"
		camera.add_child(sword)
	
	# Try to load sword.obj file
	var sword_obj_path = "res://sword.obj"
	
	if FileAccess.file_exists(sword_obj_path):
		var mesh = load(sword_obj_path)
		if mesh:
			sword.mesh = mesh
			
			# Apply metallic material
			var material = StandardMaterial3D.new()
			material.albedo_color = Color(0.7, 0.7, 0.75)
			material.metallic = 0.9
			material.roughness = 0.2
			sword.material_override = material
			
			# Adjust scale for .obj model
			sword.scale = Vector3(0.15, 0.15, 0.15)
		else:
			print("Failed to load sword.obj, using fallback")
			create_fallback_sword()
	else:
		print("sword.obj not found at: ", sword_obj_path, " - Using fallback")
		create_fallback_sword()
	
	# Position sword in front of camera
	sword.position = Vector3(0.3, -0.3, -0.5)
	sword.rotation_degrees = Vector3(-45, 0, 0)
	
	# Create animation player
	if not animation_player:
		animation_player = AnimationPlayer.new()
		animation_player.name = "AnimationPlayer"
		sword.add_child(animation_player)
		create_swing_animation()
	
	# Create attack hitbox
	var attack_area = Area3D.new()
	attack_area.name = "AttackArea"
	attack_area.monitoring = false
	sword.add_child(attack_area)
	
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(1.0, 1.5, 1.0)
	collision.shape = shape
	collision.position = Vector3(0, 0.3, -0.5)
	attack_area.add_child(collision)

func create_fallback_sword():
	# Create simple blade shape if .obj not found
	var blade = BoxMesh.new()
	blade.size = Vector3(0.1, 1.2, 0.05)
	sword.mesh = blade
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.7, 0.7, 0.75)
	material.metallic = 0.8
	material.roughness = 0.3
	sword.material_override = material
	sword.scale = Vector3(1, 1, 1)

func create_swing_animation():
	var anim = Animation.new()
	var anim_length = 0.4
	
	# Position track
	var pos_track = anim.add_track(Animation.TYPE_POSITION_3D)
	anim.track_set_path(pos_track, ".")
	anim.track_insert_key(pos_track, 0.0, Vector3(0.3, -0.3, -0.5))
	anim.track_insert_key(pos_track, 0.15, Vector3(-0.4, 0.2, -0.3))
	anim.track_insert_key(pos_track, anim_length, Vector3(0.3, -0.3, -0.5))
	
	# Rotation track
	var rot_track = anim.add_track(Animation.TYPE_ROTATION_3D)
	anim.track_set_path(rot_track, ".")
	anim.track_insert_key(rot_track, 0.0, Vector3(-45, 0, 0).rotated(Vector3.RIGHT, -45 * PI / 180))
	anim.track_insert_key(rot_track, 0.15, Vector3(45, -90, 45).rotated(Vector3.RIGHT, 45 * PI / 180))
	anim.track_insert_key(rot_track, anim_length, Vector3(-45, 0, 0).rotated(Vector3.RIGHT, -45 * PI / 180))
	
	anim.length = anim_length
	
	var library = AnimationLibrary.new()
	library.add_animation("swing", anim)
	animation_player.add_animation_library("", library)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Sword attack
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not is_attacking and animation_player:
			attack()
	
	# Arrow shooting
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		shoot_arrow()

func attack():
	is_attacking = true
	animation_player.play("swing")
	
	# Enable hitbox during swing
	var attack_area = sword.get_node_or_null("AttackArea")
	if attack_area:
		attack_area.monitoring = true
		await get_tree().create_timer(0.15).timeout
		
		# Check for hits
		var overlapping = attack_area.get_overlapping_bodies()
		for body in overlapping:
			if body.has_method("take_damage") and body != self:
				body.take_damage(25)
		
		attack_area.monitoring = false
	
	await animation_player.animation_finished
	is_attacking = false

func shoot_arrow():
	var arrow = preload("res://arrow.gd").new()
	
	# Spawn arrow at camera position
	arrow.position = camera.global_position
	arrow.direction = -camera.global_transform.basis.z
	arrow.shooter = self  # Pass reference to player
	
	# Add to scene root
	get_tree().root.add_child(arrow)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
	
	# Check for interactions
	if Input.is_action_just_pressed("ui_select") and raycast and raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.has_method("interact"):
			collider.interact()
