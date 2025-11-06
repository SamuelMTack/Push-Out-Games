# DungeonGenerator.gd
# Attach this to a Node3D
extends Node3D

const CELL_SIZE = 3.0
const DUNGEON_WIDTH = 25  # Increased from 15
const DUNGEON_HEIGHT = 25  # Increased from 15
const MIN_ROOM_SIZE = 3
const MAX_ROOM_SIZE = 8  # Increased from 7
const NUM_ROOMS = 15  # Increased from 8

var dungeon_grid = []
var rooms = []

func _ready():
	pass

func generate_dungeon():
	# Initialize grid with walls
	dungeon_grid.clear()
	rooms.clear()
	
	for y in range(DUNGEON_HEIGHT):
		var row = []
		for x in range(DUNGEON_WIDTH):
			row.append(1)  # 1 = wall, 0 = floor
		dungeon_grid.append(row)
	
	# Generate random rooms
	randomize()
	for i in range(NUM_ROOMS):
		var room_created = false
		var attempts = 0
		
		while not room_created and attempts < 50:
			var room_width = randi() % (MAX_ROOM_SIZE - MIN_ROOM_SIZE + 1) + MIN_ROOM_SIZE
			var room_height = randi() % (MAX_ROOM_SIZE - MIN_ROOM_SIZE + 1) + MIN_ROOM_SIZE
			var room_x = randi() % (DUNGEON_WIDTH - room_width - 2) + 1
			var room_y = randi() % (DUNGEON_HEIGHT - room_height - 2) + 1
			
			if can_place_room(room_x, room_y, room_width, room_height):
				carve_room(room_x, room_y, room_width, room_height)
				rooms.append({"x": room_x, "y": room_y, "w": room_width, "h": room_height})
				room_created = true
			
			attempts += 1
	
	# Connect rooms with corridors
	for i in range(rooms.size() - 1):
		connect_rooms(rooms[i], rooms[i + 1])
	
	# Build the dungeon with textures
	build_dungeon()

func can_place_room(x, y, w, h):
	# Check if room overlaps with existing rooms (with padding)
	for dy in range(-1, h + 1):
		for dx in range(-1, w + 1):
			var cx = x + dx
			var cy = y + dy
			if cx < 0 or cx >= DUNGEON_WIDTH or cy < 0 or cy >= DUNGEON_HEIGHT:
				return false
			if dungeon_grid[cy][cx] == 0:
				return false
	return true

func carve_room(x, y, w, h):
	for dy in range(h):
		for dx in range(w):
			var cx = x + dx
			var cy = y + dy
			if cx < DUNGEON_WIDTH and cy < DUNGEON_HEIGHT:
				dungeon_grid[cy][cx] = 0

func connect_rooms(room1, room2):
	var center1_x = room1.x + room1.w / 2
	var center1_y = room1.y + room1.h / 2
	var center2_x = room2.x + room2.w / 2
	var center2_y = room2.y + room2.h / 2
	
	# Randomly choose horizontal-first or vertical-first
	if randf() > 0.5:
		carve_h_corridor(center1_x, center2_x, center1_y)
		carve_v_corridor(center1_y, center2_y, center2_x)
	else:
		carve_v_corridor(center1_y, center2_y, center1_x)
		carve_h_corridor(center1_x, center2_x, center2_y)

func carve_h_corridor(x1, x2, y):
	var start = min(x1, x2)
	var end = max(x1, x2)
	for x in range(start, end + 1):
		if x >= 0 and x < DUNGEON_WIDTH and y >= 0 and y < DUNGEON_HEIGHT:
			dungeon_grid[y][x] = 0

func carve_v_corridor(y1, y2, x):
	var start = min(y1, y2)
	var end = max(y1, y2)
	for y in range(start, end + 1):
		if x >= 0 and x < DUNGEON_WIDTH and y >= 0 and y < DUNGEON_HEIGHT:
			dungeon_grid[y][x] = 0

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
	
	# Create procedural stone brick texture
	var img = Image.create(128, 128, false, Image.FORMAT_RGB8)
	
	# Base stone color
	var base_color = Color(0.4, 0.38, 0.35)
	var mortar_color = Color(0.25, 0.24, 0.22)
	var brick_width = 32
	var brick_height = 16
	var mortar_size = 2
	
	for py in range(128):
		for px in range(128):
			var brick_row = int(py / brick_height)
			var offset = (brick_row % 2) * (brick_width / 2)
			var local_x = (px + offset) % brick_width
			var local_y = py % brick_height
			
			# Determine if this pixel is mortar or brick
			if local_x < mortar_size or local_y < mortar_size:
				img.set_pixel(px, py, mortar_color)
			else:
				# Add some noise to brick color
				var noise = randf() * 0.1 - 0.05
				var brick_color = Color(
					base_color.r + noise,
					base_color.g + noise,
					base_color.b + noise
				)
				img.set_pixel(px, py, brick_color)
	
	var texture = ImageTexture.create_from_image(img)
	material.albedo_texture = texture
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	material.uv1_scale = Vector3(2, 2, 2)
	
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
	
	# Create procedural stone floor texture
	var img = Image.create(64, 64, false, Image.FORMAT_RGB8)
	
	# Base stone colors
	var base_color = Color(0.35, 0.3, 0.28)
	var dark_color = Color(0.25, 0.22, 0.2)
	
	for py in range(64):
		for px in range(64):
			# Create irregular stone pattern
			var noise = (sin(px * 0.5) + cos(py * 0.3)) * 0.5
			var stone_variation = randf() * 0.15
			
			var final_color = base_color.lerp(dark_color, noise * 0.3 + stone_variation)
			img.set_pixel(px, py, final_color)
	
	var texture = ImageTexture.create_from_image(img)
	material.albedo_texture = texture
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	material.uv1_scale = Vector3(3, 3, 3)
	material.roughness = 0.8
	
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

func spawn_enemies(player_ref):
	# Spawn 1-2 skeletons in each room (except the first one where player spawns)
	for i in range(1, rooms.size()):
		var room = rooms[i]
		var num_skeletons = randi() % 2 + 1  # 1-2 skeletons per room
		
		for j in range(num_skeletons):
			var skeleton = preload("res://skeleton.gd").new()
			
			# Random position within the room
			var offset_x = randf() * (room.w - 2) + 1
			var offset_z = randf() * (room.h - 2) + 1
			var spawn_x = (room.x + offset_x) * CELL_SIZE
			var spawn_z = (room.y + offset_z) * CELL_SIZE
			
			skeleton.position = Vector3(spawn_x, 1, spawn_z)
			skeleton.player = player_ref
			add_child(skeleton)
	
	# Spawn health potions in some rooms
	spawn_health_potions(player_ref)
	
	# Spawn shop in the first room
	spawn_shop(player_ref)

func spawn_health_potions(player_ref):
	# Spawn 1 health potion in 3-4 random rooms (not the first room)
	var num_potions = randi() % 2 + 3  # 3-4 potions
	var available_rooms = range(1, rooms.size())
	available_rooms.shuffle()
	
	for i in range(min(num_potions, available_rooms.size())):
		var room_idx = available_rooms[i]
		var room = rooms[room_idx]
		
		var potion = preload("res://health_potion.gd").new()
		
		# Random position within the room
		var offset_x = randf() * (room.w - 2) + 1
		var offset_z = randf() * (room.h - 2) + 1
		var spawn_x = (room.x + offset_x) * CELL_SIZE
		var spawn_z = (room.y + offset_z) * CELL_SIZE
		
		potion.position = Vector3(spawn_x, 0.5, spawn_z)
		potion.player = player_ref
		add_child(potion)
	
	# Spawn portal in the last room
	spawn_portal(player_ref)

func spawn_portal(player_ref):
	if rooms.size() > 0:
		var last_room = rooms[rooms.size() - 1]
		
		var portal = preload("res://portal.gd").new()
		
		# Center of the last room
		var spawn_x = (last_room.x + last_room.w / 2.0) * CELL_SIZE
		var spawn_z = (last_room.y + last_room.h / 2.0) * CELL_SIZE
		
		portal.position = Vector3(spawn_x, 0.5, spawn_z)
		portal.player = player_ref
		portal.dungeon_generator = self
		add_child(portal)

func spawn_shop(player_ref):
	if rooms.size() > 0:
		var first_room = rooms[0]
		
		var shop = preload("res://shop.gd").new()
		
		# Place shop near the edge of the first room
		var spawn_x = (first_room.x + 1) * CELL_SIZE
		var spawn_z = (first_room.y + 1) * CELL_SIZE
		
		shop.position = Vector3(spawn_x, 1, spawn_z)
		shop.player = player_ref
		add_child(shop)

func reset_dungeon(player_ref):
	# Clear all children (old dungeon, enemies, potions, portal)
	for child in get_children():
		child.queue_free()
	
	# Wait for children to be freed
	await get_tree().process_frame
	
	# Reset arrays
	dungeon_grid.clear()
	rooms.clear()
	
	# Generate new dungeon
	generate_dungeon()
	
	# Respawn player in first room
	if rooms.size() > 0:
		var first_room = rooms[0]
		var spawn_x = (first_room.x + first_room.w / 2.0) * CELL_SIZE
		var spawn_z = (first_room.y + first_room.h / 2.0) * CELL_SIZE
		player_ref.position = Vector3(spawn_x, 2, spawn_z)
	
	# Spawn enemies and items
	spawn_enemies(player_ref)
