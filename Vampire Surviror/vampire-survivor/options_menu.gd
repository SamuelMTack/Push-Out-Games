extends Control

@onready var volume_slider = %VolumeSlider
@onready var window_mode_button = %WindowModeButton
@onready var back_button = %BackButton
@onready var reset_button = %ResetButton
@onready var confirm_reset_dialog = %ConfirmResetDialog

func _ready():
	# Setup Volume Slider
	var master_bus = AudioServer.get_bus_index("Master")
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus))
	volume_slider.value_changed.connect(_on_volume_changed)
	
	# Setup Window Mode
	window_mode_button.add_item("Windowed")
	window_mode_button.add_item("Fullscreen")
	
	var current_mode = DisplayServer.window_get_mode()
	if current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN or current_mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		window_mode_button.selected = 1
	else:
		window_mode_button.selected = 0
		
	window_mode_button.item_selected.connect(_on_window_mode_selected)
	
	# Setup Buttons
	back_button.pressed.connect(_on_back_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	
	# Setup Dialog
	confirm_reset_dialog.confirmed.connect(_on_reset_confirmed)

func _on_volume_changed(value):
	var master_bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))

func _on_window_mode_selected(index):
	if index == 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif index == 1:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_reset_pressed():
	confirm_reset_dialog.popup_centered()

func _on_reset_confirmed():
	if has_node("/root/GameManager"):
		get_node("/root/GameManager").reset_progress()
		print("Progress Reset!")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://title_screen.tscn")
