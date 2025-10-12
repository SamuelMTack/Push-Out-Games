extends Control

# Game variables
@export var points = 0
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

# Quest system
var current_quest_index = 0
var quests = []

# Background Changes
var current_background_tier = 0

# Save file path
const SAVE_PATH = "user://clicker_save.json"

# UI References
@onready var button_click_sfx_coin_button: AudioStreamPlayer2D = %ButtonClickSFXCoinButton
@onready var points_label = %PointsLabel
@onready var click_button = %ClickButton
@onready var shop_panel = %ShopPanel
@onready var clicker_price_label = %PriceLabel
@onready var clickers_owned_label = %ClickersOwnedLabel
@onready var points_per_sec_label = %PointsPerSecLabel
@onready var save_button = %SaveButton
@onready var load_button = %LoadButton
@onready var save_status_label = %SaveStatusLabel
@onready var background_sprite = %BackgroundSprite
@onready var backgroundarea: TextureRect = %Backgroundarea
@onready var quest_panel = %QuestPanel
@onready var quest_title_label = %QuestTitleLabel
@onready var quest_description_label = %QuestDescriptionLabel
@onready var quest_progress_label = %QuestProgressLabel
@onready var complete_quest_button = %CompleteQuestButton
@onready var quest_cost_label = %CostLabel
@onready var quest_popup = $QuestCompletionPopup
@onready var popup_title = $QuestCompletionPopup/PopupVBox/PopupTitle
@onready var popup_message = $QuestCompletionPopup/PopupVBox/PopupMessage
@onready var popup_reward = $QuestCompletionPopup/PopupVBox/PopupReward
@onready var popup_close_button = $QuestCompletionPopup/PopupVBox/CloseButton


#GPU Particles Handling
@onready var gpu_particles_2d: GPUParticles2D = %GPUParticles2D
@onready var timer_last_click: Timer = %TimerLastClick





func _ready():
	initialize_quests()
	
	# Connect signals
	click_button.pressed.connect(_on_click_button_pressed)
	%BuyClickerButton.pressed.connect(_on_buy_clicker_pressed)
	%BuyClickMultiplierButton.pressed.connect(_on_buy_click_multiplier_pressed)
	%BuyAutoClickerButton.pressed.connect(_on_buy_auto_clicker_pressed)
	%BuyGoldenTouchButton.pressed.connect(_on_buy_golden_touch_pressed)
	%BuyMegaFactoryButton.pressed.connect(_on_buy_mega_factory_pressed)
	save_button.pressed.connect(_on_save_button_pressed)
	load_button.pressed.connect(_on_load_button_pressed)
	complete_quest_button.pressed.connect(_on_complete_quest_pressed)
	popup_close_button.pressed.connect(_on_popup_close_pressed)
	
	# Hide popup initially
	quest_popup.visible = false
	
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
	update_background()
	update_quest_ui()

func initialize_quests():
	quests = [
		{
			"title": "The First Step",
			"description": "Invest in your clicking journey to unlock greater possibilities.",
			"cost": 50,
			"reward": "Unlocked: Click Efficiency +10%",
			"reward_type": "click_bonus",
			"reward_value": 0.1
		},
		{
			"title": "Gathering Momentum",
			"description": "Expand your operation to reach new heights of production.",
			"cost": 200,
			"reward": "Unlocked: Idle Speed Boost +25%",
			"reward_type": "idle_bonus",
			"reward_value": 0.25
		},
		{
			"title": "Industrial Revolution",
			"description": "Fund the construction of advanced automation systems.",
			"cost": 750,
			"reward": "Unlocked: +3 Free Idle Clickers",
			"reward_type": "free_clickers",
			"reward_value": 3
		},
		{
			"title": "The Golden Age",
			"description": "Achieve prosperity through massive investment in infrastructure.",
			"cost": 2000,
			"reward": "Unlocked: Click Power x2",
			"reward_type": "click_multiplier",
			"reward_value": 2.0
		},
		{
			"title": "Technological Singularity",
			"description": "Push the boundaries of what's possible with cutting-edge innovation.",
			"cost": 5000,
			"reward": "Unlocked: All Production x1.5",
			"reward_type": "global_multiplier",
			"reward_value": 1.5
		},
		{
			"title": "Cosmic Domination",
			"description": "Transcend mortal limits and ascend to legendary status.",
			"cost": 15000,
			"reward": "Victory! You've mastered the clicker realm!",
			"reward_type": "victory",
			"reward_value": 0
		}
	]


func _on_click_button_pressed():
	var click_value = points_per_click * click_multiplier_bonus * golden_touch_bonus
	points += click_value
	button_click_sfx_coin_button.play()
	timer_last_click.start()
	gpu_particles_2d.amount_ratio += (1 - gpu_particles_2d.amount_ratio)*0.001
	print(str(gpu_particles_2d.amount_ratio))
	update_ui()
	update_background()
	update_quest_ui()

	
	# Add animation effect
	click_button.scale = Vector2(1.5, 1.5)
	var tween = create_tween()
	tween.tween_property(click_button, "scale", Vector2(2.5, 2.5), 0.1)

func _on_timer_last_click_timeout() -> void:
	while gpu_particles_2d.amount_ratio > 0:
		gpu_particles_2d.amount_ratio = gpu_particles_2d.amount_ratio - 0.005 
		await get_tree().create_timer(1.0).timeout
		print(str(gpu_particles_2d.amount_ratio))

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
		
func _on_complete_quest_pressed():
	if current_quest_index >= quests.size():
		return
	
	var quest = quests[current_quest_index]
	if points >= quest.cost:
		points -= quest.cost
		
		# Apply quest reward
		apply_quest_reward(quest)
		
		# Show completion popup
		show_quest_completion_popup(quest)
		
		# Move to next quest
		current_quest_index += 1
		
		update_ui()
		update_quest_ui()

func apply_quest_reward(quest: Dictionary):
	match quest.reward_type:
		"click_bonus":
			points_per_click += quest.reward_value
		"idle_bonus":
			idle_click_rate += quest.reward_value
		"free_clickers":
			idle_clickers += int(quest.reward_value)
		"click_multiplier":
			click_multiplier_bonus *= quest.reward_value
		"global_multiplier":
			idle_click_rate *= quest.reward_value
			mega_factory_multiplier *= quest.reward_value

func show_quest_completion_popup(quest: Dictionary):
	popup_title.text = "Quest Complete!"
	popup_message.text = quest.title + " - Completed!"
	popup_reward.text = quest.reward
	quest_popup.visible = true

func _on_popup_close_pressed():
	quest_popup.visible = false

func update_quest_ui():
	if current_quest_index >= quests.size():
		quest_title_label.text = "All Quests Complete!"
		quest_description_label.text = "You've conquered every challenge!"
		quest_progress_label.text = "Congratulations, Master Clicker!"
		complete_quest_button.visible = false
		return
	
	var quest = quests[current_quest_index]
	quest_title_label.text = "Quest %d: %s" % [current_quest_index + 1, quest.title]
	quest_description_label.text = quest.description
	quest_progress_label.text = "Progress: %d / %d points" % [int(points), quest.cost]
	quest_cost_label.text = str(quest.cost) + " pts"
	complete_quest_button.disabled = points < quest.cost


func _on_idle_timer_timeout():
	if idle_clickers > 0 or auto_clicker_bonus > 0:
		var idle_points = ((idle_clickers * idle_click_rate) + auto_clicker_bonus) * mega_factory_multiplier
		points += idle_points / 10.0
		update_ui()
		update_background()
		
		
func update_background():
	var new_tier = get_background_tier()
	if new_tier != current_background_tier:
		current_background_tier = new_tier
		var background_path = get_background_path(current_background_tier)
		
		# Try to load the background image
		if ResourceLoader.exists(background_path):
			var texture = load(background_path)
			backgroundarea.texture = texture
			

			# Fade in animation
			backgroundarea.modulate.a = 0.0
			var tween = create_tween()
			tween.tween_property(backgroundarea, "modulate:a", 1.0, 1.0)
		else:
			# Fallback to colored backgrounds if images don't exist
			set_fallback_background(current_background_tier)

func get_background_tier() -> int:
	
	
	if points >= 30000:
		return 9  
	elif points >= 20000:
		return 8  
	elif points >= 15000:
		return 7  
	elif points >= 10000:
		return 6  
	elif points >= 6000:
		return 5  
	elif points >= 3000:
		return 4  
	elif points >= 1000:
		return 3  
	elif points >= 500:
		return 2 
	elif points >= 100:
		return 1  
	else:
		return 0  # Simple starting theme

func get_background_path(tier: int) -> String:
	match tier:
		0: return "res://backgrounds/background_0.png"
		1: return "res://backgrounds/background_1.png"
		2: return "res://backgrounds/background_2.png"
		3: return "res://backgrounds/background_3.png"
		4: return "res://backgrounds/background_4.png"
		5: return "res://backgrounds/background_5.png"
		6: return "res://backgrounds/background_6.png"
		7: return "res://backgrounds/background_7.png"
		8: return "res://backgrounds/background_8.png"
		9: return "res://backgrounds/background_9.png"
		_: return ""


func set_fallback_background(tier: int):
	# Create a colored rectangle as fallback
	var color: Color
	match tier:
		0: color = Color(0.7, 0.8, 0.9)  # Light blue
		1: color = Color(0.8, 0.9, 0.6)  # Light green
		2: color = Color(0.4, 0.7, 0.4)  # Forest green
		3: color = Color(0.6, 0.7, 0.8)  # Mountain gray-blue
		4: color = Color(0.5, 0.5, 0.6)  # City gray
		5: color = Color(0.9, 0.8, 0.4)  # Golden yellow
		6: color = Color(0.1, 0.1, 0.3)  # Dark space blue
		_: color = Color.WHITE
	
	backgroundarea.modulate = color
func _on_save_button_pressed():
	save_game()

func _on_load_button_pressed():
	load_game()

func save_game():
	var save_data = {
		"points": points,
		"points_per_click": points_per_click,
		"idle_clickers": idle_clickers,
		"idle_click_rate": idle_click_rate,
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
		"mega_factory_multiplier": mega_factory_multiplier,
		"current_quest_index": current_quest_index
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
			points_per_click = save_data.get("points_per_click", 1)
			idle_clickers = save_data.get("idle_clickers", 0)
			idle_click_rate = save_data.get("idle_click_rate", 1.0)
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
			current_quest_index = save_data.get("current_quest_index", 0)
			
			update_ui()
			update_background()
			update_quest_ui()
			
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
	clickers_owned_label.text =  str(idle_clickers)
	%BuyClickerButton.disabled = points < clicker_price
	
	# Click Multiplier
	%PriceLabelMulti.text = str(click_multiplier_price) + " pts"
	%ClickMultiplierLevel.text = "(Lv %d) +%.1fx per click" % [click_multiplier_level, click_multiplier_bonus]
	%BuyClickMultiplierButton.disabled = points < click_multiplier_price
	
	# Auto Clicker
	%PriceLabelAuto.text = str(auto_clicker_price) + " pts"
	%AutoClickerLevel.text = "(Lv %d) +%d pts/sec" % [auto_clicker_level, auto_clicker_bonus]
	%BuyAutoClickerButton.disabled = points < auto_clicker_price
	
	# Golden Touch
	%PriceLabelGoldenTouch.text = str(golden_touch_price) + " pts"
	%GoldenTouchLevel.text = "(Lv %d) +%.1fx click value" % [golden_touch_level, golden_touch_bonus]
	%BuyGoldenTouchButton.disabled = points < golden_touch_price
	
	# Mega Factory
	%PriceLabelFactory.text = str(mega_factory_price) + " pts"
	%MegaFactoryLevel.text = "(Lv %d) +%.2fx idle production" % [mega_factory_level, mega_factory_multiplier]
	%BuyMegaFactoryButton.disabled = points < mega_factory_price
