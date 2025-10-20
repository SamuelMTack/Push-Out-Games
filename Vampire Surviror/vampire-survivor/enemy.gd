extends CharacterBody2D

@export var speed = 80.0
@export var max_health = 30.0
@export var contact_damage = 5.0  # Damage per hit to player
@export var exp_drop_chance = 1  # 70% chance to drop exp
@export var experience_scene: PackedScene = preload("res://Experience.tscn")

var health = max_health
var player: CharacterBody2D
var damage_cooldown = 0.0  # To prevent instant multiple hits

func _ready():
	add_to_group("enemies")
	
	# Find player
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		player = players[0]

func _physics_process(delta):
	if not player:
		return
	
	# Move towards player
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	
	# Cooldown for damage
	if damage_cooldown > 0:
		damage_cooldown -= delta
	
	# Check collision with player
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().is_in_group("player"):
			if damage_cooldown <= 0:
				player.take_damage(contact_damage)
				damage_cooldown = 0.5  # Half second between damage hits

func take_damage(amount):
	health -= amount
	
	# Visual feedback
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if health <= 0:
		die()

func die():
	# Random chance to drop experience
	if randf() < exp_drop_chance and experience_scene:
		var exp = experience_scene.instantiate()
		get_parent().add_child(exp)
		exp.global_position = global_position
	
	queue_free()
