extends Area3D

var gold_amount = 5
var rotation_speed = 3.0

func _ready():
	body_entered.connect(_on_body_entered)
	
	# Create coin visual
	var mesh_instance = MeshInstance3D.new()
	var cylinder_mesh = CylinderMesh.new()
	cylinder_mesh.top_radius = 0.3
	cylinder_mesh.bottom_radius = 0.3
	cylinder_mesh.height = 0.1
	mesh_instance.mesh = cylinder_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.GOLD
	material.emission_enabled = true
	material.emission = Color.GOLD
	material.emission_energy = 0.5
	material.metallic = 1.0
	mesh_instance.set_surface_override_material(0, material)
	
	add_child(mesh_instance)
	
	# Create collision
	var collision = CollisionShape3D.new()
	var shape = CylinderShape3D.new()
	shape.radius = 0.3
	shape.height = 0.1
	collision.shape = shape
	add_child(collision)

func _process(delta):
	# Rotate and bob
	rotate_y(rotation_speed * delta)
	position.y += sin(Time.get_ticks_msec() / 300.0) * 0.002

func set_gold_amount(amount: int):
	gold_amount = amount

func _on_body_entered(body):
	if body.is_in_group("Player") and body.has_method("add_gold"):
		body.add_gold(gold_amount)
		queue_free()
