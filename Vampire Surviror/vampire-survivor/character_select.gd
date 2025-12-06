extends Control

@onready var char_list = %CharacterList
@onready var description_label = %DescriptionLabel
@onready var start_button = %StartButton

var selected_char_id = "knight"

func _ready():
	_populate_list()
	_update_selection()

func _populate_list():
	# Clear existing children if any
	for child in char_list.get_children():
		child.queue_free()
	
	var gm = get_node("/root/GameManager")
	if not gm: return
	
	for char_id in gm.characters:
		var char_data = gm.characters[char_id]
		var btn = Button.new()
		btn.text = char_data["name"]
		btn.toggle_mode = true
		btn.button_group = load("res://character_button_group.tres") # Optional, or manage manually
		# Manual management is easier without creating resource file
		btn.toggle_mode = false 
		
		btn.pressed.connect(_on_char_selected.bind(char_id))
		char_list.add_child(btn)

func _on_char_selected(char_id):
	selected_char_id = char_id
	_update_selection()

func _update_selection():
	var gm = get_node("/root/GameManager")
	if not gm: return
	
	gm.selected_character = selected_char_id
	var data = gm.characters[selected_char_id]
	
	description_label.text = "Name: " + data["name"] + "\n" + data["description"] + "\n" + \
	"HP: " + str(data["stats"]["max_health"]) + " | Speed: " + str(data["stats"]["speed"])
	
	start_button.disabled = false

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://level_select.tscn")

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://title_screen.tscn")
