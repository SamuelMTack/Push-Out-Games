extends Weapon

@export var orbit_radius: float = 100.0
@export var orbit_speed: float = 2.0
@export var projectile_count: int = 1

var projectiles = []
var projectile_scene_ref = preload("res://weapons/OrbitProjectile.tscn")

func _ready():
	super._ready()
	update_projectiles()

func attack():
	# Passive weapon, always active
	pass

func _process(delta):
	super._process(delta)
	
	# Rotate container or update positions
	# Simple implementation: Rotate this node? No, this node is attached to player.
	# We need a container that rotates, or update projectile positions manually.
	
	var time = Time.get_ticks_msec() / 1000.0 * orbit_speed
	
	for i in range(projectiles.size()):
		var proj = projectiles[i]
		if is_instance_valid(proj):
			var angle = time + (i * TAU / projectiles.size())
			proj.position = Vector2(cos(angle), sin(angle)) * orbit_radius

func update_projectiles():
	# Clear existing
	for p in projectiles:
		if is_instance_valid(p):
			p.queue_free()
	projectiles.clear()
	
	# Create new
	for i in range(projectile_count):
		var proj = projectile_scene_ref.instantiate()
		add_child(proj)
		proj.setup(damage)
		projectiles.append(proj)

func upgrade():
	super.upgrade()
	projectile_count += 1
	orbit_speed += 0.5
	update_projectiles()
