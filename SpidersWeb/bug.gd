# Bug.gd
extends Node2D

signal clicked(bug)

var target = Vector2.ZERO
var speed = 50.0
var is_alive = true
var is_caught = false
var struggle_timer = 0.0
var is_bonus = false
var point_value = 10

func _process(delta):
	if is_alive and not is_caught:
		# Move towards target
		var direction = (target - position).normalized()
		position += direction * speed * delta
		
		# Check if reached target or off screen
		if is_bonus:
			# Bonus bugs disappear when reaching target
			if position.distance_to(target) < 10:
				queue_free()
		else:
			# Regular bugs disappear off screen
			var screen_size = get_viewport_rect().size
			if position.x < -50 or position.x > screen_size.x + 50 or position.y < -50 or position.y > screen_size.y + 50:
				queue_free()
	
	elif is_caught:
		# Struggle animation
		struggle_timer += delta
		rotation = sin(struggle_timer * 10.0) * 0.3
		queue_redraw()

func catch_in_web():
	is_caught = true
	speed = 0
	queue_redraw()

func _draw():
	if is_bonus:
		# Draw bonus bug - larger and purple/gold
		draw_circle(Vector2.ZERO, 12, Color.PURPLE)
		draw_circle(Vector2.ZERO, 10, Color.GOLD)
		
		# Draw star points
		for i in range(8):
			var angle = (i / 8.0) * TAU
			var point_start = Vector2(cos(angle), sin(angle)) * 10
			var point_end = Vector2(cos(angle), sin(angle)) * 16
			draw_line(point_start, point_end, Color.YELLOW, 3.0)
		
		# Draw sparkle effect
		if not is_caught:
			var sparkle_offset = sin(Time.get_ticks_msec() * 0.01) * 3
			draw_circle(Vector2(sparkle_offset, -sparkle_offset), 3, Color(1, 1, 1, 0.8))
	else:
		# Draw regular bug body
		if is_caught:
			draw_circle(Vector2.ZERO, 8, Color.YELLOW)
			draw_circle(Vector2.ZERO, 6, Color(0.8, 0.6, 0.0))
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
			var click_radius = 16 if is_bonus else 10
			if local_pos.length() < click_radius:
				clicked.emit(self)

func _notification(what):
	if what == NOTIFICATION_DRAW:
		queue_redraw()
