extends Node3D

const LEVEL_SIZE = 80  # Increased level size
const MAZE_SIZE = 20  # Larger maze grid (20x20)
const CELL_SIZE = 4.0  # Wider cells for more room
const WALL_HEIGHT = 5.0
const WALL_THICKNESS = 0.4
const HAZARD_COUNT = 15
const ENEMY_COUNT = 12
const POWERUP_COUNT = 5

# Preload scenes
var platform_scene = preload("res://Platform.tscn")
var hazard_spike_scene = preload("res://HazardSpike.tscn")
var hazard_lava_scene = preload("res://HazardLava.tscn")
var enemy_scene = preload("res://Enemy.tscn")
var powerup_scene = preload("res://Powerup.tscn")
var door_scene = preload("res://Door.tscn")

var current_level = 1
var maze_grid = []
var maze_cells = []
var door_position = Vector3.ZERO
var start_position = Vector3.ZERO

func _ready():
	generate_level()

func generate_level():
	# Clear existing level
	clear_level()
	
	# Generate floor
	generate_floor()
	
	# Generate maze walls
	generate_maze()
	
	# Generate outer walls
	generate_outer_walls()
	
	# Generate some elevated platforms in larger cells
	generate_platforms_in_maze()
	
	# Generate hazards in maze
	generate_hazards()
	
	# Spawn enemies in maze
	spawn_enemies()
	
	# Spawn powerups in maze
	spawn_powerups()
	
	# Create exit door
	create_exit_door()
	
	current_level += 1

func clear_level():
	# Remove all dynamic objects
	for child in get_children():
		if child.is_in_group("LevelObject"):
			child.queue_free()

func generate_floor():
	# Create main floor
	var floor_mesh = BoxMesh.new()
	floor_mesh.size = Vector3(LEVEL_SIZE, 1, LEVEL_SIZE)
	
	var floor_instance = MeshInstance3D.new()
	floor_instance.mesh = floor_mesh
	
	var floor_material = StandardMaterial3D.new()
	floor_material.albedo_color = Color(0.15, 0.15, 0.18)
	floor_instance.set_surface_override_material(0, floor_material)
	
	var floor_body = StaticBody3D.new()
	var floor_collision = CollisionShape3D.new()
	var floor_shape = BoxShape3D.new()
	floor_shape.size = Vector3(LEVEL_SIZE, 1, LEVEL_SIZE)
	floor_collision.shape = floor_shape
	
	floor_body.add_child(floor_instance)
	floor_body.add_child(floor_collision)
	floor_body.position = Vector3(0, -0.5, 0)
	floor_body.add_to_group("LevelObject")
	
	add_child(floor_body)

func generate_maze():
	# Initialize maze grid
	maze_grid = []
	maze_cells = []
	
	for x in range(MAZE_SIZE):
		maze_grid.append([])
		for z in range(MAZE_SIZE):
			maze_grid[x].append({
				"visited": false,
				"walls": {
					"north": true,
					"south": true,
					"east": true,
					"west": true
				}
			})
	
	# Generate maze using recursive backtracking
	var stack = []
	var current = Vector2i(0, 0)
	maze_grid[0][0].visited = true
	
	# Track the farthest cell from start for door placement
	var farthest_cell = Vector2i(0, 0)
	var max_distance = 0
	
	while true:
		var neighbors = get_unvisited_neighbors(current)
		
		if neighbors.size() > 0:
			var next = neighbors[randi() % neighbors.size()]
			stack.push_back(current)
			remove_wall(current, next)
			current = next
			maze_grid[current.x][current.y].visited = true
			
			# Track farthest cell
			var distance = abs(current.x) + abs(current.y)
			if distance > max_distance:
				max_distance = distance
				farthest_cell = current
		elif stack.size() > 0:
			current = stack.pop_back()
		else:
			break
	
	# Sometimes carve out additional paths for more open feel
	carve_additional_paths()
	
	# Create wall meshes based on the maze grid
	create_maze_walls()
	
	# Store start and end positions
	var maze_offset = Vector3(
		-(MAZE_SIZE * CELL_SIZE) / 2.0,
		0,
		-(MAZE_SIZE * CELL_SIZE) / 2.0
	)
	
	start_position = Vector3(CELL_SIZE/2, 2, CELL_SIZE/2) + maze_offset
	door_position = Vector3(
		farthest_cell.x * CELL_SIZE + CELL_SIZE/2,
		1.5,
		farthest_cell.y * CELL_SIZE + CELL_SIZE/2
	) + maze_offset

func carve_additional_paths():
	# Randomly remove some walls to create loops and more open areas
	for x in range(1, MAZE_SIZE - 1):
		for z in range(1, MAZE_SIZE - 1):
			if randf() < 0.15:  # 15% chance to create opening
				var direction = randi() % 4
				match direction:
					0:  # North
						if z > 0:
							maze_grid[x][z].walls.north = false
							maze_grid[x][z-1].walls.south = false
					1:  # South
						if z < MAZE_SIZE - 1:
							maze_grid[x][z].walls.south = false
							maze_grid[x][z+1].walls.north = false
					2:  # East
						if x < MAZE_SIZE - 1:
							maze_grid[x][z].walls.east = false
							maze_grid[x+1][z].walls.west = false
					3:  # West
						if x > 0:
							maze_grid[x][z].walls.west = false
							maze_grid[x-1][z].walls.east = false

func get_unvisited_neighbors(pos: Vector2i) -> Array:
	var neighbors = []
	
	# Check north
	if pos.y > 0 and not maze_grid[pos.x][pos.y - 1].visited:
		neighbors.append(Vector2i(pos.x, pos.y - 1))
	
	# Check south
	if pos.y < MAZE_SIZE - 1 and not maze_grid[pos.x][pos.y + 1].visited:
		neighbors.append(Vector2i(pos.x, pos.y + 1))
	
	# Check east
	if pos.x < MAZE_SIZE - 1 and not maze_grid[pos.x + 1][pos.y].visited:
		neighbors.append(Vector2i(pos.x + 1, pos.y))
	
	# Check west
	if pos.x > 0 and not maze_grid[pos.x - 1][pos.y].visited:
		neighbors.append(Vector2i(pos.x - 1, pos.y))
	
	return neighbors

func remove_wall(current: Vector2i, next: Vector2i):
	var dx = next.x - current.x
	var dy = next.y - current.y
	
	if dx == 1:  # Moving east
		maze_grid[current.x][current.y].walls.east = false
		maze_grid[next.x][next.y].walls.west = false
	elif dx == -1:  # Moving west
		maze_grid[current.x][current.y].walls.west = false
		maze_grid[next.x][next.y].walls.east = false
	elif dy == 1:  # Moving south
		maze_grid[current.x][current.y].walls.south = false
		maze_grid[next.x][next.y].walls.north = false
	elif dy == -1:  # Moving north
		maze_grid[current.x][current.y].walls.north = false
		maze_grid[next.x][next.y].walls.south = false

func create_maze_walls():
	var maze_offset = Vector3(
		-(MAZE_SIZE * CELL_SIZE) / 2.0,
		0,
		-(MAZE_SIZE * CELL_SIZE) / 2.0
	)
	
	for x in range(MAZE_SIZE):
		for z in range(MAZE_SIZE):
			var cell = maze_grid[x][z]
			var cell_pos = Vector3(x * CELL_SIZE, 0, z * CELL_SIZE) + maze_offset
			
			# Store cell positions for spawning
			maze_cells.append(cell_pos + Vector3(CELL_SIZE/2, 0, CELL_SIZE/2))
			
			# Create north wall
			if cell.walls.north:
				create_wall(
					cell_pos + Vector3(CELL_SIZE/2, WALL_HEIGHT/2, 0),
					Vector3(CELL_SIZE, WALL_HEIGHT, WALL_THICKNESS)
				)
			
			# Create south wall
			if cell.walls.south:
				create_wall(
					cell_pos + Vector3(CELL_SIZE/2, WALL_HEIGHT/2, CELL_SIZE),
					Vector3(CELL_SIZE, WALL_HEIGHT, WALL_THICKNESS)
				)
			
			# Create east wall
			if cell.walls.east:
				create_wall(
					cell_pos + Vector3(CELL_SIZE, WALL_HEIGHT/2, CELL_SIZE/2),
					Vector3(WALL_THICKNESS, WALL_HEIGHT, CELL_SIZE)
				)
			
			# Create west wall
			if cell.walls.west:
				create_wall(
					cell_pos + Vector3(0, WALL_HEIGHT/2, CELL_SIZE/2),
					Vector3(WALL_THICKNESS, WALL_HEIGHT, CELL_SIZE)
				)

func create_wall(position: Vector3, size: Vector3):
	var wall_body = StaticBody3D.new()
	
	# Create mesh
	var wall_mesh = BoxMesh.new()
	wall_mesh.size = size
	
	var wall_instance = MeshInstance3D.new()
	wall_instance.mesh = wall_mesh
	
	# Create material with different colors for variety
	var wall_material = StandardMaterial3D.new()
	var color_variation = randf_range(0.25, 0.4)
	wall_material.albedo_color = Color(color_variation, color_variation * 0.95, color_variation * 0.9)
	wall_instance.set_surface_override_material(0, wall_material)
	
	# Create collision
	var wall_collision = CollisionShape3D.new()
	var wall_shape = BoxShape3D.new()
	wall_shape.size = size
	wall_collision.shape = wall_shape
	
	wall_body.add_child(wall_instance)
	wall_body.add_child(wall_collision)
	wall_body.position = position
	wall_body.add_to_group("LevelObject")
	
	add_child(wall_body)

func generate_outer_walls():
	# Create surrounding walls
	var wall_material = StandardMaterial3D.new()
	wall_material.albedo_color = Color(0.1, 0.1, 0.15)
	
	# North wall
	create_outer_wall(
		Vector3(0, WALL_HEIGHT/2, -LEVEL_SIZE/2),
		Vector3(LEVEL_SIZE, WALL_HEIGHT * 2, 1),
		wall_material
	)
	
	# South wall
	create_outer_wall(
		Vector3(0, WALL_HEIGHT/2, LEVEL_SIZE/2),
		Vector3(LEVEL_SIZE, WALL_HEIGHT * 2, 1),
		wall_material
	)
	
	# East wall
	create_outer_wall(
		Vector3(LEVEL_SIZE/2, WALL_HEIGHT/2, 0),
		Vector3(1, WALL_HEIGHT * 2, LEVEL_SIZE),
		wall_material
	)
	
	# West wall
	create_outer_wall(
		Vector3(-LEVEL_SIZE/2, WALL_HEIGHT/2, 0),
		Vector3(1, WALL_HEIGHT * 2, LEVEL_SIZE),
		wall_material
	)

func create_outer_wall(position: Vector3, size: Vector3, material: StandardMaterial3D):
	var wall_body = StaticBody3D.new()
	
	var wall_mesh = BoxMesh.new()
	wall_mesh.size = size
	
	var wall_instance = MeshInstance3D.new()
	wall_instance.mesh = wall_mesh
	wall_instance.set_surface_override_material(0, material)
	
	var wall_collision = CollisionShape3D.new()
	var wall_shape = BoxShape3D.new()
	wall_shape.size = size
	wall_collision.shape = wall_shape
	
	wall_body.add_child(wall_instance)
	wall_body.add_child(wall_collision)
	wall_body.position = position
	wall_body.add_to_group("LevelObject")
	
	add_child(wall_body)

func generate_platforms_in_maze():
	# Add some platforms in random cells for verticality
	for i in range(10):
		if maze_cells.size() > 10:
			var cell_index = randi_range(5, maze_cells.size() - 5)
			var cell_pos = maze_cells[cell_index]
			
			var platform = platform_scene.instantiate()
			add_child(platform)
			platform.add_to_group("LevelObject")
			
			platform.position = cell_pos + Vector3(0, randf_range(2, 3), 0)
			platform.scale = Vector3(CELL_SIZE * 0.7, 0.3, CELL_SIZE * 0.7)
			
			var colors = [Color.DARK_GRAY, Color.DIM_GRAY, Color.SLATE_GRAY]
			platform.set_color(colors[randi() % colors.size()])

func generate_hazards():
	for i in range(HAZARD_COUNT):
		var hazard
		
		# Random hazard type
		if randf() < 0.5:
			hazard = hazard_spike_scene.instantiate()
		else:
			hazard = hazard_lava_scene.instantiate()
		
		add_child(hazard)
		hazard.add_to_group("LevelObject")
		
		# Place in random maze cell (avoid start and end)
		if maze_cells.size() > 10:
			var cell_index = randi_range(5, maze_cells.size() - 5)
			var cell_pos = maze_cells[cell_index]
			hazard.position = cell_pos + Vector3(
				randf_range(-CELL_SIZE/3, CELL_SIZE/3),
				0.5,
				randf_range(-CELL_SIZE/3, CELL_SIZE/3)
			)

func spawn_enemies():
	var enemy_count = ENEMY_COUNT + (current_level - 1) * 2  # Scale with level
	
	for i in range(enemy_count):
		var enemy = enemy_scene.instantiate()
		add_child(enemy)
		enemy.add_to_group("LevelObject")
		
		# Spawn in random maze cell (avoid start)
		if maze_cells.size() > 5:
			var cell_index = randi_range(3, maze_cells.size() - 1)
			var cell_pos = maze_cells[cell_index]
			enemy.position = cell_pos + Vector3(0, 2, 0)

func spawn_powerups():
	for i in range(POWERUP_COUNT):
		var powerup = powerup_scene.instantiate()
		add_child(powerup)
		powerup.add_to_group("LevelObject")
		
		# Place in random maze cell
		if maze_cells.size() > 0:
			var cell_pos = maze_cells[randi() % maze_cells.size()]
			powerup.position = cell_pos + Vector3(0, 1, 0)

func create_exit_door():
	var door = door_scene.instantiate()
	add_child(door)
	door.add_to_group("LevelObject")
	door.add_to_group("ExitDoor")  # Add to group for UI tracking
	
	# Use the calculated door position
	door.position = door_position
	
	door.level_complete.connect(_on_level_complete)
	
	# Update UI with door position
	var ui = get_node_or_null("/root/World/UI")
	if ui and ui.has_method("set_door_position"):
		ui.set_door_position(door_position)

func _on_level_complete():
	generate_level()
	
	# Move player to spawn (start of maze)
	var player = get_node_or_null("/root/World/Player")
	if player:
		player.position = start_position
		player.velocity = Vector3.ZERO
