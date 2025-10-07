extends Control

# Game variables
var points = 0
var points_per_click = 1
var idle_clickers = 0
var idle_click_rate = 1.0 # Points per second per clicker

# Shop prices
var clicker_base_price = 10
var clicker_price = clicker_base_price

# UI References
@onready var points_label = $VBoxContainer/PointsLabel
@onready var click_button = $VBoxContainer/ClickButton
@onready var shop_panel = $ShopPanel
@onready var clicker_price_label = $ShopPanel/VBoxContainer/BuyClickerButton/PriceLabel
@onready var clickers_owned_label = $ShopPanel/VBoxContainer/ClickersOwnedLabel
@onready var points_per_sec_label = $VBoxContainer/PointsPerSecLabel

func _ready():
	# Connect signals
	click_button.pressed.connect(_on_click_button_pressed)
	$ShopPanel/VBoxContainer/BuyClickerButton.pressed.connect(_on_buy_clicker_pressed)
	
	# Start idle clicker timer
	var timer = Timer.new()
	timer.wait_time = 0.1 # Update 10 times per second for smooth increments
	timer.timeout.connect(_on_idle_timer_timeout)
	add_child(timer)
	timer.start()
	
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

func update_ui():
	points_label.text = "Points: " + str(int(points))
	points_per_sec_label.text = "Per second: " + str(idle_clickers * idle_click_rate)
	clicker_price_label.text = str(clicker_price) + " points"
	clickers_owned_label.text = "Idle Clickers Owned: " + str(idle_clickers)
	
	# Disable buy button if can't afford
	$ShopPanel/VBoxContainer/BuyClickerButton.disabled = points < clicker_price
