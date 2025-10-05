extends Control

signal shop_closed

var player_currency := 0
var items := [
	{"name": "Extra Life", "cost": 50, "description": "Gain an additional life"},
	{"name": "Shield", "cost": 30, "description": "Temporary protection from traps"},
	{"name": "Speed Boost", "cost": 40, "description": "Increase movement speed"},
	{"name": "Attack Power", "cost": 35, "description": "Stronger distance attacks"}
]

@onready var currency_label: Label
@onready var items_container: VBoxContainer
var main_game: Node2D

func _ready():
	# Create shop UI
	create_shop_ui()
	main_game = get_parent()

func create_shop_ui():
	# Background
	var bg = ColorRect.new()
	bg.size = Vector2(400, 300)
	bg.position = Vector2(300, 150)
	bg.color = Color(0.2, 0.2, 0.2, 0.9)
	add_child(bg)

	# Title
	var title = Label.new()
	title.text = "SHOP"
	title.position = Vector2(320, 170)
	add_child(title)

	# Currency display
	currency_label = Label.new()
	currency_label.text = "Currency: " + str(player_currency)
	currency_label.position = Vector2(320, 200)
	add_child(currency_label)

	# Items container
	items_container = VBoxContainer.new()
	items_container.position = Vector2(320, 230)
	add_child(items_container)

	# Create item buttons
	for i in range(items.size()):
		var item = items[i]
		var button = Button.new()
		button.text = item.name + " - " + str(item.cost) + " coins"
		button.size = Vector2(200, 30)

		# Connect button to purchase function
		var callable = Callable(self, "purchase_item").bind(i)
		button.pressed.connect(callable)

		items_container.add_child(button)

	# Close button
	var close_button = Button.new()
	close_button.text = "Continue"
	close_button.position = Vector2(450, 400)
	close_button.size = Vector2(100, 40)
	close_button.pressed.connect(close_shop)
	add_child(close_button)

func purchase_item(item_index: int):
	var item = items[item_index]

	if player_currency >= item.cost:
		player_currency -= item.cost
		currency_label.text = "Currency: " + str(player_currency)

		# Apply item effect
		apply_item_effect(item.name)
		print("Purchased: ", item.name)
	else:
		print("Not enough currency!")

func apply_item_effect(item_name: String):
	match item_name:
		"Extra Life":
			if main_game and main_game.has_method("add_life"):
				main_game.add_life()
		"Shield":
			if main_game and main_game.has_method("activate_shield"):
				main_game.activate_shield(10.0)  # 10 seconds of protection
		"Speed Boost":
			if main_game and main_game.has_method("boost_speed"):
				main_game.boost_speed(1.5, 15.0)  # 1.5x speed for 15 seconds
		"Attack Power":
			if main_game and main_game.has_method("boost_attack"):
				main_game.boost_attack(2.0, 20.0)  # 2x attack power for 20 seconds

func close_shop():
	shop_closed.emit()
	queue_free()

func add_currency(amount: int):
	player_currency += amount
	if currency_label:
		currency_label.text = "Currency: " + str(player_currency)