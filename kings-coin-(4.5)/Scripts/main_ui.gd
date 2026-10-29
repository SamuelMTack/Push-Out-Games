extends Control

@onready var timer: Timer = $Timer


func _on_button_start_pressed() -> void:
	timer.start()
	
func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://node_2d.tscn")

func _on_button_options_pressed() -> void:
	pass # Replace with function body.


func _on_button_exit_pressed() -> void:
	get_tree().quit()
