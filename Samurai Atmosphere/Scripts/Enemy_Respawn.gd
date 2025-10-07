extends Node

@onready var timer = $Timer
@onready var zahnbat = $Zahnbat
const Enemy =preload("res://Scenes/zahnbat.tscn")
var Enemy_inst = Enemy.instantiate()

func _on_zahnbat_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	timer.start()
	enemy_died()
	
func _on_timer_timeout():
	spawn_enemy()


func spawn_enemy():
	print("enemy Spawned")
	
	
func enemy_died():
	print("enemy died")
	
	
	
