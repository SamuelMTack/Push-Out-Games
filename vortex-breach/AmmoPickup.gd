extends Area3D

var ammo_amount = 20
var rotation_speed = 2.5

func _ready():
	body_entered.connect(_on_body_entered)
	
	# Create ammo box visual
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.4, 0.4, 0.4)
	mesh_instance.mesh = box_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.DARK_OLIVE_GREEN
	mesh_instance.set_surface_override_material(0, material)
	
	add_child(mesh_instance)
	
	# Add detail stripe
	var stripe = MeshInstance3D.new()
	var stripe_mesh = BoxMesh.new()
	stripe_mesh.size = Vector3(0.41, 0.1, 0.41)
	stripe.mesh = stripe_mesh
	
	var stripe_material = StandardMaterial3D.new()
	stripe_material.albedo_color = Color.YELLOW
	stripe.set_surface_override_material(0, stripe_material)
	
	mesh_instance.add_child(stripe)
	
	# Create collision
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(0.4, 0.4, 0.4)
	collision.shape = shape
	add_child(collision)

func _process(delta):
	# Rotate and bob
	rotate_y(rotation_speed * delta)
	position.y += sin(Time.get_ticks_msec() / 400.0) * 0.002

func _on_body_entered(body):
	if body.is_in_group("Player") and body.has_method("add_ammo"):
		body.add_ammo(ammo_amount)
		queue_free()
