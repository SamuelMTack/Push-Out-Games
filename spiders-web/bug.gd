# Bug.gd
extends Node2D

signal clicked(bug)

var target = Vector2.ZERO
var speed = 50.0
var is_alive = true
var is_caught = false
var struggle_timer = 0.0

func _ready():
	speed = randf_range(40.0, 80.0)

func _process(delta):
	if is_alive and not is_caught:
		# Move towards target
		var direction = (target - position).normalized()
		position += direction * speed * delta
		
		# Check if reached target
		if position.distance_to(target) < 10:
			queue_free()
	
	elif is_caught:
		# Struggle animation
		struggle_timer += delta
		rotation = sin(struggle_timer * 10.0) * 0.3

func catch_in_web():
	is_caught = true
	speed = 0

func _draw():
	# Draw bug body
	if is_caught:
		draw_circle(Vector2.ZERO, 8, Color.RED)
		draw_circle(Vector2.ZERO, 6, Color.DARK_RED)
	else:
		draw_circle(Vector2.ZERO, 8, Color.GREEN)
		draw_circle(Vector2.ZERO, 6, Color.DARK_GREEN)
	
	# Draw legs
	for i in range(6):
		var angle = (i / 6.0) * TAU
		var leg_start = Vector2.ZERO
		var leg_end = Vector2(cos(angle), sin(angle)) * 12
		draw_line(leg_start, leg_end, Color.BLACK, 2.0)

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var local_pos = to_local(event.position)
			if local_pos.length() < 10:
				clicked.emit(self)

func _notification(what):
	if what == NOTIFICATION_DRAW:
		queue_redraw()
