# Main.gd
# Attach this to the root Node3D of your main scene
extends Node3D

@onready var dungeon_generator = $DungeonGenerator
@onready var player = $Player
@onready var start_menu = $StartMenu

var game_started = false

func _ready():
	# Configure window settings for proper scaling
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	get_window().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	
	# Connect to window size changes
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	get_tree().root.size_changed.connect(_on_viewport_size_changed)
	
	# Show start menu first
	show_start_menu()
	
	# Initial aspect ratio setup
	_on_viewport_size_changed()

func show_start_menu():
	# Show menu and hide/disable game elements
	start_menu.visible = true
	player.set_physics_process(false)
	player.set_process_input(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func start_game():
	if not game_started:
		# Generate dungeon on first start
		dungeon_generator.generate_dungeon()
		
		# Spawn player in the first room's center
		if dungeon_generator.rooms.size() > 0:
			var first_room = dungeon_generator.rooms[0]
			var spawn_x = (first_room.x + first_room.w / 2.0) * dungeon_generator.CELL_SIZE
			var spawn_z = (first_room.y + first_room.h / 2.0) * dungeon_generator.CELL_SIZE
			player.position = Vector3(spawn_x, 2, spawn_z)
			
			# Spawn skeletons in other rooms
			dungeon_generator.spawn_enemies(player)
		else:
			# Fallback position
			player.position = Vector3(4.5, 2, 4.5)
		
		game_started = true
	
	# Hide menu and enable game
	start_menu.visible = false
	player.set_physics_process(true)
	player.set_process_input(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func quit_game():
	get_tree().quit()

func _on_viewport_size_changed():
	# Update camera aspect ratio when window resizes
	if player and player.camera:
		player.camera.keep_aspect = Camera3D.KEEP_WIDTH
	
	# Force viewport update
	get_viewport().size = get_window().size
