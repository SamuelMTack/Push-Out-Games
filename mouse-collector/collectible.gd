extends Area2D

# Signal to tell Main that we have been collected
signal collected_signal

func _ready():
	# Make sure Godot knows this object can be clicked/hovered
	input_pickable = true
	
	# Connect the built-in Godot signal for mouse hovering
	mouse_entered.connect(_on_mouse_entered)

func _on_mouse_entered():
	# 1. Tell the Main script to add score
	collected_signal.emit()
	
	# 2. Make this object disappear immediately
	queue_free()
