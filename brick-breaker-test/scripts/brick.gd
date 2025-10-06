extends Area2D
signal destroyed

@export var hit_points: int = 1

func _ready() -> void:
    connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(area: Area2D) -> void:
    if area.name == "Ball":
        hit_points -= 1
        if hit_points <= 0:
            emit_signal("destroyed")
            queue_free()
