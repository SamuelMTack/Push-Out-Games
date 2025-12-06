extends Control

@onready var start_button = %StartButton
@onready var exit_button = %ExitButton

func _ready():
	# Connect button signals
	start_button.pressed.connect(_on_start_button_pressed)
	%ShopButton.pressed.connect(_on_shop_button_pressed)
	%OptionsButton.pressed.connect(_on_options_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)
	
	# Set initial focus
	start_button.grab_focus()

func _on_start_button_pressed():
	# Go to character select screen
	get_tree().change_scene_to_file("res://character_select.tscn")

func _on_shop_button_pressed():
	get_tree().change_scene_to_file("res://shop_menu.tscn")

func _on_options_button_pressed():
	get_tree().change_scene_to_file("res://options_menu.tscn")

func _on_exit_button_pressed():
	# Quit the game
	get_tree().quit()
