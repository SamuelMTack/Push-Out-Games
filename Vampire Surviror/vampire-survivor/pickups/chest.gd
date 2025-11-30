extends Area2D

var is_opened = false
var coins_amount = 100

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if not is_opened and body.is_in_group("player"):
		open_chest(body)

func open_chest(player):
	is_opened = true
	print("Chest Opened!")
	
	# Determine reward
	var upgrade_reward = null
	
	# 50% chance for an evolution if possible, or just a random upgrade
	# For now, let's just trigger the UI to pick a reward
	
	# Call UI to show chest animation and reward
	get_tree().call_group("ui", "show_chest_reward", coins_amount)
	
	queue_free()
