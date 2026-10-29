extends Node2D

@export var enemy_scenes: Array[PackedScene] = [
	preload("res://enemies/Enemy_Bat.tscn"),
	preload("res://enemies/Enemy_Goblin.tscn"),
	preload("res://enemies/Enemy_Giant.tscn"),
	preload("res://enemies/Enemy_Shooter.tscn"),
	preload("res://enemies/Enemy_Charger.tscn"),
	preload("res://enemies/Enemy_Skeleton.tscn"),
	preload("res://enemies/Enemy_Ghost.tscn"),
	preload("res://enemies/Enemy_Golem.tscn"),
	preload("res://enemies/Enemy_Slime.tscn"),
	preload("res://enemies/Enemy_Werewolf.tscn"),
	preload("res://enemies/Enemy_Mummy.tscn")
]

var boss_scene = preload("res://enemies/Boss.tscn")
var boss_spawned = false
var breakable_scene = preload("res://pickups/Breakable.tscn")
var breakable_timer = 0.0

# Fallback if array is empty or loading fails
var default_enemy = preload("res://Enemy.tscn")

@export var spawn_interval = 2.0
@export var spawn_distance = 600.0
@export var max_enemies = 50  # Prevent too many enemies


var spawn_timer = 0.0
var horde_timer = 30.0 # First horde at 30s
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
	
	# Boss Spawning (e.g., at 5 minutes = 300 seconds)
	if time_elapsed > 300.0 and not boss_spawned:
		spawn_boss()

	# Horde Spawning
	horde_timer -= delta
	if horde_timer <= 0:
		spawn_horde()
		horde_timer = 30.0 # Every 30 seconds

	# Breakable Spawning (every 10s)
	breakable_timer -= delta
	if breakable_timer <= 0:
		spawn_breakable()
		breakable_timer = 10.0

func spawn_breakable():
	if not player or not breakable_scene: return
	
	var breakable = breakable_scene.instantiate()
	get_parent().add_child(breakable)
	
	# Spawn randomly on screen edge or nearby
	var angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * (spawn_distance * 0.8)
	breakable.global_position = player.global_position + offset

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
	var difficulty_multiplier = 1.0 + (time_elapsed / 60.0) * 0.1
	if "max_health" in enemy:
		enemy.max_health *= difficulty_multiplier
		enemy.health = enemy.max_health
	if "contact_damage" in enemy:
		enemy.contact_damage *= difficulty_multiplier

func spawn_horde():
	if not player or enemy_scenes.is_empty(): return
	
	var horde_size = 5 + int(time_elapsed / 60.0) * 5
	var scene = enemy_scenes.pick_random()
	
	# Pick a random direction for the horde center
	var angle = randf() * TAU
	var center_offset = Vector2(cos(angle), sin(angle)) * spawn_distance
	var center_pos = player.global_position + center_offset
	
	print("Spawning horde of ", horde_size, " enemies!")
	
	for i in range(horde_size):
		var enemy = scene.instantiate()
		get_parent().add_child(enemy)
		
		# Random offset from horde center
		var random_offset = Vector2(randf_range(-100, 100), randf_range(-100, 100))
		enemy.global_position = center_pos + random_offset
		
		# Scale stats
		var difficulty_multiplier = 1.0 + (time_elapsed / 60.0) * 0.1
		if "max_health" in enemy:
			enemy.max_health *= difficulty_multiplier
			enemy.health = enemy.max_health


func spawn_boss():
	if not player or not boss_scene: return
	
	boss_spawned = true
	var boss = boss_scene.instantiate()
	get_parent().add_child(boss)
	
	# Spawn slightly further away
	var angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * (spawn_distance * 1.5)
	boss.global_position = player.global_position + offset
	
	print("WARNING: BOSS SPAWNED!")
