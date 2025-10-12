extends Button

@onready var eggs: AnimatedSprite2D = $"../../Eggs"
@onready var chicken: AnimatedSprite2D = $"../../Chicken"


func _on_button_down() -> void:
	chicken.frame = 1
	eggs.play("Falling_eggs")

		
func _on_button_up() -> void:
	chicken.frame = 0
