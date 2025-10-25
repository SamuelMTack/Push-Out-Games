extends Node2D



# Grid settings
const GRID_SIZE = 4
const TILE_SIZE = 100
const TILE_SPACING = 10
const ANIMATION_SPEED = 0.15

# Colors for tiles
var tile_colors = {
	2: Color(0.93, 0.89, 0.85),
	4: Color(0.93, 0.88, 0.78),
	8: Color(0.95, 0.69, 0.47),
	16: Color(0.96, 0.58, 0.39),
	32: Color(0.96, 0.49, 0.37),
	64: Color(0.96, 0.37, 0.23),
	128: Color(0.93, 0.81, 0.45),
	256: Color(0.93, 0.80, 0.38),
	512: Color(0.93, 0.78, 0.31),
	1024: Color(0.93, 0.77, 0.25),
	2048: Color(0.93, 0.76, 0.18),
	4096: Color(0.24, 0.22, 0.20)
}

var grid = []
var tiles = []
var score = 0
var is_animating = false
var game_over = false

@onready var score_label = $UI/ScoreLabel
@onready var game_over_label = $UI/GameOverLabel
@onready var restart_button = $UI/RestartButton

func _ready():
	setup_grid()
	spawn_tile()
	spawn_tile()
	update_display()
	game_over_label.hide()

func setup_grid():
	grid.clear()
	tiles.clear()
	
	for i in range(GRID_SIZE):
		grid.append([])
		tiles.append([])
		for j in range(GRID_SIZE):
			grid[i].append(0)
			tiles[i].append(null)

func get_tile_position(row, col):
	var offset_x = 150
	var offset_y = 150
	return Vector2(
		offset_x + col * (TILE_SIZE + TILE_SPACING),
		offset_y + row * (TILE_SIZE + TILE_SPACING)
	)

func create_tile(row, col, value):
	var tile = ColorRect.new()
	tile.size = Vector2(TILE_SIZE, TILE_SIZE)
	tile.position = get_tile_position(row, col)
	tile.color = tile_colors.get(value, Color(0.2, 0.2, 0.2))
	
	var label = Label.new()
	label.text = str(value)
	label.add_theme_font_size_override("font_size", 32 if value < 128 else (28 if value < 1024 else 24))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = Vector2(TILE_SIZE, TILE_SIZE)
	label.add_theme_color_override("font_color", Color.WHITE if value > 4 else Color(0.47, 0.43, 0.40))
	
	tile.add_child(label)
	add_child(tile)
	
	# Spawn animation
	tile.scale = Vector2(0.1, 0.1)
	var tween = create_tween()
	tween.tween_property(tile, "scale", Vector2(1, 1), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	return tile

func spawn_tile():
	var empty_cells = []
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			if grid[i][j] == 0:
				empty_cells.append(Vector2i(i, j))
	
	if empty_cells.size() == 0:
		return false
	
	var cell = empty_cells[randi() % empty_cells.size()]
	var value = 2 if randf() < 0.9 else 4
	grid[cell.x][cell.y] = value
	tiles[cell.x][cell.y] = create_tile(cell.x, cell.y, value)
	return true

func update_display():
	score_label.text = "Score: " + str(score)

func move_tiles(direction):
	if is_animating or game_over:
		return
	
	var moved = false
	var new_grid = []
	var merge_happened = []
	
	for i in range(GRID_SIZE):
		new_grid.append([])
		for j in range(GRID_SIZE):
			new_grid[i].append(0)
	
	# Process movement based on direction
	if direction == "left" or direction == "right":
		for i in range(GRID_SIZE):
			var row = []
			var range_array = range(GRID_SIZE) if direction == "left" else range(GRID_SIZE - 1, -1, -1)
			
			for j in range_array:
				if grid[i][j] != 0:
					row.append(grid[i][j])
			
			var merged_row = merge_row(row)
			merge_happened.append_array(merged_row[1])
			row = merged_row[0]
			
			for j in range(row.size()):
				var target_col = j if direction == "left" else (GRID_SIZE - 1 - j)
				new_grid[i][target_col] = row[j]
	else: # up or down
		for j in range(GRID_SIZE):
			var col = []
			var range_array = range(GRID_SIZE) if direction == "up" else range(GRID_SIZE - 1, -1, -1)
			
			for i in range_array:
				if grid[i][j] != 0:
					col.append(grid[i][j])
			
			var merged_col = merge_row(col)
			merge_happened.append_array(merged_col[1])
			col = merged_col[0]
			
			for i in range(col.size()):
				var target_row = i if direction == "up" else (GRID_SIZE - 1 - i)
				new_grid[target_row][j] = col[i]
	
	# Check if grid changed
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			if grid[i][j] != new_grid[i][j]:
				moved = true
				break
	
	if moved:
		animate_tiles(new_grid)
		grid = new_grid
		await get_tree().create_timer(ANIMATION_SPEED + 0.05).timeout
		spawn_tile()
		update_display()
		check_game_over()

func merge_row(row):
	var merged = []
	var merge_values = []
	var i = 0
	
	while i < row.size():
		if i + 1 < row.size() and row[i] == row[i + 1]:
			var new_value = row[i] * 2
			merged.append(new_value)
			merge_values.append(new_value)
			score += new_value
			i += 2
		else:
			merged.append(row[i])
			i += 1
	
	return [merged, merge_values]

func animate_tiles(new_grid):
	is_animating = true
	
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			if tiles[i][j] != null:
				tiles[i][j].queue_free()
				tiles[i][j] = null
	
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			if new_grid[i][j] != 0:
				tiles[i][j] = create_tile(i, j, new_grid[i][j])
	
	await get_tree().create_timer(ANIMATION_SPEED).timeout
	is_animating = false

func check_game_over():
	# Check for empty cells
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			if grid[i][j] == 0:
				return
	
	# Check for possible merges
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			if j < GRID_SIZE - 1 and grid[i][j] == grid[i][j + 1]:
				return
			if i < GRID_SIZE - 1 and grid[i][j] == grid[i + 1][j]:
				return
	
	game_over = true
	game_over_label.show()

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_LEFT or event.keycode == KEY_A:
			move_tiles("left")
		elif event.keycode == KEY_RIGHT or event.keycode == KEY_D:
			move_tiles("right")
		elif event.keycode == KEY_UP or event.keycode == KEY_W:
			move_tiles("up")
		elif event.keycode == KEY_DOWN or event.keycode == KEY_S:
			move_tiles("down")

func _on_restart_button_pressed():
	score = 0
	game_over = false
	game_over_label.hide()
	
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			if tiles[i][j] != null:
				tiles[i][j].queue_free()
	
	setup_grid()
	spawn_tile()
	spawn_tile()
	update_display()
