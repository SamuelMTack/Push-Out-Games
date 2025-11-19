extends Area3D

var damage = 25.0

func _ready():
	print("HazardSpike _ready() called at position: ", global_position)
	body_entered.connect(_on_body_entered)
	
	# Create visual - CONE SHAPE (spike)
	var mesh_instance = MeshInstance3D.new()
	var cone_mesh = CylinderMesh.new()
	cone_mesh.top_radius = 0.0  # Point at top
	cone_mesh.bottom_radius = 0.5  # Base
	cone_mesh.height = 1.5
	mesh_instance.mesh = cone_mesh
	
	# Make it dark gray and visible
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.DARK_GRAY
	material.metallic = 0.3
	material.roughness = 0.8
	mesh_instance.set_surface_override_material(0, material)
	
	add_child(mesh_instance)
	# Position mesh so BASE sits on the ground, spike points up
	mesh_instance.position.y = 0.75
	
	print("Spike mesh created and positioned")
	
	# Create collision
	var collision = CollisionShape3D.new()
	var shape = CylinderShape3D.new()
	shape.radius = 0.5
	shape.height = 1.5
	collision.shape = shape
	# Position collision to match mesh
	collision.position.y = 0.75
	add_child(collision)
	
	print("Spike collision created")
	
	# Verify setup
	await get_tree().process_frame
	print("Spike fully initialized at: ", global_position)
	print("Spike has ", get_child_count(), " children")

func _on_body_entered(body):
	print("Spike collision detected with: ", body.name)
	if body.is_in_group("Player") and body.has_method("take_damage"):
		print("Damaging player for ", damage, " damage!")
		body.take_damage(damage)
	else:
		print("Body is not player or doesn't have take_damage method")
