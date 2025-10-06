extends Area2D

@export var speed: int = 800
@export var screen_margin: int = 16

func _ready() -> void:
    pass

func _physics_process(delta: float) -> void:
    var input_dir: int = 0
    if Input.is_action_pressed("ui_right"):
        input_dir += 1
    if Input.is_action_pressed("ui_left"):
        input_dir -= 1
    var velocity: float = input_dir * speed
    position.x += velocity * delta
    var half_width: float = float($CollisionShape2D.shape.extents.x)
    var viewport_width: float = get_viewport_rect().size.x
    position.x = clamp(position.x, screen_margin + half_width, viewport_width - screen_margin - half_width)
