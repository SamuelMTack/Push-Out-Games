# Skeleton.gd
# Create this as a new script file: res://skeleton.gd
extends CharacterBody3D

const SPEED = 2.5
const ATTACK_RANGE = 2.0
const ATTACK_COOLDOWN = 1.5
const DETECTION_RANGE = 15.0

var health = 50
var player = null
var attack_timer = 0.0
var is_attacking = false
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	setup_skeleton()

func setup_skeleton():
	# Create skeleton body (spine)
	var spine = MeshInstance3D.new()
	var spine_mesh = BoxMesh.new()
	spine_mesh.size = Vector3(0.4, 1.2, 0.3)
	spine.mesh = spine_mesh
	var spine_mat = StandardMaterial3D.new()
	spine_mat.albedo_color = Color(0.9, 0.9, 0.85)
	spine.material_override = spine_mat
	spine.position = Vector3(0, 0.6, 0)
	add_child(spine)
	
	# Create head
	var head = MeshInstance3D.new()
	var head_mesh = BoxMesh.new()
	head_mesh.size = Vector3(0.4, 0.4, 0.4)
	head.mesh = head_mesh
	head.material_override = spine_mat
	head.position = Vector3(0, 1.4, 0)
	add_child(head)
	
	# Create arms
	for side in [-1, 1]:
		var arm = MeshInstance3D.new()
		var arm_mesh = BoxMesh.new()
		arm_mesh.size = Vector3(0.15, 0.8, 0.15)
		arm.mesh = arm_mesh
		arm.material_override = spine_mat
		arm.position = Vector3(side * 0.3, 0.7, 0)
		add_child(arm)
	
	# Create legs
	for side in [-1, 1]:
		var leg = MeshInstance3D.new()
		var leg_mesh = BoxMesh.new()
		leg_mesh.size = Vector3(0.15, 0.8, 0.15)
		leg.mesh = leg_mesh
		leg.material_override = spine_mat
		leg.position = Vector3(side * 0.15, -0.4, 0)
		add_child(leg)
	
	# Add collision shape
	var collision = CollisionShape3D.new()
	var shape = CapsuleShape3D.new()
	shape.radius = 0.3
	shape.height = 1.6
	collision.shape = shape
	collision.position = Vector3(0, 0.8, 0)
	add_child(collision)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	attack_timer -= delta
	
	if player and is_instance_valid(player):
		var distance = global_position.distance_to(player.global_position)
		
		# Only chase if player is in detection range
		if distance < DETECTION_RANGE:
			if distance > ATTACK_RANGE:
				# Move towards player
				var direction = (player.global_position - global_position).normalized()
				direction.y = 0
				velocity.x = direction.x * SPEED
				velocity.z = direction.z * SPEED
				
				# Face player
				look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z))
				is_attacking = false
			else:
				# In attack range
				velocity.x = 0
				velocity.z = 0
				look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z))
				
				if attack_timer <= 0 and not is_attacking:
					attack_player()
		else:
			# Out of range, idle
			velocity.x = 0
			velocity.z = 0
	else:
		velocity.x = 0
		velocity.z = 0
	
	move_and_slide()

func attack_player():
	is_attacking = true
	attack_timer = ATTACK_COOLDOWN
	
	# Simple attack - just deal damage if player is still in range
	await get_tree().create_timer(0.3).timeout
	
	if player and is_instance_valid(player):
		var distance = global_position.distance_to(player.global_position)
		if distance <= ATTACK_RANGE:
			if player.has_method("take_damage"):
				player.take_damage(10)
	
	is_attacking = false

func take_damage(amount):
	health -= amount
	
	# Visual feedback - flash red
	for child in get_children():
		if child is MeshInstance3D:
			var mat = child.material_override
			if mat:
				mat.albedo_color = Color(1, 0.3, 0.3)
				await get_tree().create_timer(0.1).timeout
				mat.albedo_color = Color(0.9, 0.9, 0.85)
	
	if health <= 0:
		die()

func die():
	queue_free()
