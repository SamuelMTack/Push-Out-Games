extends Area2D

var damage: float = 0.0

func setup(dmg):
	damage = dmg
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
