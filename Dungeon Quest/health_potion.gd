# health_potion.gd
# Create this as a new script file: res://health_potion.gd
extends Area3D

const HEAL_AMOUNT = 30
const ROTATION_SPEED = 2.0
const BOB_SPEED = 2.0
const BOB_HEIGHT = 0.3

var player = null
var initial_y = 0.0
var time = 0.0
var obj_path = "res://potion.obj"  # Change this to your .obj file path

func _ready():
	initial_y = position.y
	setup_potion()
	body_entered.connect(_on_body_entered)

func setup_potion():
	# Try to load the .obj file
	var mesh_instance = MeshInstance3D.new()
	
	if FileAccess.file_exists(obj_path):
		# Load the .obj file
		var mesh = load(obj_path)
		if mesh:
			mesh_instance.mesh = mesh
			
			# Apply a potion color (red/pink for health)
			var material = StandardMaterial3D.new()
			material.albedo_color = Color(1.0, 0.2, 0.3)
			material.emission_enabled = true
			material.emission = Color(1.0, 0.2, 0.3)
			material.emission_energy = 0.5
			mesh_instance.material_override = material
		else:
			print("Failed to load .obj file, using fallback")
			create_fallback_mesh(mesh_instance)
	else:
		print("OBJ file not found at: ", obj_path, " - Using fallback mesh")
		create_fallback_mesh(mesh_instance)
	
	# Scale the model appropriately
	mesh_instance.scale = Vector3(0.3, 0.3, 0.3)
	add_child(mesh_instance)
	
	# Add collision shape for pickup
	var collision = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = 0.5
	collision.shape = shape
	add_child(collision)

func create_fallback_mesh(mesh_instance):
	# Create a simple potion shape if .obj not found
	var cylinder = CylinderMesh.new()
	cylinder.top_radius = 0.3
	cylinder.bottom_radius = 0.4
	cylinder.height = 0.8
	mesh_instance.mesh = cylinder
	
	# Red/pink color for health potion
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.2, 0.3)
	material.emission_enabled = true
	material.emission = Color(1.0, 0.2, 0.3)
	material.emission_energy = 0.5
	mesh_instance.material_override = material

func _process(delta):
	time += delta
	
	# Rotate the potion
	rotate_y(ROTATION_SPEED * delta)
	
	# Bob up and down
	position.y = initial_y + sin(time * BOB_SPEED) * BOB_HEIGHT

func _on_body_entered(body):
	if body == player:
		# Heal the player
		if player.has_method("heal"):
			player.heal(HEAL_AMOUNT)
		elif player.has_method("take_damage"):
			# Alternative: directly modify health
			player.health = min(player.health + HEAL_AMOUNT, 100)
			print("Player healed! Health: ", player.health)
		
		# Remove the potion
		queue_free()
