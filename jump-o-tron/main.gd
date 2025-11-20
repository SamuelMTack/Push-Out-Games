# ===== AUTO JUMPER GAME - CLEAN VERSION =====

# SCENE STRUCTURE:
# Main (Node2D) - Main.gd
# ├── Player (CharacterBody2D) - Player.gd
# │   ├── Sprite2D (PlaceholderTexture2D: 32x32)
# │   └── CollisionShape2D (RectangleShape2D: 32x32)
# ├── Camera2D (Position: 240, 400)
# ├── Platforms (Node2D)
# └── UI (CanvasLayer)
#     └── ScoreLabel (Label)
#
# Platform.tscn (StaticBody2D) - Platform.gd
# ├── Sprite2D (PlaceholderTexture2D: 80x20)
# └── CollisionShape2D (RectangleShape2D: 80x20)

# =============================================================================
# MAIN.GD - Game Manager
# =============================================================================
extends Node2D

const PLATFORM_SCENE := preload("res://Platform.tscn")
const SCREEN_WIDTH := 480
const SCREEN_HEIGHT := 800
const PLATFORM_MIN_SPACING := 100
const PLATFORM_MAX_SPACING := 140
const INITIAL_PLATFORM_SPACING := 120
const PLATFORM_CLEANUP_DISTANCE := 1000
const GAME_OVER_DISTANCE := 900
const MOVING_PLATFORM_CHANCE := 0.3  # 30% chance for moving platforms
const DIFFICULT_SPACING_THRESHOLD := 130  # Platforms spaced this far or more become moving

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera2D
@onready var platforms_container: Node2D = $Platforms
@onready var score_label: Label = $UI/ScoreLabel

var score: int = 0
var highest_y: float = 0.0


func _ready() -> void:
	highest_y = player.position.y
	_generate_initial_platforms()


func _process(_delta: float) -> void:
	_update_camera()
	_update_score()
	_generate_platforms_ahead()
	_cleanup_old_platforms()
	_check_game_over()


func _update_camera() -> void:
	camera.position.x = player.position.x
	
	if player.position.y < camera.position.y:
		camera.position.y = player.position.y


func _update_score() -> void:
	if player.position.y < highest_y:
		highest_y = player.position.y
		score = int((700 - highest_y) / 10)
		score_label.text = "Score: " + str(score)


func _generate_initial_platforms() -> void:
	var start_y := 700.0
	_create_platform(Vector2(SCREEN_WIDTH / 2, start_y), false)
	
	for i in range(15):
		var x := randf_range(100, SCREEN_WIDTH - 100)
		var y := start_y - (i + 1) * INITIAL_PLATFORM_SPACING
		_create_platform(Vector2(x, y), false)


func _generate_platforms_ahead() -> void:
	var highest_platform_y := _get_highest_platform_y()
	var target_y := camera.position.y - SCREEN_HEIGHT
	
	while highest_platform_y > target_y:
		var x := randf_range(100, SCREEN_WIDTH - 100)
		var spacing := randf_range(PLATFORM_MIN_SPACING, PLATFORM_MAX_SPACING)
		var y := highest_platform_y - spacing
		
		# Make platform moving if spacing is large
		var should_move := spacing >= DIFFICULT_SPACING_THRESHOLD and randf() < MOVING_PLATFORM_CHANCE
		_create_platform(Vector2(x, y), should_move)
		highest_platform_y = y


func _get_highest_platform_y() -> float:
	var highest := 9999.0
	
	for platform in platforms_container.get_children():
		if platform.position.y < highest:
			highest = platform.position.y
	
	return highest


func _create_platform(pos: Vector2, is_moving: bool) -> void:
	var platform := PLATFORM_SCENE.instantiate()
	platform.position = pos
	
	if is_moving:
		platform.set_moving(true)
	
	platforms_container.add_child(platform)


func _cleanup_old_platforms() -> void:
	var cleanup_threshold := camera.position.y + PLATFORM_CLEANUP_DISTANCE
	
	for platform in platforms_container.get_children():
		if platform.position.y > cleanup_threshold:
			platform.queue_free()


func _check_game_over() -> void:
	if player.position.y > camera.position.y + GAME_OVER_DISTANCE:
		get_tree().reload_current_scene()
