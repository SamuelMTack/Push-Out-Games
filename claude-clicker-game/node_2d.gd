extends Control

# Game variables
var points = 0
var points_per_click = 1
var idle_clickers = 0
var idle_click_rate = 1.0 # Points per second per clicker

# Shop prices
var clicker_base_price = 10
var clicker_price = clicker_base_price

# Save file path
const SAVE_PATH = "user://clicker_save.json"

# UI References
@onready var points_label = $VBoxContainer/PointsLabel
@onready var click_button = $VBoxContainer/ClickButton
@onready var shop_panel = $ShopPanel
@onready var clicker_price_label = $ShopPanel/VBoxContainer/BuyClickerButton/PriceLabel
@onready var clickers_owned_label = $ShopPanel/VBoxContainer/ClickersOwnedLabel
@onready var points_per_sec_label = $VBoxContainer/PointsPerSecLabel
@onready var save_button = $VBoxContainer/SaveLoadButtons/SaveButton
@onready var load_button = $VBoxContainer/SaveLoadButtons/LoadButton
@onready var save_status_label = $VBoxContainer/SaveStatusLabel

func _ready():
	# Connect signals
	click_button.pressed.connect(_on_click_button_pressed)
	$ShopPanel/VBoxContainer/BuyClickerButton.pressed.connect(_on_buy_clicker_pressed)
	save_button.pressed.connect(_on_save_button_pressed)
	load_button.pressed.connect(_on_load_button_pressed)
	
	# Start idle clicker timer
	var timer = Timer.new()
	timer.wait_time = 0.1 # Update 10 times per second for smooth increments
	timer.timeout.connect(_on_idle_timer_timeout)
	add_child(timer)
	timer.start()
	
	# Auto-load on start if save exists
	if FileAccess.file_exists(SAVE_PATH):
		load_game()
	
	update_ui()

func _on_click_button_pressed():
	points += points_per_click
	update_ui()
	
	# Add a little animation effect
	click_button.scale = Vector2(0.95, 0.95)
	var tween = create_tween()
	tween.tween_property(click_button, "scale", Vector2(1.0, 1.0), 0.1)

func _on_buy_clicker_pressed():
	if points >= clicker_price:
		points -= clicker_price
		idle_clickers += 1
		# Increase price by 15% for each purchase
		clicker_price = int(clicker_base_price * pow(1.15, idle_clickers))
		update_ui()

func _on_idle_timer_timeout():
	if idle_clickers > 0:
		# Add points from idle clickers (divided by 10 since timer runs 10x per second)
		points += (idle_clickers * idle_click_rate) / 10.0
		update_ui()

func _on_save_button_pressed():
	save_game()

func _on_load_button_pressed():
	load_game()

func save_game():
	var save_data = {
		"points": points,
		"idle_clickers": idle_clickers,
		"clicker_price": clicker_price
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(save_data)
		file.store_line(json_string)
		file.close()
		show_save_status("Game Saved!", Color.GREEN)
	else:
		show_save_status("Save Failed!", Color.RED)

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		show_save_status("No save file found!", Color.ORANGE)
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_line()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var save_data = json.data
			points = save_data.get("points", 0)
			idle_clickers = save_data.get("idle_clickers", 0)
			clicker_price = save_data.get("clicker_price", clicker_base_price)
			update_ui()
			show_save_status("Game Loaded!", Color.GREEN)
		else:
			show_save_status("Load Failed!", Color.RED)
	else:
		show_save_status("Load Failed!", Color.RED)

func show_save_status(message: String, color: Color):
	save_status_label.text = message
	save_status_label.modulate = color
	
	# Fade out message after 2 seconds
	var tween = create_tween()
	tween.tween_property(save_status_label, "modulate:a", 0.0, 1.0).set_delay(2.0)
	tween.tween_callback(func(): save_status_label.text = "")

func update_ui():
	points_label.text = "Points: " + str(int(points))
	points_per_sec_label.text = "Per second: " + str(idle_clickers * idle_click_rate)
	clicker_price_label.text = str(clicker_price) + " points"
	clickers_owned_label.text = "Idle Clickers Owned: " + str(idle_clickers)
	
	# Disable buy button if can't afford
	$ShopPanel/VBoxContainer/BuyClickerButton.disabled = points < clicker_price
