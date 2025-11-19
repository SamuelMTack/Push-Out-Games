extends Node2D

var damage: float = 0.0
var radius: float = 0.0
var fuse: float = 0.0
var exploded: bool = false

@onready var sprite = $Sprite2D
@onready var area = $Area2D
@onready var collision = $Area2D/CollisionShape2D

func setup(dmg, rad, time):
	damage = dmg
	radius = rad
	fuse = time
	
	# Set collision size
	if collision and collision.shape is CircleShape2D:
		collision.shape.radius = radius

func _process(delta):
	if exploded: return
	
	fuse -= delta
	if fuse <= 0:
		explode()
	else:
		# Pulse effect
		var s = 1.0 + sin(Time.get_ticks_msec() * 0.01) * 0.2
		scale = Vector2(s, s)

func explode():
	exploded = true
	sprite.hide()
	
	# Damage enemies in range
	var bodies = area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies") and body.has_method("take_damage"):
			body.take_damage(damage)
	
	# Visual effect (simple color flash for now)
	var flash = ColorRect.new()
	flash.color = Color(1, 0.5, 0, 0.5)
	flash.size = Vector2(radius*2, radius*2)
	flash.position = -Vector2(radius, radius)
	add_child(flash)
	
	await get_tree().create_timer(0.2).timeout
	queue_free()
