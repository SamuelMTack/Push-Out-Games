extends Area2D

@export var speed: int = 320
var velocity: Vector2 = Vector2.ZERO
var launched: bool = false

func _ready() -> void:
    reset()
    connect("area_entered", Callable(self, "_on_area_entered"))

func reset() -> void:
    position = Vector2(400, 520)
    velocity = Vector2(0, -1) * speed
    launched = false

func launch() -> void:
    if not launched:
        launched = true
        velocity = Vector2(0.5, -0.8).normalized() * speed

func _physics_process(delta: float) -> void:
    if not launched:
        return
    var new_pos: Vector2 = position + velocity * delta
    var view_rect := get_viewport_rect()
    # Check wall collisions
    if new_pos.x < 0 or new_pos.x > view_rect.size.x:
        velocity.x = -velocity.x
    if new_pos.y < 0:
        velocity.y = -velocity.y
    position += velocity * delta

func _on_area_entered(area: Area2D) -> void:
    if area.name == "Paddle":
        var paddle_pos: Vector2 = area.position
        var half_width: float = float(area.get_node("CollisionShape2D").shape.extents.x)
        var offset: float = (position.x - paddle_pos.x) / half_width
        var t: float = clamp((offset + 1.0)/2.0, 0.0, 1.0)
        var angle: float = lerp(-0.75, 0.75, t)
        velocity = Vector2(cos(angle), -abs(sin(angle))).normalized() * speed
    elif area.name.begins_with("Brick"):
        # reflect vertically and let brick handle its own queue_free
        velocity.y = -velocity.y
