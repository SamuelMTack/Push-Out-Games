extends Area2D

@export var experience_value = 10.0
@export var pickup_range = 50.0  # Auto-pickup range

var player: CharacterBody2D

func _ready():
	body_entered.connect(_on_body_entered)
	
	# Find player
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		player = players[0]

func _physics_process(delta):
	if player:
		var distance = global_position.distance_to(player.global_position)
		
		# Use player's pickup range
		#var pickup_range = player.pickup_range if player.has("pickup_range") else 50.0
		
		# Auto-pickup if close enough
		if distance < pickup_range:
			# Move towards player
			var direction = (player.global_position - global_position).normalized()
			global_position += direction * 400.0 * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.add_experience(experience_value)
		queue_free()
