# StartMenu.gd
# Attach this to a CanvasLayer node
extends CanvasLayer

@onready var start_button = $MenuContainer/VBoxContainer/StartButton
@onready var quit_button = $MenuContainer/VBoxContainer/QuitButton

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_start_pressed():
	get_parent().start_game()

func _on_quit_pressed():
	get_parent().quit_game()
