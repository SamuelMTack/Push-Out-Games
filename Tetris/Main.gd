extends Node2D

const Tetromino = preload("Tetromino.gd")

const GRID_WIDTH = 10
const GRID_HEIGHT = 20
const CELL_SIZE = 40
const MARGIN_X = 50
const MARGIN_Y = 50

var grid = []
var current_piece = null
var next_piece = null
var current_pos = Vector2i(0, 0)
var timer = 0.0
var drop_interval = 0.5
var score = 0
var game_running = false

var score_label: Label
var game_over_label: Label

func _ready():
	# Initialize grid
	for x in range(GRID_WIDTH):
		grid.append([])
		for y in range(GRID_HEIGHT):
			grid[x].append(null)
	
	# Setup UI
	score_label = Label.new()
	score_label.position = Vector2(MARGIN_X, MARGIN_Y - 30)
	add_child(score_label)
	
	game_over_label = Label.new()
	game_over_label.text = "GAME OVER\nPress Space to Restart"
	game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_label.position = Vector2(MARGIN_X, MARGIN_Y + 200)
	game_over_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	# Manually center it roughly based on grid width
	game_over_label.size = Vector2(GRID_WIDTH * CELL_SIZE, 100)
	game_over_label.visible = false
	add_child(game_over_label)
	
	next_piece = get_random_piece()
	new_game()

func new_game():
	score = 0
	game_running = true
	game_over_label.visible = false
	update_score_label()
	
	# Clear grid
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			grid[x][y] = null
	
	spawn_piece()

func update_score_label():
	score_label.text = "Score: " + str(score)

func get_random_piece():
	var shape_idx = randi() % Tetromino.SHAPES.size()
	var shape_data = Tetromino.SHAPES[shape_idx]
	return {
		"shape": shape_data.cells.duplicate(),
		"color": shape_data.color
	}

func spawn_piece():
	current_piece = next_piece
	next_piece = get_random_piece()
	
	current_pos = Vector2i(GRID_WIDTH / 2 - 1, 0) 
	
	if not is_valid_position(current_piece.shape, current_pos):
		game_over()

func _process(delta):
	if not game_running:
		if Input.is_action_just_pressed("ui_accept"):
			new_game()
		return
	
	timer += delta
	if timer >= drop_interval:
		timer = 0
		move_piece(Vector2i(0, 1))
	
	if Input.is_action_just_pressed("ui_left"):
		move_piece(Vector2i(-1, 0))
	elif Input.is_action_just_pressed("ui_right"):
		move_piece(Vector2i(1, 0))
	elif Input.is_action_just_pressed("ui_down"):
		move_piece(Vector2i(0, 1))
	elif Input.is_action_just_pressed("ui_up"):
		rotate_piece()
	elif Input.is_action_just_pressed("ui_accept"):
		hard_drop()
	
	queue_redraw()

func move_piece(dir: Vector2i):
	if is_valid_position(current_piece.shape, current_pos + dir):
		current_pos += dir
		return true
	elif dir == Vector2i(0, 1):
		lock_piece()
		return false
	return false

func hard_drop():
	while move_piece(Vector2i(0, 1)):
		pass

func rotate_piece():
	var new_shape = []
	for cell in current_piece.shape:
		# 90 degree rotation: (x, y) -> (-y, x)
		new_shape.append(Vector2i(-cell.y, cell.x))
	
	if is_valid_position(new_shape, current_pos):
		current_piece.shape = new_shape
	# Wall kick (simple)
	elif is_valid_position(new_shape, current_pos + Vector2i(1, 0)):
		current_pos += Vector2i(1, 0)
		current_piece.shape = new_shape
	elif is_valid_position(new_shape, current_pos + Vector2i(-1, 0)):
		current_pos += Vector2i(-1, 0)
		current_piece.shape = new_shape

func is_valid_position(shape, pos):
	for cell in shape:
		var abs_x = pos.x + cell.x
		var abs_y = pos.y + cell.y
		
		if abs_x < 0 or abs_x >= GRID_WIDTH or abs_y >= GRID_HEIGHT:
			return false
		if abs_y >= 0 and grid[abs_x][abs_y] != null:
			return false
	return true

func lock_piece():
	for cell in current_piece.shape:
		var abs_x = current_pos.x + cell.x
		var abs_y = current_pos.y + cell.y
		if abs_y >= 0:
			grid[abs_x][abs_y] = current_piece.color
	
	clear_lines()
	spawn_piece()

func clear_lines():
	var new_grid = []
	# Init empty
	for x in range(GRID_WIDTH):
		new_grid.append([])
		for y in range(GRID_HEIGHT):
			new_grid[x].append(null)
			
	var target_y = GRID_HEIGHT - 1
	var lines_cleared = 0
	
	for y in range(GRID_HEIGHT - 1, -1, -1):
		var full = true
		for x in range(GRID_WIDTH):
			if grid[x][y] == null:
				full = false
				break
		
		if not full:
			# Copy row to target_y
			for x in range(GRID_WIDTH):
				new_grid[x][target_y] = grid[x][y]
			target_y -= 1
		else:
			lines_cleared += 1
			
	grid = new_grid
	
	if lines_cleared > 0:
		score += lines_cleared * 100
		update_score_label()

func game_over():
	game_running = false
	game_over_label.visible = true

func _draw():
	# Draw Grid Background
	draw_rect(Rect2(MARGIN_X, MARGIN_Y, GRID_WIDTH * CELL_SIZE, GRID_HEIGHT * CELL_SIZE), Color(0.1, 0.1, 0.1))
	
	# Draw Locked Blocks
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			if grid[x][y] != null:
				draw_rect(Rect2(MARGIN_X + x * CELL_SIZE, MARGIN_Y + y * CELL_SIZE, CELL_SIZE, CELL_SIZE), grid[x][y])
				draw_rect(Rect2(MARGIN_X + x * CELL_SIZE, MARGIN_Y + y * CELL_SIZE, CELL_SIZE, CELL_SIZE), Color.BLACK, false, 1.0) # Border
	
	# Draw Current Piece
	if current_piece and game_running:
		for cell in current_piece.shape:
			var abs_x = current_pos.x + cell.x
			var abs_y = current_pos.y + cell.y
			if abs_y >= 0: # Don't draw above grid
				draw_rect(Rect2(MARGIN_X + abs_x * CELL_SIZE, MARGIN_Y + abs_y * CELL_SIZE, CELL_SIZE, CELL_SIZE), current_piece.color)
				draw_rect(Rect2(MARGIN_X + abs_x * CELL_SIZE, MARGIN_Y + abs_y * CELL_SIZE, CELL_SIZE, CELL_SIZE), Color.WHITE, false, 1.0)

	# Draw Next Piece Preview
	var preview_x = MARGIN_X + GRID_WIDTH * CELL_SIZE + 20
	var preview_y = MARGIN_Y
	draw_string(ThemeDB.fallback_font, Vector2(preview_x, preview_y), "Next:")
	
	if next_piece:
		var preview_center_x = preview_x + 50
		var preview_center_y = preview_y + 50
		for cell in next_piece.shape:
			draw_rect(Rect2(preview_center_x + cell.x * CELL_SIZE, preview_center_y + cell.y * CELL_SIZE, CELL_SIZE, CELL_SIZE), next_piece.color)
			draw_rect(Rect2(preview_center_x + cell.x * CELL_SIZE, preview_center_y + cell.y * CELL_SIZE, CELL_SIZE, CELL_SIZE), Color.WHITE, false, 1.0)
