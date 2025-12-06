extends "res://weapons/weapon.gd"

@export var strike_scene: PackedScene = preload("res://weapons/projectiles/LightningStrike.tscn")

func attack():
	if not strike_scene: return
	
	# Find random enemies and breakables
	var enemies = get_tree().get_nodes_in_group("enemies")
	var breakables = get_tree().get_nodes_in_group("breakables")
	var targets = enemies + breakables
	if targets.is_empty(): return
	
	# Determine how many to strike (base 1 + amount from player)
	var strike_count = 1
	if player and "amount" in player:
		strike_count += player.amount
	
	# Shuffle to pick random
	targets.shuffle()
	
	for i in range(min(strike_count, targets.size())):
		var enemy = targets[i]
		spawn_strike(enemy.global_position)
	
	super.attack()

func spawn_strike(pos: Vector2):
	var strike = strike_scene.instantiate()
	get_tree().current_scene.add_child(strike)
	strike.global_position = pos
	strike.damage = damage
	strike.scale = Vector2(scale.x, scale.y)
