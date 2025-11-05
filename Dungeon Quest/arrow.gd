# arrow.gd
# Create this as a new script file: res://arrow.gd
extends Area3D

const SPEED = 30.0
const DAMAGE = 15
const LIFETIME = 5.0

var direction = Vector3.FORWARD
var time_alive = 0.0
var shooter = null  # Reference to whoever shot the arrow

func _ready():
	setup_arrow()
	body_entered.connect(_on_body_entered)

func setup_arrow():
	# Create arrow visual
	var arrow_mesh = MeshInstance3D.new()
	
	# Arrow shaft (pointing along X axis)
	var shaft = CylinderMesh.new()
	shaft.top_radius = 0.05
	shaft.bottom_radius = 0.05
	shaft.height = 0.8
	arrow_mesh.mesh = shaft
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.6, 0.4, 0.2)
	arrow_mesh.material_override = material
	
	# Rotate shaft to point forward (along Z axis)
	arrow_mesh.rotation_degrees = Vector3(90, 0, 0)
	arrow_mesh.position = Vector3(0, 0, -0.4)
	add_child(arrow_mesh)
	
	# Arrow tip pointing forward
	var tip = MeshInstance3D.new()
	var cone = CylinderMesh.new()
	cone.top_radius = 0
	cone.bottom_radius = 0.1
	cone.height = 0.3
	tip.mesh = cone
	
	var tip_material = StandardMaterial3D.new()
	tip_material.albedo_color = Color(0.5, 0.5, 0.5)
	tip_material.metallic = 0.8
	tip.material_override = tip_material
	
	tip.position = Vector3(0, 0, -0.85)
	tip.rotation_degrees = Vector3(90, 0, 0)
	add_child(tip)
	
	# Fletching (back feathers)
	for angle in [0, 120, 240]:
		var feather = MeshInstance3D.new()
		var feather_mesh = BoxMesh.new()
		feather_mesh.size = Vector3(0.02, 0.15, 0.1)
		feather.mesh = feather_mesh
		
		var feather_mat = StandardMaterial3D.new()
		feather_mat.albedo_color = Color(0.9, 0.1, 0.1)
		feather.material_override = feather_mat
		
		feather.position = Vector3(0, 0, 0.05)
		feather.rotation_degrees = Vector3(0, angle, 0)
		add_child(feather)
	
	# Add collision (oriented forward along Z axis)
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(0.1, 0.1, 1.2)
	collision.shape = shape
	collision.position = Vector3(0, 0, -0.4)
	add_child(collision)

func _physics_process(delta):
	time_alive += delta
	
	# Move arrow forward in its local Z direction
	position += -global_transform.basis.z * SPEED * delta
	
	# Remove after lifetime expires
	if time_alive > LIFETIME:
		queue_free()

func _on_body_entered(body):
	# Don't hit the shooter
	if body == shooter:
		return
	
	# Check if hit an enemy
	if body.has_method("take_damage"):
		body.take_damage(DAMAGE)
		queue_free()
	# Check if hit a wall
	elif body is StaticBody3D:
		queue_free()
