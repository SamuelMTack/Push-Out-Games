extends Weapon

@export var swing_speed: float = 0.2
@export var swing_arc: float = 120.0
@export var range_distance: float = 100.0

var sprite: Sprite2D
var area: Area2D
var collision: CollisionPolygon2D
var is_swinging: bool = false

func _ready():
	super._ready()
	
	# Create visual and collision components if not in scene
	if not has_node("Sprite2D"):
		sprite = Sprite2D.new()
		sprite.texture = preload("res://Assets/Sprites/Weapons/weapon_sword.png")
		sprite.position = Vector2(range_distance/2, 0)
		sprite.rotation_degrees = -45
		add_child(sprite)
		sprite.hide()
	else:
		sprite = $Sprite2D
		
	if not has_node("Area2D"):
		area = Area2D.new()
		add_child(area)
		collision = CollisionPolygon2D.new()
		# Create a cone shape polygon
		var points = PackedVector2Array([Vector2(0, 0)])
		var segments = 10
		for i in range(segments + 1):
			var angle = deg_to_rad(-swing_arc/2 + i * (swing_arc/segments))
			points.append(Vector2(cos(angle), sin(angle)) * range_distance)
		collision.polygon = points
		area.add_child(collision)
		# Connect signal
		area.body_entered.connect(_on_body_entered)
		area.monitoring = false
	else:
		area = $Area2D

func attack():
	if is_swinging: return
	
	super.attack()
	is_swinging = true
	sprite.show()
	area.monitoring = true
	
	# Determine direction (side to side relative to player facing)
	# We'll alternate swing direction
	var player_facing = Vector2.RIGHT
	if player and player.velocity.length() > 0:
		player_facing = player.velocity.normalized()
	
	# If player not moving, use last facing or mouse? Let's use current rotation or default right
	# Actually, let's just swing left-to-right and right-to-left relative to facing
	
	var base_angle = player_facing.angle()
	var start_angle = base_angle - deg_to_rad(swing_arc/2)
	var end_angle = base_angle + deg_to_rad(swing_arc/2)
	
	# Alternate swing
	if randf() > 0.5:
		var temp = start_angle
		start_angle = end_angle
		end_angle = temp
		
	rotation = start_angle
	
	# Animate swing
	var tween = create_tween()
	tween.tween_property(self, "rotation", end_angle, swing_speed).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func():
		is_swinging = false
		sprite.hide()
		area.monitoring = false
	)

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
