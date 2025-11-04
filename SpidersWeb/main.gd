# Main.gd
extends Node2D

# Web building
var anchor_points = []
var anchor_connections = {}  # Track connections per anchor
var web_lines = []
var current_anchor = null
var is_dragging = false
var temp_line = null
var max_connections_per_anchor = 3

# Placeable anchors
var placeable_anchors_count = 0
var is_placing_anchor = false

# Bugs
var bugs = []
var bug_scene = preload("res://Bug.tscn")
var bug_spawn_timer = 0.0
var bug_spawn_interval = 2.0
var bonus_bug_spawn_timer = 0.0
const BONUS_BUG_SPAWN_INTERVAL = 8.0

# Auto-collect timer
var auto_collect_timer = 0.0
var auto_collect_enabled = false
const AUTO_COLLECT_INTERVAL = 3.0

# Game state
var score = 0
var level = 1
const ANCHORS_PER_LEVEL = 8
const WEB_CATCH_DISTANCE = 20.0
const POINTS_PER_LEVEL = 300

# Upgrades
var bug_point_value = 10
var bug_point_multiplier = 1
var bug_speed_multiplier = 1.0
var max_bugs_on_screen = 5

# UI
var score_label
var level_label
var shop_panel
var shop_button
var placing_anchor_label
var auto_collect_label

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
	
	# Shop button
	shop_button = Button.new()
	shop_button.text = "SHOP"
	shop_button.position = Vector2(20, 90)
	shop_button.size = Vector2(100, 40)
	shop_button.pressed.connect(_on_shop_button_pressed)
	add_child(shop_button)
	
	# Placing anchor label
	placing_anchor_label = Label.new()
	placing_anchor_label.position = Vector2(20, 140)
	placing_anchor_label.add_theme_font_size_override("font_size", 20)
	placing_anchor_label.add_theme_color_override("font_color", Color.YELLOW)
	placing_anchor_label.text = "Click to place anchor"
	placing_anchor_label.visible = false
	add_child(placing_anchor_label)
	
	# Auto collect label
	auto_collect_label = Label.new()
	auto_collect_label.position = Vector2(20, 170)
	auto_collect_label.add_theme_font_size_override("font_size", 18)
	auto_collect_label.add_theme_color_override("font_color", Color.CYAN)
	auto_collect_label.text = "Auto-Collect: OFF"
	add_child(auto_collect_label)
	
	# Shop panel
	setup_shop_panel()

func setup_shop_panel():
	shop_panel = Panel.new()
	shop_panel.position = Vector2(250, 100)
	shop_panel.size = Vector2(500, 550)
	shop_panel.visible = false
	add_child(shop_panel)
	
	var container = VBoxContainer.new()
	container.position = Vector2(20, 20)
	shop_panel.add_child(container)
	
	# Title
	var title = Label.new()
	title.text = "=== SHOP ==="
	title.add_theme_font_size_override("font_size", 28)
	container.add_child(title)
	
	container.add_child(create_spacer(15))
	
	# Max connections upgrade
	var connections_btn = Button.new()
	connections_btn.text = "Increase Web Connections (+1)\nCost: 50 | Current: " + str(max_connections_per_anchor)
	connections_btn.custom_minimum_size = Vector2(460, 50)
	connections_btn.pressed.connect(_on_buy_connections)
	container.add_child(connections_btn)
	
	container.add_child(create_spacer(8))
	
	# Placeable anchor
	var anchor_btn = Button.new()
	anchor_btn.text = "Buy Placeable Anchor\nCost: 100"
	anchor_btn.custom_minimum_size = Vector2(460, 50)
	anchor_btn.pressed.connect(_on_buy_anchor)
	container.add_child(anchor_btn)
	
	container.add_child(create_spacer(8))
	
	# Bug point value upgrade
	var points_btn = Button.new()
	points_btn.text = "Increase Bug Value (+5 points)\nCost: 75 | Current: " + str(bug_point_value)
	points_btn.custom_minimum_size = Vector2(460, 50)
	points_btn.pressed.connect(_on_buy_bug_value)
	container.add_child(points_btn)
	
	container.add_child(create_spacer(8))
	
	# Bug speed upgrade
	var speed_btn = Button.new()
	speed_btn.text = "Increase Bug Speed (+20%)\nCost: 60 | Multiplier: " + str(bug_speed_multiplier) + "x"
	speed_btn.custom_minimum_size = Vector2(460, 50)
	speed_btn.pressed.connect(_on_buy_bug_speed)
	container.add_child(speed_btn)
	
	container.add_child(create_spacer(8))
	
	# Max bugs upgrade
	var max_bugs_btn = Button.new()
	max_bugs_btn.text = "Increase Bug Spawns (+2 max)\nCost: 80 | Current: " + str(max_bugs_on_screen)
	max_bugs_btn.custom_minimum_size = Vector2(460, 50)
	max_bugs_btn.pressed.connect(_on_buy_max_bugs)
	container.add_child(max_bugs_btn)
	
	container.add_child(create_spacer(8))
	
	# Auto collect upgrade
	var auto_collect_btn = Button.new()
	if auto_collect_enabled:
		auto_collect_btn.text = "Auto-Collect: ACTIVE"
	else:
		auto_collect_btn.text = "Enable Auto-Collect Timer\nCost: 150"
	auto_collect_btn.custom_minimum_size = Vector2(460, 50)
	auto_collect_btn.pressed.connect(_on_buy_auto_collect)
	container.add_child(auto_collect_btn)
	
	container.add_child(create_spacer(15))
	
	# Close button
	var close_btn = Button.new()
	close_btn.text = "CLOSE"
	close_btn.custom_minimum_size = Vector2(460, 40)
	close_btn.pressed.connect(_on_shop_close)
	container.add_child(close_btn)

func create_spacer(height: int) -> Control:
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, height)
	return spacer

func _on_shop_button_pressed():
	shop_panel.visible = true

func _on_shop_close():
	shop_panel.visible = false

func _on_buy_connections():
	if score >= 50:
		score -= 50
		max_connections_per_anchor += 1
		update_score()
		update_shop_buttons()

func _on_buy_anchor():
	if score >= 100:
		score -= 100
		placeable_anchors_count += 1
		is_placing_anchor = true
		placing_anchor_label.visible = true
		shop_panel.visible = false
		update_score()

func _on_buy_bug_value():
	if score >= 75:
		score -= 75
		bug_point_value += 5
		update_score()
		update_shop_buttons()

func _on_buy_bug_speed():
	if score >= 60:
		score -= 60
		bug_speed_multiplier += 0.2
		update_score()
		update_shop_buttons()

func _on_buy_max_bugs():
	if score >= 80:
		score -= 80
		max_bugs_on_screen += 2
		update_score()
		update_shop_buttons()

func _on_buy_auto_collect():
	if not auto_collect_enabled and score >= 150:
		score -= 150
		auto_collect_enabled = true
		auto_collect_label.text = "Auto-Collect: ON"
		update_score()
		update_shop_buttons()

func update_shop_buttons():
	if shop_panel and shop_panel.get_child_count() > 0:
		var container = shop_panel.get_child(0)
		if container.get_child_count() > 2:
			container.get_child(2).text = "Increase Web Connections (+1)\nCost: 50 | Current: " + str(max_connections_per_anchor)
		if container.get_child_count() > 6:
			container.get_child(6).text = "Increase Bug Value (+5 points)\nCost: 75 | Current: " + str(bug_point_value)
		if container.get_child_count() > 8:
			container.get_child(8).text = "Increase Bug Speed (+20%)\nCost: 60 | Multiplier: " + str(snapped(bug_speed_multiplier, 0.1)) + "x"
		if container.get_child_count() > 10:
			container.get_child(10).text = "Increase Bug Spawns (+2 max)\nCost: 80 | Current: " + str(max_bugs_on_screen)
		if container.get_child_count() > 12:
			if auto_collect_enabled:
				container.get_child(12).text = "Auto-Collect: ACTIVE"
			else:
				container.get_child(12).text = "Enable Auto-Collect Timer\nCost: 150"

func update_score():
	score_label.text = "Score: " + str(score)

func spawn_anchor_points():
	anchor_points.clear()
	anchor_connections.clear()
	var margin = 100
	var screen_size = get_viewport_rect().size
	
	for i in range(ANCHORS_PER_LEVEL):
		var pos = Vector2(
			randf_range(margin, screen_size.x - margin),
			randf_range(margin + 80, screen_size.y - margin)
		)
		anchor_points.append(pos)
		anchor_connections[pos] = 0

func _draw():
	# Draw anchor points
	for anchor in anchor_points:
		var connections = anchor_connections.get(anchor, 0)
		var color = Color.GRAY
		if connections >= max_connections_per_anchor:
			color = Color.RED
		draw_circle(anchor, 8, Color.DARK_GRAY)
		draw_circle(anchor, 6, color)
		
		# Draw connection count
		var font_pos = anchor + Vector2(-5, 20)
		draw_string(ThemeDB.fallback_font, font_pos, str(connections) + "/" + str(max_connections_per_anchor), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
	
	# Draw web lines
	for line in web_lines:
		draw_line(line["start"], line["end"], Color.WHITE, 2.0)
	
	# Draw temporary line while dragging
	if is_dragging and current_anchor != null:
		draw_line(current_anchor, get_global_mouse_position(), Color(1, 1, 1, 0.5), 2.0)
	
	# Draw preview for placing anchor
	if is_placing_anchor:
		var mouse_pos = get_global_mouse_position()
		draw_circle(mouse_pos, 10, Color(0, 1, 0, 0.5))
		draw_circle(mouse_pos, 8, Color(0, 1, 0, 0.3))

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Placing anchor mode
				if is_placing_anchor:
					var new_anchor = event.position
					anchor_points.append(new_anchor)
					anchor_connections[new_anchor] = 0
					placeable_anchors_count -= 1
					is_placing_anchor = false
					placing_anchor_label.visible = false
					queue_redraw()
					return
				
				# Check if clicked on anchor
				for anchor in anchor_points:
					if anchor.distance_to(event.position) < 15:
						# Check if anchor has room for more connections
						if anchor_connections.get(anchor, 0) < max_connections_per_anchor:
							current_anchor = anchor
							is_dragging = true
						break
			else:
				# Released mouse
				if is_dragging and current_anchor != null:
					# Check if released on another anchor
					for anchor in anchor_points:
						if anchor != current_anchor and anchor.distance_to(event.position) < 15:
							# Check if target anchor has room
							if anchor_connections.get(anchor, 0) < max_connections_per_anchor:
								# Create web line
								web_lines.append({
									"start": current_anchor,
									"end": anchor
								})
								anchor_connections[current_anchor] += 1
								anchor_connections[anchor] += 1
							break
				is_dragging = false
				current_anchor = null
				queue_redraw()
	
	elif event is InputEventMouseMotion:
		if is_dragging or is_placing_anchor:
			queue_redraw()

func _process(delta):
	# Auto-collect caught bugs
	if auto_collect_enabled:
		auto_collect_timer += delta
		if auto_collect_timer >= AUTO_COLLECT_INTERVAL:
			auto_collect_timer = 0.0
			collect_caught_bugs()
	
	# Count active bugs
	var active_bug_count = 0
	for bug in bugs:
		if is_instance_valid(bug):
			active_bug_count += 1
	
	# Spawn regular bugs
	if active_bug_count < max_bugs_on_screen:
		bug_spawn_timer += delta
		if bug_spawn_timer >= bug_spawn_interval:
			bug_spawn_timer = 0.0
			spawn_bug(false)
	
	# Spawn bonus bugs
	bonus_bug_spawn_timer += delta
	if bonus_bug_spawn_timer >= BONUS_BUG_SPAWN_INTERVAL:
		bonus_bug_spawn_timer = 0.0
		spawn_bug(true)
	
	# Check for bugs caught in web (iterate backwards to safely remove)
	for i in range(bugs.size() - 1, -1, -1):
		var bug = bugs[i]
		if not is_instance_valid(bug):
			bugs.remove_at(i)
			continue
		if bug.is_alive and not bug.is_caught:
			if is_bug_in_web(bug.position):
				bug.catch_in_web()

func collect_caught_bugs():
	for i in range(bugs.size() - 1, -1, -1):
		var bug = bugs[i]
		if is_instance_valid(bug) and bug.is_caught:
			score += bug.point_value
			update_score()
			bugs.remove_at(i)
			bug.queue_free()
	
	# Check for level completion
	if score >= level * POINTS_PER_LEVEL:
		next_level()

func spawn_bug(is_bonus: bool):
	var screen_size = get_viewport_rect().size
	var bug = bug_scene.instantiate()
	
	if is_bonus:
		# Bonus bug spawns randomly on screen
		bug.position = Vector2(
			randf_range(100, screen_size.x - 100),
			randf_range(100, screen_size.y - 100)
		)
		# Short travel distance
		var angle = randf() * TAU
		bug.target = bug.position + Vector2(cos(angle), sin(angle)) * randf_range(150, 250)
		bug.is_bonus = true
		bug.point_value = 50
		bug.speed = randf_range(180.0, 220.0) * bug_speed_multiplier
	else:
		# Regular bug spawns from edges
		var side = randi() % 4
		match side:
			0: # Top
				bug.position = Vector2(randf_range(0, screen_size.x), -20)
				bug.target = Vector2(randf_range(0, screen_size.x), screen_size.y + 50)
			1: # Right
				bug.position = Vector2(screen_size.x + 20, randf_range(0, screen_size.y))
				bug.target = Vector2(-50, randf_range(0, screen_size.y))
			2: # Bottom
				bug.position = Vector2(randf_range(0, screen_size.x), screen_size.y + 20)
				bug.target = Vector2(randf_range(0, screen_size.x), -50)
			3: # Left
				bug.position = Vector2(-20, randf_range(0, screen_size.y))
				bug.target = Vector2(screen_size.x + 50, randf_range(0, screen_size.y))
		
		bug.is_bonus = false
		bug.point_value = bug_point_value
		bug.speed = randf_range(100.0, 150.0) * bug_speed_multiplier
	
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
	if not is_instance_valid(bug):
		return
	if bug.is_caught:
		score += bug.point_value
		update_score()
		bugs.erase(bug)
		bug.queue_free()
		
		# Check for level completion
		if score >= level * POINTS_PER_LEVEL:
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
