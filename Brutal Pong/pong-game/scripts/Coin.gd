extends Area2D

signal collected

@export var coin_value: int = 5

func _ready():
	body_entered.connect(_on_player_entered)

	if visible:
		get_tree().create_timer(12.0).timeout.connect(queue_free)

func _on_player_entered(body):
	if body.name.contains("Player"):
		collected.emit(coin_value)
		queue_free()