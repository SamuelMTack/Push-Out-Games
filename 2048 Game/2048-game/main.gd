extends Node2D

# Game grid size
const GRID_SIZE = 4
const CELL_COUNT = GRID_SIZE * GRID_SIZE

# Tile colors (RGB)
const COLORS = {
	0: Color(205, 193, 180),
	2: Color(238, 228, 218),
	4: Color(237, 224, 200),
	8: Color(242, 177, 121),
	16: Color(245, 149, 99),
	32: Color(246, 124, 95),
	64: Color(246, 94, 59),
	128: Color(237, 197, 63),
	256: Color(237, 197, 63),
	512: Color(237, 197, 63),
	1024: Color(237, 197, 63),
	2048: Color(237, 197, 63)
}

# Tile font sizes
const FONT_SIZES = {
	0: 40,
	2: 40,
	4: 40,
	8: 40,
	16: 40,
	32: 40,
	64: 40,
	128: 35,
	256: 35,
	512: 35,
	1024: 30,
	2048: 30
}

# Game state variables
var grid = []
var score = 0
var best_score = 0

# Node references
@onready var tile_container = $TileContainer
@onready var score_label = $ScoreLabel
@onready var best_label = $BestLabel
@onready var game_over_label = $GameOverLabel
@onready var restart_button = $RestartButton

func _ready():
	# Load best score from save
	best_score = load_best_score()
	update_labels()
	new_game()

func new_game():
	grid = []
	for i in range(GRID_SIZE):
		grid.append([])
		for j in range(GRID_SIZE):
			grid[i].append(0)
	
	score = 0
	game_over_label.hide()
	restart_button.hide()
	add_random_tile()
	add_random_tile()
	update_grid()

func add_random_tile():
	var empty_cells = []
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			if grid[i][j] == 0:
				empty_cells.append(Vector2(i, j))
	
	if empty_cells.size() > 0:
		var random_cell = empty_cells[randi() % empty_cells.size()]
		grid[random_cell.x][random_cell.y] = 2 if randf() < 0.9 else 4
		update_grid()

func update_grid():
	# Clear existing tiles
	for child in tile_container.get_children():
		child.queue_free()
	
	# Create new tiles
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			if grid[i][j] != 0:
				var tile = preload("res://Tile.tscn").instantiate()
				tile.position = Vector2(100 + j * 110, 100 + i * 110)
				tile.text = str(grid[i][j])
				tile.modulate = COLORS[grid[i][j]]
				tile.font_size = FONT_SIZES[grid[i][j]]
				tile_container.add_child(tile)

func update_labels():
	score_label.text = "Score\n" + str(score)
	best_label.text = "Best\n" + str(best_score)

func load_best_score():
	# Try to load from save, return 0 if not found
#	if save_data.has("best_score"):
#		return save_data.best_score
	return 0

func save_best_score():
	# Save best score
#	save_data.best_score = best_score
	# In Godot, you would typically use File or JSON to save data
	# For simplicity, we're just using a variable here
	pass

func move(direction):
	var moved = false
	var temp_grid = []
	
	# Copy grid
	for i in range(GRID_SIZE):
		temp_grid.append([])
		for j in range(GRID_SIZE):
			temp_grid[i].append(grid[i][j])
	
	# Process based on direction
	match direction:
		"up":
			moved = move_up()
		"down":
			moved = move_down()
		"left":
			moved = move_left()
		"right":
			moved = move_right()
	
	if moved:
		add_random_tile()
		update_grid()
		update_labels()
		check_game_over()
	
	return moved

func move_up():
	var moved = false
	for j in range(GRID_SIZE):
		var row = []
		for i in range(GRID_SIZE):
			if grid[i][j] != 0:
				row.append(grid[i][j])
		
		# Merge
		for i in range(row.size() - 1):
			if row[i] == row[i + 1]:
				row[i] *= 2
				score += row[i]
				row.remove_at(i + 1)
				moved = true
		
		# Fill with zeros
		while row.size() < GRID_SIZE:
			row.append(0)
		
		# Update grid
		for i in range(GRID_SIZE):
			if grid[i][j] != row[i]:
				moved = true
			grid[i][j] = row[i]
	
	return moved

func move_down():
	var moved = false
	for j in range(GRID_SIZE):
		var row = []
		for i in range(GRID_SIZE - 1, -1, -1):
			if grid[i][j] != 0:
				row.append(grid[i][j])
		
		# Merge
		for i in range(row.size() - 1):
			if row[i] == row[i + 1]:
				row[i] *= 2
				score += row[i]
				row.remove_at(i + 1)
				moved = true
		
		# Fill with zeros
		while row.size() < GRID_SIZE:
			row.append(0)
		
		# Update grid
		for i in range(GRID_SIZE - 1, -1, -1):
			if grid[i][j] != row[GRID_SIZE - 1 - i]:
				moved = true
			grid[i][j] = row[GRID_SIZE - 1 - i]
	
	return moved

func move_left():
	var moved = false
	for i in range(GRID_SIZE):
		var row = []
		for j in range(GRID_SIZE):
			if grid[i][j] != 0:
				row.append(grid[i][j])
		
		# Merge
		for j in range(row.size() - 1):
			if row[j] == row[j + 1]:
				row[j] *= 2
				score += row[j]
				row.remove_at(j + 1)
				moved = true
		
		# Fill with zeros
		while row.size() < GRID_SIZE:
			row.append(0)
		
		# Update grid
		for j in range(GRID_SIZE):
			if grid[i][j] != row[j]:
				moved = true
			grid[i][j] = row[j]
	
	return moved

func move_right():
	var moved = false
	for i in range(GRID_SIZE):
		var row = []
		for j in range(GRID_SIZE - 1, -1, -1):
			if grid[i][j] != 0:
				row.append(grid[i][j])
		
		# Merge
		for j in range(row.size() - 1):
			if row[j] == row[j + 1]:
				row[j] *= 2
				score += row[j]
				row.remove_at(j + 1)
				moved = true
		
		# Fill with zeros
		while row.size() < GRID_SIZE:
			row.append(0)
		
		# Update grid
		for j in range(GRID_SIZE - 1, -1, -1):
			if grid[i][j] != row[GRID_SIZE - 1 - j]:
				moved = true
			grid[i][j] = row[GRID_SIZE - 1 - j]
	
	return moved

func check_game_over():
	var game_over = true
	
	# Check for empty cells
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			if grid[i][j] == 0:
				game_over = false
				break
	
	# If no empty cells, check for possible merges
	if game_over:
		for i in range(GRID_SIZE):
			for j in range(GRID_SIZE):
				var current = grid[i][j]
				if (i < GRID_SIZE - 1 and grid[i + 1][j] == current) or \
				   (j < GRID_SIZE - 1 and grid[i][j + 1] == current):
					game_over = false
					break
	
	if game_over:
		game_over_label.show()
		restart_button.show()
		if score > best_score:
			best_score = score
			save_best_score()

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_UP:
				move("up")
			KEY_DOWN:
				move("down")
			KEY_LEFT:
				move("left")
			KEY_RIGHT:
				move("right")

func _on_RestartButton_pressed():
	new_game()
