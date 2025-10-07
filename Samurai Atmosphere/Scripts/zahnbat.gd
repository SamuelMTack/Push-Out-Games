extends Area2D

@onready var timer = $Timer

func _ready():
	# Das Signal timeout verbinden, falls nicht schon im Editor:
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))

	connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(area: Area2D):
	if area.name == "Hitbox":
		print("Enemy wurde getroffen!")
		await get_tree().create_timer(0.5).timeout
		$CollisionShape2D.disabled = true
		hide()            # Gegner „verschwindet“
		timer.start()     # Timer läuft los 

func _on_timer_timeout():
	print("Timer abgelaufen, Gegner respawnt")
	$CollisionShape2D.disabled = false
	show()               # Gegner wird wieder sichtbar
