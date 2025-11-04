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
	
	# Arrow shaft
	var shaft = CylinderMesh.new()
	shaft.top_radius = 0.05
	shaft.bottom_radius = 0.05
	shaft.height = 0.8
	arrow_mesh.mesh = shaft
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.6, 0.4, 0.2)
	arrow_mesh.material_override = material
	
	arrow_mesh.rotation_degrees = Vector3(0, 0, 90)
	add_child(arrow_mesh)
	
	# Arrow tip
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
	
	tip.position = Vector3(0.55, 0, 0)
	tip.rotation_degrees = Vector3(0, 0, -90)
	add_child(tip)
	
	# Add collision
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(1.0, 0.1, 0.1)
	collision.shape = shape
	add_child(collision)
	
	# Orient arrow in direction
	look_at(global_position + direction)

func _physics_process(delta):
	time_alive += delta
	
	# Move arrow
	position += direction * SPEED * delta
	
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
