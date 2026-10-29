extends Node2D

var target_position = Vector2.ZERO
var speed = 400.0
var damage = 10.0
var duration = 3.0
var area_scale = 1.0
var crit_chance = 0.0
var crit_multiplier = 2.0

@onready var sprite = $Sprite2D

func setup(target: Vector2, dmg: float, dur: float, area: float, crit_c: float, crit_m: float):
	target_position = target
	damage = dmg
	duration = dur
	area_scale = area
	crit_chance = crit_c
	crit_multiplier = crit_m

func _process(delta):
	var direction = (target_position - global_position).normalized()
	var distance = global_position.distance_to(target_position)
	
	if distance < speed * delta:
		# Reached target
		global_position = target_position
		_spawn_zone()
		queue_free()
	else:
		global_position += direction * speed * delta
		sprite.rotation += 10.0 * delta # Spin effect

func _spawn_zone():
	var zone_scene = load("res://weapons/projectiles/HolyWaterZone.tscn")
	var zone = zone_scene.instantiate()
	zone.global_position = global_position
	zone.setup(damage, duration, area_scale)
	get_tree().current_scene.add_child(zone)
