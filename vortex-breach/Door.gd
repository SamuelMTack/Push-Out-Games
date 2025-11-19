extends Area3D

signal level_complete

func _ready():
	body_entered.connect(_on_body_entered)
	
	# Create door visual
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(2, 3, 0.2)
	mesh_instance.mesh = box_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.GOLD
	material.emission_enabled = true
	material.emission = Color.GOLD
	material.emission_energy = 1.0
	material.metallic = 0.8
	mesh_instance.set_surface_override_material(0, material)
	
	add_child(mesh_instance)
	
	# Create collision
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(2, 3, 0.2)
	collision.shape = shape
	add_child(collision)
	
	# Add frame
	create_door_frame()

func create_door_frame():
	for i in range(2):
		var post = MeshInstance3D.new()
		var post_mesh = BoxMesh.new()
		post_mesh.size = Vector3(0.3, 3.5, 0.3)
		post.mesh = post_mesh
		
		var material = StandardMaterial3D.new()
		material.albedo_color = Color.DARK_GRAY
		post.set_surface_override_material(0, material)
		
		post.position = Vector3(-1.2 + i * 2.4, 0, 0)
		add_child(post)
	
	# Top
	var top = MeshInstance3D.new()
	var top_mesh = BoxMesh.new()
	top_mesh.size = Vector3(2.6, 0.3, 0.3)
	top.mesh = top_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.DARK_GRAY
	top.set_surface_override_material(0, material)
	
	top.position = Vector3(0, 1.75, 0)
	add_child(top)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		level_complete.emit()

func _process(delta):
	# Pulse effect
	var pulse = 1.0 + sin(Time.get_ticks_msec() / 500.0) * 0.1
	scale = Vector3(pulse, pulse, 1.0)
