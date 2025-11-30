extends Area2D

var damage = 10.0
var duration = 3.0
var tick_rate = 0.5
var current_time = 0.0
var tick_timer = 0.0

func _ready():
	# Visuals - Create a blue circle if no sprite
	if not has_node("Sprite2D"):
		var sprite = Sprite2D.new()
		# Use a placeholder texture or generate one
		# For now, let's use a simple color rect or circle if possible, but Sprite2D needs texture.
		# We'll assume a texture is assigned or we use a ColorRect for prototype
		var color_rect = ColorRect.new()
		color_rect.size = Vector2(64, 64)
		color_rect.position = Vector2(-32, -32)
		color_rect.color = Color(0, 0.5, 1, 0.5) # Blue transparent
		add_child(color_rect)
	
	# Collision shape
	if not has_node("CollisionShape2D"):
		var shape = CollisionShape2D.new()
		var circle = CircleShape2D.new()
		circle.radius = 30
		shape.shape = circle
		add_child(shape)

func setup(dmg: float, dur: float, area_scale: float):
	damage = dmg
	duration = dur
	scale = Vector2(area_scale, area_scale)

func _process(delta):
	current_time += delta
	if current_time >= duration:
		queue_free()
		return

	tick_timer += delta
	if tick_timer >= tick_rate:
		tick_timer = 0.0
		_deal_damage()

func _deal_damage():
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies") and body.has_method("take_damage"):
			body.take_damage(damage)
