extends CharacterBody2D

@export var speed = 80.0
@export var max_health = 30.0
@export var damage = 10.0
@export var exp_value = 1
@export var experience_scene: PackedScene

var health = max_health
var player: CharacterBody2D

func _ready():
	add_to_group("enemies")
	
	# Find player
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		player = players[0]

func _physics_process(_delta):
	if not player:
		return
	
	# Move towards player
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	
	# Check collision with player
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().is_in_group("player"):
			player.take_damage(damage * 0.1) # Damage per frame of contact

func take_damage(amount):
	health -= amount
	# Visual feedback (optional - add a shader or sprite modulation)
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if health <= 0:
		die()

func die():
	# Drop experience
	if experience_scene:
		var exp = experience_scene.instantiate()
		get_parent().add_child(exp)
		exp.global_position = global_position
		exp.experience_value = exp_value
	
	queue_free()
