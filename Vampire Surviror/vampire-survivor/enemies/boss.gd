extends "res://enemy.gd"

func _ready():
	super._ready()
	max_health = 5000.0
	health = max_health
	speed = 50.0
	scale = Vector2(3.0, 3.0) # Make it big
	
	# Boss immunity to knockback?
	
func die():
	# Drop a treasure chest!
	# For now, just drop a lot of XP
	var main = get_tree().current_scene
	if main and main.has_method("register_experience_gain"):
		main.register_experience_gain(1000)
	
	# Maybe trigger victory or level complete?
	# For now, standard death but with fanfare
	print("BOSS DEFEATED!")
	
	super.die()
