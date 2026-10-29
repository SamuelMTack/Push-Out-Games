extends "res://weapons/weapon.gd"

@onready var area_2d = $Area2D
@onready var sprite = $Sprite2D

var tick_timer = 0.0
var tick_rate = 0.5

func _ready():
	super._ready()
	# Garlic is always active, so we don't rely on 'attack' for spawning
	# But we use 'attack' or process for ticking damage
	
	# Set initial scale
	update_visuals()

func _process(delta):
	super._process(delta) # Handles cooldown for attack?
	
	# Actually, garlic ticks independently of "attack" usually, or attack IS the tick?
	# Let's make it tick based on cooldown
	
	tick_timer -= delta
	if tick_timer <= 0:
		tick_damage()
		tick_timer = cooldown # Use cooldown as tick rate

func tick_damage():
	var enemies = area_2d.get_overlapping_bodies()
	for body in enemies:
		if body.has_method("take_damage"):
			body.take_damage(damage)
	
	# Pulse effect
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.5, 0.1)
	tween.tween_property(sprite, "modulate:a", 0.2, 0.1)

func update_stats(player_ref):
	super.update_stats(player_ref)
	update_visuals()

func update_visuals():
	if sprite:
		sprite.scale = Vector2(scale.x, scale.y) * 3.0 # Make it big enough to see
		# Also update collision shape size?
		# Area2D inherits scale from parent (this node), so it should scale automatically!
