# gold_coin.gd
# Create this as a new script file: res://gold_coin.gd
extends Area3D

const ROTATION_SPEED = 3.0
const BOB_SPEED = 2.5
const BOB_HEIGHT = 0.2

var player = null
var initial_y = 0.0
var time = 0.0
var gold_amount = 10

func _ready():
	initial_y = position.y
	setup_gold_coin()
	body_entered.connect(_on_body_entered)

func setup_gold_coin():
	# Create coin visual
	var coin = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	cylinder.top_radius = 0.3
	cylinder.bottom_radius = 0.3
	cylinder.height = 0.1
	coin.mesh = cylinder
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.84, 0.0)
	material.metallic = 0.8
	material.roughness = 0.2
	material.emission_enabled = true
	material.emission = Color(1.0, 0.84, 0.0)
	material.emission_energy = 0.3
	coin.material_override = material
	
	add_child(coin)
	
	# Add collision shape for pickup
	var collision = CollisionShape3D.new()
	var shape = CylinderShape3D.new()
	shape.radius = 0.3
	shape.height = 0.1
	collision.shape = shape
	add_child(collision)

func _process(delta):
	time += delta
	
	# Rotate the coin
	rotate_y(ROTATION_SPEED * delta)
	
	# Bob up and down
	position.y = initial_y + sin(time * BOB_SPEED) * BOB_HEIGHT

func _on_body_entered(body):
	if body == player:
		# Give gold to player
		if player.has_method("add_gold"):
			player.add_gold(gold_amount)
		
		# Remove the coin
		queue_free()
