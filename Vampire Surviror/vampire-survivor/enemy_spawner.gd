extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval = 2.0
@export var spawn_distance = 600.0

var spawn_timer = 0.0
var player: CharacterBody2D

func _ready():
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		player = players[0]

func _physics_process(delta):
	spawn_timer -= delta
	
	if spawn_timer <= 0:
		spawn_enemy()
		spawn_timer = spawn_interval
		
		# Increase difficulty over time
		spawn_interval = max(0.5, spawn_interval * 0.99)

func spawn_enemy():
	if not enemy_scene or not player:
		return
	
	var enemy = enemy_scene.instantiate()
	get_parent().add_child(enemy)
	
	# Spawn at random position around player
	var angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * spawn_distance
	enemy.global_position = player.global_position + offset
