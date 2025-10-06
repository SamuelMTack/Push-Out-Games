extends Node2D

@onready var paddle: Node2D = $Paddle
@onready var ball: Node2D = $Ball
@onready var bricks: Node2D = $Bricks
@onready var score_label: Label = $HUD/ScoreLabel

var score: int = 0

@export var rows: int = 5
@export var cols: int = 10
@export var brick_spacing: Vector2 = Vector2(8, 8)

func _ready() -> void:
    _create_bricks()

func _input(event) -> void:
    if event.is_action_pressed("ui_accept"):
        if ball.has_method("launch"):
            ball.launch()

func _create_bricks() -> void:
    var start_x: float = 64.0
    var start_y: float = 64.0
    var brick_scene := load("res://scenes/Brick.tscn")
    for r in range(rows):
        for c in range(cols):
            var b = brick_scene.instantiate()
            b.name = "Brick_%d_%d" % [r, c]
            var extents_x: float = float(b.get_node("CollisionShape2D").shape.extents.x)
            var extents_y: float = float(b.get_node("CollisionShape2D").shape.extents.y)
            b.position = Vector2(start_x + c*(extents_x*2 + brick_spacing.x), start_y + r*(extents_y*2 + brick_spacing.y))
            # connect to brick "destroyed" signal if present, otherwise watch for removal
            if b.has_signal("destroyed"):
                b.connect("destroyed", Callable(self, "_on_brick_destroyed"))
            bricks.add_child(b)

func _on_brick_destroyed() -> void:
    score += 100
    score_label.text = "Score: %d" % score
