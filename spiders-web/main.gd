# Main.gd
extends Node2D

# Web building
var anchor_points = []
var web_lines = []
var current_anchor = null
var is_dragging = false
var temp_line = null

# Bugs
var bugs = []
var bug_scene = preload("res://bug.tscn")  # You'll need to create this
var bug_spawn_timer = 0.0
const BUG_SPAWN_INTERVAL = 2.0

# Game state
var score = 0
var level = 1
const ANCHORS_PER_LEVEL = 8
const WEB_CATCH_DISTANCE = 50.0

# UI
var score_label
var level_label

func _ready():
	randomize()
	setup_ui()
	spawn_anchor_points()
	
func setup_ui():
	# Score label
	score_label = Label.new()
	score_label.position = Vector2(20, 20)
	score_label.add_theme_font_size_override("font_size", 24)
	score_label.text = "Score: 0"
	add_child(score_label)
	
	# Level label
	level_label = Label.new()
	level_label.position = Vector2(20, 50)
	level_label.add_theme_font_size_override("font_size", 24)
	level_label.text = "Level: 1"
	add_child(level_label)

func spawn_anchor_points():
	anchor_points.clear()
	var margin = 100
	var screen_size = get_viewport_rect().size
	
	for i in range(ANCHORS_PER_LEVEL):
		var pos = Vector2(
			randf_range(margin, screen_size.x - margin),
			randf_range(margin + 80, screen_size.y - margin)
		)
		anchor_points.append(pos)

func _draw():
	# Draw anchor points
	for anchor in anchor_points:
		draw_circle(anchor, 8, Color.DARK_GRAY)
		draw_circle(anchor, 6, Color.GRAY)
	
	# Draw web lines
	for line in web_lines:
		draw_line(line["start"], line["end"], Color.WHITE, 2.0)
	
	# Draw temporary line while dragging
	if is_dragging and current_anchor != null:
		draw_line(current_anchor, get_global_mouse_position(), Color(1, 1, 1, 0.5), 2.0)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Check if clicked on anchor
				for anchor in anchor_points:
					if anchor.distance_to(event.position) < 15:
						current_anchor = anchor
						is_dragging = true
						break
			else:
				# Released mouse
				if is_dragging and current_anchor != null:
					# Check if released on another anchor
					for anchor in anchor_points:
						if anchor != current_anchor and anchor.distance_to(event.position) < 15:
							# Create web line
							web_lines.append({
								"start": current_anchor,
								"end": anchor
							})
							break
				is_dragging = false
				current_anchor = null
				queue_redraw()
	
	elif event is InputEventMouseMotion:
		if is_dragging:
			queue_redraw()

func _process(delta):
	# Spawn bugs
	bug_spawn_timer += delta
	if bug_spawn_timer >= BUG_SPAWN_INTERVAL:
		bug_spawn_timer = 0.0
		spawn_bug()
	
	# Check for bugs caught in web
	for bug in bugs:
		if bug.is_alive and not bug.is_caught:
			if is_bug_in_web(bug.position):
				bug.catch_in_web()

func spawn_bug():
	var screen_size = get_viewport_rect().size
	var bug = bug_scene.instantiate()
	
	# Spawn from random edge
	var side = randi() % 4
	match side:
		0: bug.position = Vector2(randf_range(0, screen_size.x), -20)  # Top
		1: bug.position = Vector2(screen_size.x + 20, randf_range(0, screen_size.y))  # Right
		2: bug.position = Vector2(randf_range(0, screen_size.x), screen_size.y + 20)  # Bottom
		3: bug.position = Vector2(-20, randf_range(0, screen_size.y))  # Left
	
	# Random target position
	bug.target = Vector2(randf_range(100, screen_size.x - 100), randf_range(100, screen_size.y - 100))
	
	add_child(bug)
	bugs.append(bug)
	bug.clicked.connect(_on_bug_clicked)

func is_bug_in_web(bug_pos: Vector2) -> bool:
	for line in web_lines:
		var dist = point_to_line_distance(bug_pos, line["start"], line["end"])
		if dist < WEB_CATCH_DISTANCE:
			return true
	return false

func point_to_line_distance(point: Vector2, line_start: Vector2, line_end: Vector2) -> float:
	var line_vec = line_end - line_start
	var point_vec = point - line_start
	var line_len = line_vec.length()
	
	if line_len == 0:
		return point.distance_to(line_start)
	
	var t = clamp(point_vec.dot(line_vec) / (line_len * line_len), 0.0, 1.0)
	var projection = line_start + t * line_vec
	return point.distance_to(projection)

func _on_bug_clicked(bug):
	if bug.is_caught:
		score += 10
		score_label.text = "Score: " + str(score)
		bugs.erase(bug)
		bug.queue_free()
		
		# Check for level completion
		if score >= level * 100:
			next_level()

func next_level():
	level += 1
	level_label.text = "Level: " + str(level)
	
	# Clear everything
	for bug in bugs:
		bug.queue_free()
	bugs.clear()
	web_lines.clear()
	
	# Spawn new anchors
	spawn_anchor_points()
	queue_redraw()
