extends StaticBody2D

signal player_hit

@onready var damage_area = $SpikeDamageArea

func _ready():
	# Connect player damage detection
	damage_area.body_entered.connect(_on_player_entered)

	# Only auto-remove if this is visible
	if visible:
		get_tree().create_timer(8.0).timeout.connect(queue_free)

func _on_player_entered(body):
	if body.name.contains("Player"):
		player_hit.emit()