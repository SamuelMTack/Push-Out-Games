extends Node2D
class_name Weapon

@export var weapon_name: String = "Weapon"
@export var icon: Texture2D
@export var damage: float = 10.0
@export var cooldown: float = 1.0
@export var level: int = 1

var current_cooldown: float = 0.0
var player: CharacterBody2D

func _ready():
	# Find player parent
	var parent = get_parent()
	if parent is CharacterBody2D:
		player = parent

func _process(delta):
	if current_cooldown > 0:
		current_cooldown -= delta
	else:
		attack()

func attack():
	# Override in child classes
	current_cooldown = cooldown

func upgrade():
	level += 1
	damage *= 1.2
	cooldown *= 0.9
