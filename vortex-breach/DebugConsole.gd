extends Node

# Debug Console for testing
# Press F1 to toggle console
# Type commands and press Enter

var console_visible = false
var player: CharacterBody3D = null

# Commands available:
# god - Toggle invincibility
# ammo [amount] - Set ammo
# gold [amount] - Add gold
# health [amount] - Set health
# spawn_enemy - Spawn enemy at player position
# power [type] - Give powerup (speed, jump, damage, spread, bullet_speed, fire_rate)
# clear_enemies - Remove all enemies
# next_level - Generate new level

var god_mode = false

func _ready():
	# Find player
	await get_tree().process_frame
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]

func _input(event):
	if event.is_action_pressed("toggle_console"):  # F1
		toggle_console()

func toggle_console():
	console_visible = !console_visible
	
	if console_visible:
		print("=== DEBUG CONSOLE ===")
		print("Available commands:")
		print("  god - Toggle invincibility")
		print("  ammo [amount] - Set ammo")
		print("  gold [amount] - Add gold")
		print("  health [amount] - Set health")
		print("  spawn_enemy - Spawn enemy")
		print("  power [type] - Give powerup")
		print("  clear_enemies - Remove all enemies")
		print("  next_level - Generate new level")
		print("====================")

func execute_command(command: String):
	var parts = command.split(" ")
	var cmd = parts[0].to_lower()
	
	if not player:
		print("Error: Player not found")
		return
	
	match cmd:
		"god":
			god_mode = !god_mode
			print("God mode: ", "ON" if god_mode else "OFF")
		
		"ammo":
			if parts.size() > 1:
				var amount = int(parts[1])
				player.current_ammo = amount
				print("Ammo set to: ", amount)
			else:
				print("Usage: ammo [amount]")
		
		"gold":
			if parts.size() > 1:
				var amount = int(parts[1])
				player.add_gold(amount)
				print("Added ", amount, " gold")
			else:
				print("Usage: gold [amount]")
		
		"health":
			if parts.size() > 1:
				var amount = float(parts[1])
				player.health = amount
				player.update_ui()
				print("Health set to: ", amount)
			else:
				print("Usage: health [amount]")
		
		"spawn_enemy":
			var enemy_scene = load("res://Enemy.tscn")
			if enemy_scene:
				var enemy = enemy_scene.instantiate()
				player.get_parent().add_child(enemy)
				enemy.position = player.position + Vector3(3, 0, 0)
				print("Enemy spawned")
			else:
				print("Error: Enemy.tscn not found")
		
		"power":
			if parts.size() > 1:
				var power_type = parts[1].to_lower()
				player.apply_powerup(power_type, 10.0)
				print("Applied powerup: ", power_type)
			else:
				print("Usage: power [speed|jump|damage|spread|bullet_speed|fire_rate]")
		
		"clear_enemies":
			var enemies = get_tree().get_nodes_in_group("Enemy")
			for enemy in enemies:
				enemy.queue_free()
			print("Cleared ", enemies.size(), " enemies")
		
		"next_level":
			var level_gen = get_node_or_null("/root/World/LevelGenerator")
			if level_gen and level_gen.has_method("generate_level"):
				level_gen.generate_level()
				player.position = Vector3(0, 5, 0)
				print("Generated new level")
			else:
				print("Error: LevelGenerator not found")
		
		_:
			print("Unknown command: ", cmd)

func _process(_delta):
	if god_mode and player:
		player.health = player.max_health
		player.stamina = player.max_stamina

# Quick test function to verify everything works
func run_diagnostics():
	print("\n=== RUNNING DIAGNOSTICS ===")
	
	# Check player
	if player:
		print("✓ Player found")
	else:
		print("✗ Player not found")
	
	# Check scenes exist
	var scenes_to_check = [
		"res://Bullet.tscn",
		"res://Enemy.tscn",
		"res://Platform.tscn",
		"res://HazardSpike.tscn",
		"res://HazardLava.tscn",
		"res://Powerup.tscn",
		"res://Door.tscn",
		"res://GoldPickup.tscn",
		"res://AmmoPickup.tscn"
	]
	
	for scene_path in scenes_to_check:
		if ResourceLoader.exists(scene_path):
			print("✓ ", scene_path)
		else:
			print("✗ ", scene_path, " - MISSING")
	
	# Check UI
	var ui = get_node_or_null("/root/World/UI")
	if ui:
		print("✓ UI found")
	else:
		print("✗ UI not found")
	
	# Check LevelGenerator
	var level_gen = get_node_or_null("/root/World/LevelGenerator")
	if level_gen:
		print("✓ LevelGenerator found")
	else:
		print("✗ LevelGenerator not found")
	
	print("=== DIAGNOSTICS COMPLETE ===\n")
