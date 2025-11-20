extends CharacterBody3D

enum EnemyType { BASIC, FAST, TANK, SNIPER }

var enemy_type = EnemyType.BASIC
var health = 30.0
var max_health = 30.0
var move_speed = 3.0
var damage = 10.0
var gold_drop = 5
var ammo_drop_chance = 0.6

var player: CharacterBody3D = null
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var attack_cooldown = 1.0
var attack_timer = 0.0

@onready var mesh_instance = $MeshInstance3D

# Preload pickup scenes
var gold_pickup_scene = preload("res://GoldPickup.tscn")
var ammo_pickup_scene = preload("res://AmmoPickup.tscn")

func _ready():
	add_to_group("Enemy")
	randomize_type()
	apply_type_properties()
	
	# Find player
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]

func randomize_type():
	var rand = randf()
	if rand < 0.5:
		enemy_type = EnemyType.BASIC
	elif rand < 0.7:
		enemy_type = EnemyType.FAST
	elif rand < 0.9:
		enemy_type = EnemyType.TANK
	else:
		enemy_type = EnemyType.SNIPER

func apply_type_properties():
	var material = StandardMaterial3D.new()
	
	match enemy_type:
		EnemyType.BASIC:
			max_health = 30.0
			move_speed = 3.0
			damage = 10.0
			gold_drop = 5
			material.albedo_color = Color.RED
			mesh_instance.scale = Vector3.ONE
		
		EnemyType.FAST:
			max_health = 20.0
			move_speed = 6.0
			damage = 5.0
			gold_drop = 8
			material.albedo_color = Color.ORANGE
			mesh_instance.scale = Vector3(0.7, 1.2, 0.7)
		
		EnemyType.TANK:
			max_health = 80.0
			move_speed = 1.5
			damage = 20.0
			gold_drop = 15
			material.albedo_color = Color.DARK_RED
			mesh_instance.scale = Vector3(1.5, 1.5, 1.5)
		
		EnemyType.SNIPER:
			max_health = 15.0
			move_speed = 2.0
			damage = 15.0
			gold_drop = 10
			material.albedo_color = Color.PURPLE
			mesh_instance.scale = Vector3(0.8, 1.3, 0.8)
	
	health = max_health
	mesh_instance.set_surface_override_material(0, material)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if player and is_instance_valid(player):
		# Move towards player
		var direction = (player.global_transform.origin - global_transform.origin).normalized()
		direction.y = 0  # Don't move vertically
		
		# Different behavior based on type
		var target_distance = 0.0
		match enemy_type:
			EnemyType.SNIPER:
				target_distance = 15.0  # Keep distance
			_:
				target_distance = 2.0  # Get close
		
		var distance_to_player = global_transform.origin.distance_to(player.global_transform.origin)
		
		if distance_to_player > target_distance:
			velocity.x = direction.x * move_speed
			velocity.z = direction.z * move_speed
		else:
			velocity.x = 0
			velocity.z = 0
		
		# Look at player
		if direction.length() > 0:
			look_at(player.global_transform.origin, Vector3.UP)
			rotation.x = 0
			rotation.z = 0
	else:
		velocity.x = 0
		velocity.z = 0
	
	move_and_slide()
	
	# Attack cooldown
	if attack_timer > 0:
		attack_timer -= delta

func _on_player_collision(body):
	if body.is_in_group("Player") and attack_timer <= 0:
		if body.has_method("take_damage"):
			body.take_damage(damage)
			attack_timer = attack_cooldown

func take_damage(dmg: float):
	health -= dmg
	
	# Visual feedback
	flash_damage()
	
	if health <= 0:
		die()

func flash_damage():
	var tween = create_tween()
	var material = mesh_instance.get_surface_override_material(0)
	if material:
		var original_color = material.albedo_color
		tween.tween_property(material, "albedo_color", Color.WHITE, 0.1)
		tween.tween_property(material, "albedo_color", original_color, 0.1)

func die():
	# Drop gold
	var gold_pickup = gold_pickup_scene.instantiate()
	get_parent().add_child(gold_pickup)
	gold_pickup.global_transform.origin = global_transform.origin + Vector3(0, 0.5, 0)
	gold_pickup.set_gold_amount(gold_drop)
	
	# Chance to drop ammo
	if randf() < ammo_drop_chance:
		var ammo_pickup = ammo_pickup_scene.instantiate()
		get_parent().add_child(ammo_pickup)
		ammo_pickup.global_transform.origin = global_transform.origin + Vector3(randf_range(-1, 1), 0.5, randf_range(-1, 1))
	
	queue_free()
