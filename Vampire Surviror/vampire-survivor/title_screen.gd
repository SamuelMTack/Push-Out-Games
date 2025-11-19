extends Control

@onready var start_button = %StartButton
@onready var exit_button = %ExitButton

func _ready():
	# Connect button signals
	start_button.pressed.connect(_on_start_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)
	
	# Set initial focus
	start_button.grab_focus()

func _on_start_button_pressed():
	# Go to level select screen
	get_tree().change_scene_to_file("res://level_select.tscn")

func _on_exit_button_pressed():
	# Quit the game
	get_tree().quit()
