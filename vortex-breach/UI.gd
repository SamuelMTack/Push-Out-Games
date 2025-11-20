extends CanvasLayer

@onready var health_bar = $MarginContainer/VBoxContainer/HealthBar
@onready var health_label = $MarginContainer/VBoxContainer/HealthBar/HealthLabel

@onready var stamina_bar = $MarginContainer/VBoxContainer/StaminaBar
@onready var stamina_label = $MarginContainer/VBoxContainer/StaminaBar/StaminaLabel

@onready var ammo_label = $MarginContainer/VBoxContainer/AmmoLabel
@onready var gold_label = $MarginContainer/VBoxContainer/GoldLabel
@onready var powerup_label = $MarginContainer/VBoxContainer/PowerupLabel

# Direction indicator
var door_position = Vector3.ZERO
var direction_indicator: Control = null
var arrow_label: Label = null
var distance_label: Label = null

func _ready():
	# Create direction indicator UI
	create_direction_indicator()

func create_direction_indicator():
	# Create container for the direction indicator
	direction_indicator = Control.new()
	direction_indicator.set_anchors_preset(Control.PRESET_CENTER_TOP)
	direction_indicator.position = Vector2(0, 80)  # Position below top UI elements
	add_child(direction_indicator)
	
	# Create arrow label that will rotate
	arrow_label = Label.new()
	arrow_label.text = "▲"  # Up arrow character
	arrow_label.add_theme_font_size_override("font_size", 48)
	arrow_label.add_theme_color_override("font_color", Color.GOLD)
	arrow_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	arrow_label.add_theme_constant_override("shadow_outline_size", 2)
	arrow_label.set_anchors_preset(Control.PRESET_CENTER)
	arrow_label.position = Vector2(-24, 0)  # Center the arrow
	direction_indicator.add_child(arrow_label)
	
	# Create distance label
	distance_label = Label.new()
	distance_label.text = "Exit: 0m"
	distance_label.add_theme_font_size_override("font_size", 20)
	distance_label.add_theme_color_override("font_color", Color.WHITE)
	distance_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	distance_label.add_theme_constant_override("shadow_outline_size", 1)
	distance_label.set_anchors_preset(Control.PRESET_CENTER)
	distance_label.position = Vector2(-40, 35)  # Below arrow
	direction_indicator.add_child(distance_label)
	
	# Add background panel for better visibility
	var bg_panel = Panel.new()
	bg_panel.custom_minimum_size = Vector2(100, 80)
	bg_panel.position = Vector2(-50, -10)
	bg_panel.modulate = Color(0, 0, 0, 0.5)  # Semi-transparent black
	direction_indicator.add_child(bg_panel)
	direction_indicator.move_child(bg_panel, 0)  # Move to back

func _process(_delta):
	# Update direction arrow to point to door
	if door_position != Vector3.ZERO and arrow_label:
		var player = get_node_or_null("/root/World/Player")
		if player:
			# Calculate direction from player to door
			var player_pos = player.global_position
			var direction = door_position - player_pos
			direction.y = 0  # Ignore vertical difference
			
			# Calculate distance
			var distance = direction.length()
			if distance_label:
				distance_label.text = "Exit: %dm" % int(distance)
			
			# Get player's forward direction (camera facing)
			var camera = player.get_node_or_null("Camera3D")
			if camera:
				# Get camera's forward direction in world space
				var camera_forward = -camera.global_transform.basis.z
				camera_forward.y = 0
				camera_forward = camera_forward.normalized()
				
				# Get camera's right direction
				var camera_right = camera.global_transform.basis.x
				camera_right.y = 0
				camera_right = camera_right.normalized()
				
				# Calculate angle between camera forward and direction to door
				direction = direction.normalized()
				
				# Use dot product to find angle
				var forward_dot = camera_forward.dot(direction)
				var right_dot = camera_right.dot(direction)
				
				# Calculate rotation angle for arrow
				var angle = atan2(right_dot, forward_dot)
				
				# Rotate the arrow
				arrow_label.rotation = angle
				
				# Change arrow color based on distance
				if distance < 10:
					arrow_label.add_theme_color_override("font_color", Color.GREEN)
				elif distance < 25:
					arrow_label.add_theme_color_override("font_color", Color.GOLD)
				else:
					arrow_label.add_theme_color_override("font_color", Color.ORANGE)

func set_door_position(pos: Vector3):
	door_position = pos

func update_health(current: float, maximum: float):
	var percentage = (current / maximum) * 100
	health_bar.value = percentage
	health_label.text = "Health: %d/%d" % [current, maximum]
	
	# Color based on health
	if percentage > 60:
		health_bar.modulate = Color.GREEN
	elif percentage > 30:
		health_bar.modulate = Color.YELLOW
	else:
		health_bar.modulate = Color.RED

func update_stamina(current: float, maximum: float):
	var percentage = (current / maximum) * 100
	stamina_bar.value = percentage
	stamina_label.text = "Stamina: %d/%d" % [current, maximum]

func update_ammo(current: int, maximum: int):
	ammo_label.text = "Ammo: %d/%d" % [current, maximum]
	
	if current <= 0:
		ammo_label.modulate = Color.RED
	elif current < maximum * 0.3:
		ammo_label.modulate = Color.YELLOW
	else:
		ammo_label.modulate = Color.WHITE

func update_gold(amount: int):
	gold_label.text = "Gold: %d" % amount

func update_powerup(powerup_name: String, time_remaining: float):
	if powerup_name == "":
		powerup_label.text = "Powerup: None"
		powerup_label.modulate = Color.WHITE
	else:
		var display_name = powerup_name.capitalize()
		powerup_label.text = "Powerup: %s (%.1fs)" % [display_name, time_remaining]
		powerup_label.modulate = Color.CYAN
