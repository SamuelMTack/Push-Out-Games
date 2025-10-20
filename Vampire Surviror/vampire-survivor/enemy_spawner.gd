extends Node2D

@export var enemy_scene: PackedScene = preload("uid://d3xq8jw1y3csv")
@export var spawn_interval = 2.0
@export var spawn_distance = 600.0
@export var max_enemies = 50  # Prevent too many enemies


var spawn_timer = 0.0
var player: CharacterBody2D

func _ready():
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		player = players[0]

func _physics_process(delta):
	spawn_timer -= delta
	
	if spawn_timer <= 0:
		var enemy_count = get_tree().get_nodes_in_group("enemies").size()
		if enemy_count < max_enemies:
			spawn_enemy()
			print("spawn enemy")
		
		spawn_timer = spawn_interval
		
		# Gradually increase difficulty
		spawn_interval = max(0.5, spawn_interval * 0.995)

func spawn_enemy():
	var enemy: = enemy_scene.instantiate()
	add_child(enemy)
	# Spawn at random position around player
	var angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * spawn_distance
	enemy.global_position = player.global_position + offset
