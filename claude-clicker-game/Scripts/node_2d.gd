extends Control

# Game variables
var points = 0
var points_per_click = 1
var idle_clickers = 0
var idle_click_rate = 1.0 # Points per second per clicker

# Shop prices
var clicker_base_price = 10
var clicker_price = clicker_base_price

# Power-up variables
var click_multiplier_level = 0
var click_multiplier_price = 50
var click_multiplier_bonus = 1.0

var auto_clicker_level = 0
var auto_clicker_price = 100
var auto_clicker_bonus = 0

var golden_touch_level = 0
var golden_touch_price = 250
var golden_touch_bonus = 1.0

var mega_factory_level = 0
var mega_factory_price = 500
var mega_factory_multiplier = 1.0

# Save file path
const SAVE_PATH = "user://clicker_save.json"

# UI References
@onready var button_click_sfx_coin_button: AudioStreamPlayer2D = %ButtonClickSFXCoinButton
@onready var points_label = %PointsLabel
@onready var click_button = %ClickButton
@onready var shop_panel = $ShopPanel
@onready var clicker_price_label = $ShopPanel/ShopScroll/ShopItems/BuyClickerButton/PriceLabel
@onready var clickers_owned_label = $ShopPanel/ShopScroll/ShopItems/ClickersOwnedLabel
@onready var points_per_sec_label = %PointsPerSecLabel
@onready var save_button = %SaveButton
@onready var load_button = %LoadButton
@onready var save_status_label = %SaveStatusLabel

func _ready():
	# Connect signals
	click_button.pressed.connect(_on_click_button_pressed)
	$ShopPanel/ShopScroll/ShopItems/BuyClickerButton.pressed.connect(_on_buy_clicker_pressed)
	$ShopPanel/ShopScroll/ShopItems/BuyClickMultiplierButton.pressed.connect(_on_buy_click_multiplier_pressed)
	$ShopPanel/ShopScroll/ShopItems/BuyAutoClickerButton.pressed.connect(_on_buy_auto_clicker_pressed)
	$ShopPanel/ShopScroll/ShopItems/BuyGoldenTouchButton.pressed.connect(_on_buy_golden_touch_pressed)
	$ShopPanel/ShopScroll/ShopItems/BuyMegaFactoryButton.pressed.connect(_on_buy_mega_factory_pressed)
	save_button.pressed.connect(_on_save_button_pressed)
	load_button.pressed.connect(_on_load_button_pressed)
	
	# Start idle clicker timer
	var timer = Timer.new()
	timer.wait_time = 0.1
	timer.timeout.connect(_on_idle_timer_timeout)
	add_child(timer)
	timer.start()
	
	# Auto-load on start if save exists
	if FileAccess.file_exists(SAVE_PATH):
		load_game()
	
	update_ui()

func _on_click_button_pressed():
	var click_value = points_per_click * click_multiplier_bonus * golden_touch_bonus
	points += click_value
	button_click_sfx_coin_button.play()
	update_ui()
	
	# Add animation effect
	click_button.scale = Vector2(0.95, 0.95)
	var tween = create_tween()
	tween.tween_property(click_button, "scale", Vector2(6, 6), 0.1)

func _on_buy_clicker_pressed():
	if points >= clicker_price:
		points -= clicker_price
		idle_clickers += 1
		clicker_price = int(clicker_base_price * pow(1.15, idle_clickers))
		update_ui()

func _on_buy_click_multiplier_pressed():
	if points >= click_multiplier_price:
		points -= click_multiplier_price
		click_multiplier_level += 1
		click_multiplier_bonus = 1.0 + (click_multiplier_level * 0.5)
		click_multiplier_price = int(50 * pow(2, click_multiplier_level))
		update_ui()

func _on_buy_auto_clicker_pressed():
	if points >= auto_clicker_price:
		points -= auto_clicker_price
		auto_clicker_level += 1
		auto_clicker_bonus = auto_clicker_level * 5
		auto_clicker_price = int(100 * pow(2.5, auto_clicker_level))
		update_ui()

func _on_buy_golden_touch_pressed():
	if points >= golden_touch_price:
		points -= golden_touch_price
		golden_touch_level += 1
		golden_touch_bonus = 1.0 + (golden_touch_level * 1.0)
		golden_touch_price = int(250 * pow(3, golden_touch_level))
		update_ui()

func _on_buy_mega_factory_pressed():
	if points >= mega_factory_price:
		points -= mega_factory_price
		mega_factory_level += 1
		mega_factory_multiplier = 1.0 + (mega_factory_level * 0.25)
		mega_factory_price = int(500 * pow(4, mega_factory_level))
		update_ui()

func _on_idle_timer_timeout():
	if idle_clickers > 0 or auto_clicker_bonus > 0:
		var idle_points = ((idle_clickers * idle_click_rate) + auto_clicker_bonus) * mega_factory_multiplier
		points += idle_points / 10.0
		update_ui()

func _on_save_button_pressed():
	save_game()

func _on_load_button_pressed():
	load_game()

func save_game():
	var save_data = {
		"points": points,
		"idle_clickers": idle_clickers,
		"clicker_price": clicker_price,
		"click_multiplier_level": click_multiplier_level,
		"click_multiplier_price": click_multiplier_price,
		"click_multiplier_bonus": click_multiplier_bonus,
		"auto_clicker_level": auto_clicker_level,
		"auto_clicker_price": auto_clicker_price,
		"auto_clicker_bonus": auto_clicker_bonus,
		"golden_touch_level": golden_touch_level,
		"golden_touch_price": golden_touch_price,
		"golden_touch_bonus": golden_touch_bonus,
		"mega_factory_level": mega_factory_level,
		"mega_factory_price": mega_factory_price,
		"mega_factory_multiplier": mega_factory_multiplier
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
			click_multiplier_level = save_data.get("click_multiplier_level", 0)
			click_multiplier_price = save_data.get("click_multiplier_price", 50)
			click_multiplier_bonus = save_data.get("click_multiplier_bonus", 1.0)
			auto_clicker_level = save_data.get("auto_clicker_level", 0)
			auto_clicker_price = save_data.get("auto_clicker_price", 100)
			auto_clicker_bonus = save_data.get("auto_clicker_bonus", 0)
			golden_touch_level = save_data.get("golden_touch_level", 0)
			golden_touch_price = save_data.get("golden_touch_price", 250)
			golden_touch_bonus = save_data.get("golden_touch_bonus", 1.0)
			mega_factory_level = save_data.get("mega_factory_level", 0)
			mega_factory_price = save_data.get("mega_factory_price", 500)
			mega_factory_multiplier = save_data.get("mega_factory_multiplier", 1.0)
			update_ui()
			show_save_status("Game Loaded!", Color.GREEN)
		else:
			show_save_status("Load Failed!", Color.RED)
	else:
		show_save_status("Load Failed!", Color.RED)

func show_save_status(message: String, color: Color):
	save_status_label.text = message
	save_status_label.modulate = color
	
	var tween = create_tween()
	tween.tween_property(save_status_label, "modulate:a", 0.0, 1.0).set_delay(2.0)
	tween.tween_callback(func(): save_status_label.text = "")

func update_ui():
	points_label.text = "Points: " + str(int(points))
	var total_per_sec = ((idle_clickers * idle_click_rate) + auto_clicker_bonus) * mega_factory_multiplier
	points_per_sec_label.text = "Per second: %.1f" % total_per_sec
	
	# Idle Clickers
	clicker_price_label.text = str(clicker_price) + " pts"
	clickers_owned_label.text = "Idle Clickers: " + str(idle_clickers)
	$ShopPanel/ShopScroll/ShopItems/BuyClickerButton.disabled = points < clicker_price
	
	# Click Multiplier
	$ShopPanel/ShopScroll/ShopItems/BuyClickMultiplierButton/PriceLabel.text = str(click_multiplier_price) + " pts"
	$ShopPanel/ShopScroll/ShopItems/ClickMultiplierLevel.text = "Click Power (Lv %d) - +%.1fx per click" % [click_multiplier_level, click_multiplier_bonus]
	$ShopPanel/ShopScroll/ShopItems/BuyClickMultiplierButton.disabled = points < click_multiplier_price
	
	# Auto Clicker
	$ShopPanel/ShopScroll/ShopItems/BuyAutoClickerButton/PriceLabel.text = str(auto_clicker_price) + " pts"
	$ShopPanel/ShopScroll/ShopItems/AutoClickerLevel.text = "Auto Clicker (Lv %d) - +%d pts/sec" % [auto_clicker_level, auto_clicker_bonus]
	$ShopPanel/ShopScroll/ShopItems/BuyAutoClickerButton.disabled = points < auto_clicker_price
	
	# Golden Touch
	$ShopPanel/ShopScroll/ShopItems/BuyGoldenTouchButton/PriceLabel.text = str(golden_touch_price) + " pts"
	$ShopPanel/ShopScroll/ShopItems/GoldenTouchLevel.text = "Golden Touch (Lv %d) - %.1fx click value" % [golden_touch_level, golden_touch_bonus]
	$ShopPanel/ShopScroll/ShopItems/BuyGoldenTouchButton.disabled = points < golden_touch_price
	
	# Mega Factory
	$ShopPanel/ShopScroll/ShopItems/BuyMegaFactoryButton/PriceLabel.text = str(mega_factory_price) + " pts"
	$ShopPanel/ShopScroll/ShopItems/MegaFactoryLevel.text = "Mega Factory (Lv %d) - %.2fx idle production" % [mega_factory_level, mega_factory_multiplier]
	$ShopPanel/ShopScroll/ShopItems/BuyMegaFactoryButton.disabled = points < mega_factory_price
