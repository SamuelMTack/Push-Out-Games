# Main.gd
# Attach this to the root Node3D of your main scene
extends Node3D

@onready var dungeon_generator = $DungeonGenerator
@onready var player = $Player

func _ready():
	dungeon_generator.generate_dungeon()
	# Position player at dungeon start (higher Y to avoid collision)
	player.position = Vector3(4.5, 2, 4.5)
