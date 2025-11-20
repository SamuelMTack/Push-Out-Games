extends Area3D

enum PowerupType { SPEED, JUMP, DAMAGE, SPREAD, BULLET_SPEED, FIRE_RATE }

var powerup_type = PowerupType.SPEED
var duration = 10.0
var rotation_speed = 2.0

@onready var mesh_instance = $MeshInstance3D

func _ready():
	body_entered.connect(_on_body_entered)
	randomize_type()
	
	# Create mesh if doesn't exist
	if not mesh_instance:
		mesh_instance = MeshInstance3D.new()
		add_child(mesh_instance)
	
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.3
	sphere_mesh.height = 0.6
	mesh_instance.mesh = sphere_mesh
	
	apply_type_appearance()
	
	# Create collision
	var collision = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = 0.3
	collision.shape = shape
	add_child(collision)

func randomize_type():
	powerup_type = randi() % PowerupType.size()

func apply_type_appearance():
	var material = StandardMaterial3D.new()
	material.emission_enabled = true
	material.emission_energy = 1.5
	
	match powerup_type:
		PowerupType.SPEED:
			material.albedo_color = Color.CYAN
			material.emission = Color.CYAN
		PowerupType.JUMP:
			material.albedo_color = Color.GREEN
			material.emission = Color.GREEN
		PowerupType.DAMAGE:
			material.albedo_color = Color.RED
			material.emission = Color.RED
		PowerupType.SPREAD:
			material.albedo_color = Color.YELLOW
			material.emission = Color.YELLOW
		PowerupType.BULLET_SPEED:
			material.albedo_color = Color.BLUE
			material.emission = Color.BLUE
		PowerupType.FIRE_RATE:
			material.albedo_color = Color.MAGENTA
			material.emission = Color.MAGENTA
	
	mesh_instance.set_surface_override_material(0, material)

func _process(delta):
	# Rotate and bob
	rotate_y(rotation_speed * delta)
	position.y += sin(Time.get_ticks_msec() / 500.0) * 0.001

func _on_body_entered(body):
	if body.is_in_group("Player") and body.has_method("apply_powerup"):
		var type_name = PowerupType.keys()[powerup_type].to_lower()
		body.apply_powerup(type_name, duration)
		queue_free()
