extends StaticBody3D

@onready var mesh_instance = $MeshInstance3D
@onready var collision_shape = $CollisionShape3D

func _ready():
	# Default setup
	if not mesh_instance.mesh:
		var box_mesh = BoxMesh.new()
		box_mesh.size = Vector3(1, 0.5, 1)
		mesh_instance.mesh = box_mesh
	
	if not collision_shape.shape:
		var box_shape = BoxShape3D.new()
		box_shape.size = Vector3(1, 0.5, 1)
		collision_shape.shape = box_shape

func set_color(color: Color):
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	mesh_instance.set_surface_override_material(0, material)
