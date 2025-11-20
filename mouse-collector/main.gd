extends Node2D

# This loads the scene automatically so you don't have to drag-and-drop it
var collectible_scene = preload("res://Collectible.tscn")

@onready var score_label = $CanvasLayer/ScoreLabel
@onready var spawn_timer = $SpawnTimer

var score = 0
var screen_size

func _ready():
	screen_size = get_viewport_rect().size
	
	# Initialize Score UI
	score_label.text = "Score: 0"
	
	# Setup Timer
	spawn_timer.wait_time = 0.8
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func _on_spawn_timer_timeout():
	spawn_collectible()

func spawn_collectible():
	# Create the object
	var item = collectible_scene.instantiate()
	
	# Set random position
	var x_pos = randf_range(50, screen_size.x - 50)
	var y_pos = randf_range(50, screen_size.y - 50)
	item.position = Vector2(x_pos, y_pos)
	
	# Connect the signal from the item to the score function below
	item.collected_signal.connect(_increase_score)
	
	add_child(item)

# This function runs whenever a collectible emits its signal
func _increase_score():
	score += 1
	score_label.text = "Score: " + str(score)
