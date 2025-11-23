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

func get_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return null
		
	var nearest = enemies[0]
	var min_dist = global_position.distance_to(nearest.global_position)
	
	for e in enemies:
		var d = global_position.distance_to(e.global_position)
		if d < min_dist:
			min_dist = d
			nearest = e
			
	return nearest

func apply_upgrade(upgrade_name: String):
	match upgrade_name:
		"projectile_damage":
			damage += 5.0
			print(weapon_name, " damage increased to ", damage)
		"attack_speed":
			cooldown = max(0.1, cooldown * 0.9)
			print(weapon_name, " cooldown reduced to ", cooldown)
			scale *= 1.1
			print(weapon_name, " size increased")

func update_stats(player_ref):
	# Apply player stats to this weapon
	# Store base stats in metadata to avoid compounding multiplication
	if not has_meta("base_damage"):
		set_meta("base_damage", damage)
		set_meta("base_cooldown", cooldown)
		set_meta("base_scale", scale)
	
	damage = get_meta("base_damage") * player_ref.might
	cooldown = get_meta("base_cooldown") * player_ref.cooldown_mult
	scale = get_meta("base_scale") * player_ref.area
	
	# Speed?
	if "speed" in self:
		if not has_meta("base_speed"):
			set_meta("base_speed", self.speed)
		self.speed = get_meta("base_speed") * player_ref.speed_mult
