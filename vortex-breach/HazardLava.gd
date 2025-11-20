extends Area3D

var damage = 15.0
var damage_interval = 0.5
var bodies_in_lava = {}

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Create visual
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(3, 0.2, 3)
	mesh_instance.mesh = box_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.ORANGE_RED
	material.emission_enabled = true
	material.emission = Color.ORANGE_RED
	material.emission_energy = 2.0
	mesh_instance.set_surface_override_material(0, material)
	
	add_child(mesh_instance)
	
	# Create collision
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(3, 0.2, 3)
	collision.shape = shape
	add_child(collision)

func _process(delta):
	for body in bodies_in_lava:
		bodies_in_lava[body] += delta
		if bodies_in_lava[body] >= damage_interval:
			if body.has_method("take_damage"):
				body.take_damage(damage)
			bodies_in_lava[body] = 0.0

func _on_body_entered(body):
	if body.is_in_group("Player"):
		bodies_in_lava[body] = 0.0

func _on_body_exited(body):
	if body in bodies_in_lava:
		bodies_in_lava.erase(body)
