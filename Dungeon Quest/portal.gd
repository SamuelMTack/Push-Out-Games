
# portal.gd
# Create this as a new script file: res://portal.gd
extends Area3D

const ROTATION_SPEED = 2.0
const PULSE_SPEED = 3.0
const PULSE_AMOUNT = 0.3

var player = null
var dungeon_generator = null
var time = 0.0
var initial_scale = Vector3(1, 1, 1)

func _ready():
	setup_portal()
	body_entered.connect(_on_body_entered)

func setup_portal():
	# Create outer ring
	var outer_ring = MeshInstance3D.new()
	var outer_torus = TorusMesh.new()
	outer_torus.inner_radius = 0.8
	outer_torus.outer_radius = 1.2
	outer_ring.mesh = outer_torus
	
	var outer_mat = StandardMaterial3D.new()
	outer_mat.albedo_color = Color(0.2, 0.6, 1.0)
	outer_mat.emission_enabled = true
	outer_mat.emission = Color(0.3, 0.8, 1.0)
	outer_mat.emission_energy = 2.0
	outer_ring.material_override = outer_mat
	outer_ring.rotation_degrees = Vector3(90, 0, 0)
	add_child(outer_ring)
	
	# Create inner swirl
	var inner_disc = MeshInstance3D.new()
	var disc = CylinderMesh.new()
	disc.top_radius = 0.8
	disc.bottom_radius = 0.8
	disc.height = 0.1
	inner_disc.mesh = disc
	
	var inner_mat = StandardMaterial3D.new()
	inner_mat.albedo_color = Color(0.5, 0.3, 1.0, 0.7)
	inner_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	inner_mat.emission_enabled = true
	inner_mat.emission = Color(0.8, 0.5, 1.0)
	inner_mat.emission_energy = 1.5
	inner_disc.material_override = inner_mat
	inner_disc.rotation_degrees = Vector3(90, 0, 0)
	add_child(inner_disc)
	
	# Add collision for interaction
	var collision = CollisionShape3D.new()
	var shape = CylinderShape3D.new()
	shape.radius = 1.0
	shape.height = 2.0
	collision.shape = shape
	collision.rotation_degrees = Vector3(90, 0, 0)
	add_child(collision)
	
	initial_scale = scale

func _process(delta):
	time += delta
	
	# Rotate portal
	rotate_y(ROTATION_SPEED * delta)
	
	# Pulse effect
	var pulse = 1.0 + sin(time * PULSE_SPEED) * PULSE_AMOUNT
	scale = initial_scale * pulse

func _on_body_entered(body):
	if body == player and dungeon_generator:
		print("Entering portal - generating new dungeon!")
		# Reset player health
		if player.has_method("heal"):
			player.health = player.max_health
			player.update_health_bar()
		
		# Generate new dungeon
		dungeon_generator.reset_dungeon(player)
