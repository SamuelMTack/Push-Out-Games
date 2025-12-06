extends Area2D

enum PickupType { HEALTH, COIN, MAGNET, FREEZE }
@export var type: PickupType = PickupType.HEALTH
@export var value = 10.0

var texture_health = preload("res://Assets/Sprites/chicken.png")
var texture_coin = preload("res://Assets/Sprites/coin.png")
var texture_magnet = preload("res://Assets/Sprites/magnet.png")
var texture_freeze = preload("res://Assets/Sprites/freeze.png")

func _ready():
	connect("body_entered", _on_body_entered)
	update_visuals()

func update_visuals():
	var sprite = $Sprite2D
	sprite.modulate = Color.WHITE # Reset modulation
	match type:
		PickupType.HEALTH:
			sprite.texture = texture_health
		PickupType.COIN:
			sprite.texture = texture_coin
		PickupType.MAGNET:
			sprite.texture = texture_magnet
		PickupType.FREEZE:
			sprite.texture = texture_freeze

func _on_body_entered(body):
	if body.is_in_group("player"):
		apply_effect(body)
		queue_free()

func apply_effect(player):
	match type:
		PickupType.HEALTH:
			player.health = min(player.health + value, player.max_health)
			player.get_tree().call_group("ui", "update_health", player.health, player.max_health)
			print("Picked up Health")
		PickupType.COIN:
			# Add coin logic
			if has_node("/root/GameManager"):
				get_node("/root/GameManager").add_coins(int(value))
			print("Picked up Coin")
		PickupType.MAGNET:
			# Magnet logic: Find all XP and move to player
			var exps = get_tree().get_nodes_in_group("experience")
			for exp in exps:
				exp.magnetize(player)
			print("Picked up Magnet")
		PickupType.FREEZE:
			# Freeze logic: Stop all enemies
			get_tree().call_group("enemies", "freeze", 5.0)
			print("Picked up Freeze")
