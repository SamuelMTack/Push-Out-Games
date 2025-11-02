# DungeonGenerator.gd
# Attach this to a Node3D
extends Node3D

const CELL_SIZE = 3.0
const DUNGEON_WIDTH = 15
const DUNGEON_HEIGHT = 15

var dungeon_grid = []

func _ready():
	pass

func generate_dungeon():
	# Initialize grid
	for y in range(DUNGEON_HEIGHT):
		var row = []
		for x in range(DUNGEON_WIDTH):
			row.append(1)  # 1 = wall, 0 = floor
		dungeon_grid.append(row)
	
	# Create rooms using simple BSP-like algorithm
	carve_room(1, 1, 5, 5)
	carve_room(7, 2, 6, 4)
	carve_room(2, 8, 5, 5)
	carve_room(9, 9, 4, 4)
	
	# Connect rooms with corridors
	carve_corridor(3, 6, 3, 8)  # Vertical
	carve_corridor(6, 3, 7, 3)  # Horizontal
	carve_corridor(7, 6, 9, 6)  # Horizontal
	carve_corridor(9, 6, 9, 9)  # Vertical
	
	# Build the dungeon
	build_dungeon()

func carve_room(x, y, w, h):
	for dy in range(h):
		for dx in range(w):
			var cx = x + dx
			var cy = y + dy
			if cx < DUNGEON_WIDTH and cy < DUNGEON_HEIGHT:
				dungeon_grid[cy][cx] = 0

func carve_corridor(x1, y1, x2, y2):
	if x1 == x2:  # Vertical corridor
		var start = min(y1, y2)
		var end = max(y1, y2)
		for y in range(start, end + 1):
			if y < DUNGEON_HEIGHT:
				dungeon_grid[y][x1] = 0
	else:  # Horizontal corridor
		var start = min(x1, x2)
		var end = max(x1, x2)
		for x in range(start, end + 1):
			if x < DUNGEON_WIDTH:
				dungeon_grid[y1][x] = 0

func build_dungeon():
	for y in range(DUNGEON_HEIGHT):
		for x in range(DUNGEON_WIDTH):
			var pos = Vector3(x * CELL_SIZE, 0, y * CELL_SIZE)
			
			if dungeon_grid[y][x] == 1:
				# Create wall
				create_wall(pos)
			else:
				# Create floor
				create_floor(pos)
			
			# Add ceiling
			create_ceiling(pos)

func create_wall(pos):
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(CELL_SIZE, CELL_SIZE, CELL_SIZE)
	mesh_instance.mesh = box_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.3, 0.3, 0.35)
	mesh_instance.material_override = material
	
	mesh_instance.position = pos + Vector3(0, CELL_SIZE / 2, 0)
	add_child(mesh_instance)
	
	# Add collision
	var static_body = StaticBody3D.new()
	var collision_shape = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(CELL_SIZE, CELL_SIZE, CELL_SIZE)
	collision_shape.shape = shape
	static_body.add_child(collision_shape)
	mesh_instance.add_child(static_body)

func create_floor(pos):
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(CELL_SIZE, 0.2, CELL_SIZE)
	mesh_instance.mesh = box_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.4, 0.35, 0.3)
	mesh_instance.material_override = material
	
	mesh_instance.position = pos + Vector3(0, -0.1, 0)
	add_child(mesh_instance)
	
	# Add collision
	var static_body = StaticBody3D.new()
	var collision_shape = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(CELL_SIZE, 0.2, CELL_SIZE)
	collision_shape.shape = shape
	static_body.add_child(collision_shape)
	mesh_instance.add_child(static_body)

func create_ceiling(pos):
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(CELL_SIZE, 0.2, CELL_SIZE)
	mesh_instance.mesh = box_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.2, 0.25)
	mesh_instance.material_override = material
	
	mesh_instance.position = pos + Vector3(0, CELL_SIZE + 0.1, 0)
	add_child(mesh_instance)
