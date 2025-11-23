extends Control

@onready var coin_label = %CoinLabel
@onready var grid_container = %GridContainer
@onready var back_button = %BackButton

var upgrade_items = [
	{"id": "might", "name": "Might", "description": "Increases damage by 10%", "base_cost": 100, "cost_mult": 1.5, "max_level": 5},
	{"id": "speed", "name": "Speed", "description": "Increases movement speed", "base_cost": 80, "cost_mult": 1.2, "max_level": 5},
	{"id": "max_health", "name": "Max Health", "description": "Increases max health", "base_cost": 150, "cost_mult": 1.5, "max_level": 5},
	{"id": "cooldown", "name": "Cooldown", "description": "Reduces cooldowns by 5%", "base_cost": 200, "cost_mult": 1.8, "max_level": 5},
	{"id": "amount", "name": "Amount", "description": "Adds +1 projectile (Expensive!)", "base_cost": 1000, "cost_mult": 2.0, "max_level": 2},
	{"id": "magnet", "name": "Magnet", "description": "Increases pickup range", "base_cost": 50, "cost_mult": 1.2, "max_level": 5},
	{"id": "regen", "name": "Recovery", "description": "Health regeneration", "base_cost": 100, "cost_mult": 1.5, "max_level": 5}
]

func _ready():
	back_button.pressed.connect(_on_back_pressed)
	update_coin_display()
	populate_shop()

func update_coin_display():
	if has_node("/root/GameManager"):
		var coins = get_node("/root/GameManager").coins
		coin_label.text = "Coins: " + str(coins)

func populate_shop():
	# Clear existing children if any (except headers if we had them)
	for child in grid_container.get_children():
		child.queue_free()
	
	if not has_node("/root/GameManager"): return
	var gm = get_node("/root/GameManager")
	
	for item in upgrade_items:
		var current_level = gm.get_upgrade_level(item["id"])
		var cost = int(item["base_cost"] * pow(item["cost_mult"], current_level))
		
		var panel = PanelContainer.new()
		panel.custom_minimum_size = Vector2(200, 120)
		
		var vbox = VBoxContainer.new()
		panel.add_child(vbox)
		
		var name_label = Label.new()
		name_label.text = item["name"] + " (Lvl " + str(current_level) + "/" + str(item["max_level"]) + ")"
		vbox.add_child(name_label)
		
		var desc_label = Label.new()
		desc_label.text = item["description"]
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_label.custom_minimum_size.y = 40
		vbox.add_child(desc_label)
		
		var buy_button = Button.new()
		if current_level >= item["max_level"]:
			buy_button.text = "MAXED"
			buy_button.disabled = true
		else:
			buy_button.text = "Buy: " + str(cost)
			if gm.coins < cost:
				buy_button.disabled = true
			
			buy_button.pressed.connect(_on_buy_pressed.bind(item["id"], cost))
		
		vbox.add_child(buy_button)
		grid_container.add_child(panel)

func _on_buy_pressed(id, cost):
	if has_node("/root/GameManager"):
		var gm = get_node("/root/GameManager")
		if gm.purchase_upgrade(id, cost):
			update_coin_display()
			populate_shop() # Refresh UI

func _on_back_pressed():
	get_tree().change_scene_to_file("res://title_screen.tscn")
