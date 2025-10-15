extends Area2D


@export var experience_value = 1
@export var magnet_speed = 200.0

var is_magnetized = false
var player: CharacterBody2D

func _ready():
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta):
	if is_magnetized and player:
		var direction = (player.global_position - global_position).normalized()
		global_position += direction * magnet_speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.add_experience(experience_value)
		queue_free()

func _on_area_entered(area):
	# If player has a magnet area, start moving towards them
	if area.is_in_group("player_magnet"):
		is_magnetized = true
		var players = get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			player = players[0]
