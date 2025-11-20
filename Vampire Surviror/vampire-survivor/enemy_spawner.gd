extends Node2D

@export var enemy_scenes: Array[PackedScene] = [
	preload("res://enemies/Enemy_Bat.tscn"),
	preload("res://enemies/Enemy_Goblin.tscn"),
	preload("res://enemies/Enemy_Giant.tscn")
]
# Fallback if array is empty or loading fails
var default_enemy = preload("res://Enemy.tscn")

@export var spawn_interval = 2.0
@export var spawn_distance = 600.0
@export var max_enemies = 50  # Prevent too many enemies


var spawn_timer = 0.0
var player: CharacterBody2D
var time_elapsed = 0.0

func _ready():
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		player = players[0]

func _physics_process(delta):
	spawn_timer -= delta
	time_elapsed += delta
	
	if spawn_timer <= 0:
		var enemy_count = get_tree().get_nodes_in_group("enemies").size()
		if enemy_count < max_enemies:
			spawn_enemy()
		
		spawn_timer = spawn_interval
		
		# Gradually increase difficulty
		spawn_interval = max(0.5, spawn_interval * 0.995)

func spawn_enemy():
	if not player:
		return
	
	var scene_to_spawn = default_enemy
	
	# Pick random enemy based on time/difficulty?
	# For now just random
	if not enemy_scenes.is_empty():
		scene_to_spawn = enemy_scenes.pick_random()
	
	if not scene_to_spawn:
		return
	
	var enemy = scene_to_spawn.instantiate()
	get_parent().add_child(enemy)
	
	# Spawn at random position around player
	var angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * spawn_distance
	enemy.global_position = player.global_position + offset
	
	# Scale enemy stats based on time
	# Increase HP by 10% every minute
	var scaling_factor = 1.0 + (time_elapsed / 60.0) * 0.5
	if enemy.has_method("take_damage"): # Check if it's a valid enemy script
		enemy.max_health *= scaling_factor
		enemy.health = enemy.max_health
		# Maybe scale damage too?
		if "contact_damage" in enemy:
			enemy.contact_damage *= (1.0 + (time_elapsed / 120.0) * 0.2)
