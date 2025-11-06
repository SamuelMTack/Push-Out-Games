# shop.gd
# Create this as a new script file: res://shop.gd
extends Area3D

var player = null
var shop_ui = null
var is_player_near = false

func _ready():
	setup_shop()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func setup_shop():
	# Create shop keeper visual (simple cube with texture)
	var shopkeeper = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(1.0, 2.0, 1.0)
	shopkeeper.mesh = box
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.6, 0.3, 0.1)
	shopkeeper.material_override = material
	add_child(shopkeeper)
	
	# Create shop sign above
	var sign = MeshInstance3D.new()
	var sign_mesh = BoxMesh.new()
	sign_mesh.size = Vector3(2.0, 0.8, 0.2)
	sign.mesh = sign_mesh
	
	var sign_mat = StandardMaterial3D.new()
	sign_mat.albedo_color = Color(0.8, 0.7, 0.3)
	sign.material_override = sign_mat
	sign.position = Vector3(0, 1.5, 0)
	add_child(sign)
	
	# Add glow effect
	var glow = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.3
	glow.mesh = sphere
	
	var glow_mat = StandardMaterial3D.new()
	glow_mat.albedo_color = Color(1.0, 0.84, 0.0)
	glow_mat.emission_enabled = true
	glow_mat.emission = Color(1.0, 0.84, 0.0)
	glow_mat.emission_energy = 2.0
	glow.material_override = glow_mat
	glow.position = Vector3(0, 2.2, 0)
	add_child(glow)
	
	# Add collision for interaction
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(3.0, 2.0, 3.0)
	collision.shape = shape
	collision.position = Vector3(0, 1, 0)
	add_child(collision)

func _process(delta):
	# Rotate the glow
	var glow = get_node_or_null("MeshInstance3D3")
	if glow:
		glow.rotate_y(delta * 2)
	
	# Check for E key press when player is near
	if is_player_near and Input.is_action_just_pressed("ui_select"):
		toggle_shop()

func _on_body_entered(body):
	if body == player:
		is_player_near = true
		show_prompt()

func _on_body_exited(body):
	if body == player:
		is_player_near = false
		hide_prompt()
		if shop_ui and shop_ui.visible:
			toggle_shop()

func show_prompt():
	if not player:
		return
	
	var ui_layer = player.get_node_or_null("HealthBarUI")
	if ui_layer:
		var prompt = Label.new()
		prompt.name = "ShopPrompt"
		prompt.text = "Press E to Open Shop"
		prompt.position = Vector2(400, 300)
		prompt.add_theme_font_size_override("font_size", 24)
		prompt.add_theme_color_override("font_color", Color(1, 1, 1))
		ui_layer.add_child(prompt)

func hide_prompt():
	if not player:
		return
	
	var ui_layer = player.get_node_or_null("HealthBarUI")
	if ui_layer:
		var prompt = ui_layer.get_node_or_null("ShopPrompt")
		if prompt:
			prompt.queue_free()

func toggle_shop():
	if not shop_ui:
		create_shop_ui()
	
	shop_ui.visible = !shop_ui.visible
	
	# Capture/release mouse
	if shop_ui.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func create_shop_ui():
	if not player:
		return
	
	var ui_layer = player.get_node_or_null("HealthBarUI")
	if not ui_layer:
		return
	
	# Create shop panel
	shop_ui = Panel.new()
	shop_ui.name = "ShopUI"
	shop_ui.size = Vector2(400, 300)
	shop_ui.position = Vector2(300, 150)
	shop_ui.visible = false
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.9)
	style.border_color = Color(0.8, 0.6, 0.2)
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	shop_ui.add_theme_stylebox_override("panel", style)
	
	ui_layer.add_child(shop_ui)
	
	# Title
	var title = Label.new()
	title.text = "SHOP"
	title.position = Vector2(160, 10)
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(1, 0.84, 0))
	shop_ui.add_child(title)
	
	# Item 1: Health Potion
	create_shop_item("Health Potion (+50 HP)", 20, Vector2(20, 60), "health")
	
	# Item 2: Max Health Upgrade
	create_shop_item("Max Health Upgrade (+20)", 50, Vector2(20, 120), "max_health")
	
	# Item 3: Damage Upgrade
	create_shop_item("Damage Upgrade (+10)", 30, Vector2(20, 180), "damage")
	
	# Close button
	var close_btn = Button.new()
	close_btn.text = "Close"
	close_btn.position = Vector2(150, 240)
	close_btn.size = Vector2(100, 40)
	close_btn.pressed.connect(toggle_shop)
	shop_ui.add_child(close_btn)

func create_shop_item(item_name: String, cost: int, pos: Vector2, item_type: String):
	var item_label = Label.new()
	item_label.text = item_name
	item_label.position = pos
	item_label.add_theme_font_size_override("font_size", 18)
	shop_ui.add_child(item_label)
	
	var buy_btn = Button.new()
	buy_btn.text = "Buy (" + str(cost) + " Gold)"
	buy_btn.position = pos + Vector2(220, -5)
	buy_btn.size = Vector2(150, 30)
	buy_btn.pressed.connect(func(): purchase_item(item_type, cost))
	shop_ui.add_child(buy_btn)

func purchase_item(item_type: String, cost: int):
	if not player or player.gold < cost:
		print("Not enough gold!")
		return
	
	# Deduct gold
	player.gold -= cost
	player.update_gold_display()
	
	# Give item effect
	match item_type:
		"health":
			player.health = min(player.health + 50, player.max_health)
			player.update_health_bar()
			print("Purchased Health Potion!")
		"max_health":
			player.max_health += 20
			player.health += 20
			player.update_health_bar()
			print("Purchased Max Health Upgrade!")
		"damage":
			# You can add a damage stat to player if needed
			print("Purchased Damage Upgrade!")
	
	print("Remaining gold: ", player.gold)
