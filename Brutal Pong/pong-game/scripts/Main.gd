extends Node2D

@onready var ball := $Ball
@onready var player1 := $Player1
@onready var player2 := $Player2
@onready var score1 := $Score1
@onready var score2 := $Score2

# Game state variables
var player_lives := 3
var round_time := 60.0
var current_round_time := 60.0
var game_state := "playing"  # "playing", "shop", "game_over"
var spikes := []
var wall_traps := []

# Scoreboard variables
var player_score := 0
var ai_score := 0

# Spike system
var spike_spawn_timer := 0.0
var spike_spawn_interval := 3.0

# Wall trap system
var wall_trap_timer := 0.0
var wall_trap_interval := 5.0

# UI references
var lives_label: Label
var timer_label: Label
var shop_ui: Control

func _ready():
	# Set up ball references and initial scores
	ball.player_score = score1
	ball.ai_score = score2
	update_scoreboard()

	# Set up player controls
	player1.move_up_action = "ui_w"
	player1.move_down_action = "ui_s"
	player1.move_left_action = "ui_a"
	player1.move_right_action = "ui_d"
	player1.is_player = true

	# Create UI elements
	create_ui_elements()

	# Start the game
	start_round()

func _process(delta):
	if game_state == "playing":
		handle_round_timer(delta)
		handle_spike_spawning(delta)
		handle_wall_traps(delta)
		handle_distance_attacks()
		handle_boosts(delta)

func handle_round_timer(delta):
	current_round_time -= delta
	if timer_label:
		timer_label.text = "Time: " + str(int(current_round_time))

	if current_round_time <= 0:
		end_round()

func handle_spike_spawning(delta):
	spike_spawn_timer += delta
	if spike_spawn_timer >= spike_spawn_interval:
		spawn_spike()
		spike_spawn_timer = 0.0

func handle_wall_traps(delta):
	wall_trap_timer += delta
	if wall_trap_timer >= wall_trap_interval:
		spawn_wall_trap()
		wall_trap_timer = 0.0

func handle_distance_attacks():
	if Input.is_action_pressed("left_click"):
		var mouse_pos = get_global_mouse_position()
		var player_pos = player1.global_position
		var direction = (mouse_pos - player_pos).normalized()

		# Horizontal attacks can be held
		if abs(direction.x) > abs(direction.y):
			player1.distance_attack(direction)

	if Input.is_action_just_pressed("left_click"):
		var mouse_pos = get_global_mouse_position()
		var player_pos = player1.global_position
		var direction = (mouse_pos - player_pos).normalized()

		# Vertical attacks must be clicked
		if abs(direction.y) > abs(direction.x):
			player1.distance_attack(direction)

func spawn_spike():
	# Create spike as StaticBody2D so ball can collide with it
	var spike = StaticBody2D.new()
	spike.name = "Spike_" + str(spikes.size())

	# Add collision shape - square like paddle
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(30, 30)  # Match the visual size
	collision.shape = shape
	spike.add_child(collision)

	# Add Area2D for player damage detection
	var damage_area = Area2D.new()
	damage_area.name = "DamageArea"
	var damage_collision = CollisionShape2D.new()
	var damage_shape = CircleShape2D.new()
	damage_shape.radius = 20  # Slightly larger for player damage
	damage_collision.shape = damage_shape
	damage_area.add_child(damage_collision)
	spike.add_child(damage_area)

	# Connect player damage
	damage_area.body_entered.connect(func(body): spike_hit_player(body))

	# Add visual - create a circle-like appearance
	var visual = ColorRect.new()
	visual.size = Vector2(30, 30)
	visual.position = Vector2(-15, -15)
	visual.color = Color.RED

	# Make it look more circular by adding corner rounding (if you prefer square, remove this line)
	# For now using square - if you want circle effect, we can add a custom draw function
	spike.add_child(visual)

	# Random position in middle area, avoiding ball and its trajectory
	var spike_pos: Vector2
	var attempts = 0
	var safe_distance = 150.0  # Increased minimum distance from ball

	while attempts < 20:  # More attempts to find safe position
		spike_pos = Vector2(
			randf_range(300, 700),  # Avoid reset areas (-100 to 1100)
			randf_range(150, 450)
		)

		# Check current ball position
		var distance_to_ball = ball.position.distance_to(spike_pos)

		# Predict ball position in next 2 seconds to avoid trajectory
		var ball_future_pos = ball.position + (ball.velocity * 2.0)
		var distance_to_future = ball_future_pos.distance_to(spike_pos)

		# Avoid reset areas (left edge < 0, right edge > 1000)
		var too_close_to_reset = spike_pos.x < 100 or spike_pos.x > 900

		# Position is safe if far from ball and not near reset zones
		if distance_to_ball > safe_distance and distance_to_future > safe_distance and not too_close_to_reset:
			break
		attempts += 1

	# If we couldn't find a safe position, don't spawn the spike
	if attempts >= 20:
		spike.queue_free()
		return

	spike.position = spike_pos

	add_child(spike)
	spikes.append(spike)

	# Remove after some time
	var timer = get_tree().create_timer(8.0)
	timer.timeout.connect(func(): remove_spike(spike))

func spawn_wall_trap():
	var trap = Area2D.new()
	trap.name = "WallTrap_" + str(wall_traps.size())

	# Add collision - only for player detection, not ball
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	collision.shape = shape
	trap.add_child(collision)

	# Set collision layers so only player can be detected, not ball
	trap.collision_layer = 0  # Don't be detected by others
	trap.collision_mask = 1   # Only detect layer 1 (player)

	# Add visual (flame effect)
	var visual = ColorRect.new()
	visual.color = Color(1, 0.5, 0, 0.8)  # Orange flame color
	trap.add_child(visual)

	# Random wall position - cover entire edges
	var wall_side = randi() % 4  # 0=left, 1=right, 2=top, 3=bottom
	match wall_side:
		0:  # Left wall - full height
			trap.position = Vector2(20, 300)
			shape.size = Vector2(40, 600)  # Full screen height
			visual.size = Vector2(40, 600)
			visual.position = Vector2(-20, -300)
		1:  # Right wall - full height
			trap.position = Vector2(980, 300)
			shape.size = Vector2(40, 600)  # Full screen height
			visual.size = Vector2(40, 600)
			visual.position = Vector2(-20, -300)
		2:  # Top wall - full width
			trap.position = Vector2(500, 20)
			shape.size = Vector2(1000, 40)  # Full screen width
			visual.size = Vector2(1000, 40)
			visual.position = Vector2(-500, -20)
		3:  # Bottom wall - full width
			trap.position = Vector2(500, 580)
			shape.size = Vector2(1000, 40)  # Full screen width
			visual.size = Vector2(1000, 40)
			visual.position = Vector2(-500, -20)

	add_child(trap)
	wall_traps.append(trap)

	# Connect to player collision
	trap.body_entered.connect(func(body): player_hit_by_wall_trap(body))

	# Remove after some time
	var timer = get_tree().create_timer(3.0)
	timer.timeout.connect(func(): remove_wall_trap(trap))

func remove_spike(spike):
	if spike and is_instance_valid(spike):
		spikes.erase(spike)
		spike.queue_free()

func remove_wall_trap(trap):
	if trap and is_instance_valid(trap):
		wall_traps.erase(trap)
		trap.queue_free()

func player_hit_by_spike():
	lose_life("Hit by spike!")

func spike_hit_player(body):
	if body == player1:
		lose_life("Hit by spike!")

func player_hit_by_wall_trap(body):
	if body == player1:
		lose_life("Hit by wall trap!")

func lose_life(reason: String):
	# Check if shield is active
	if shield_active:
		print("Shield protected you from: ", reason)
		return

	player_lives -= 1
	if lives_label:
		lives_label.text = "Lives: " + str(player_lives)

	print("Player lost a life: ", reason)

	if player_lives <= 0:
		game_over()

func handle_boosts(delta):
	# Handle shield timer
	if shield_active:
		shield_timer -= delta
		if shield_timer <= 0:
			shield_active = false
			print("Shield deactivated!")
			# Remove shield visual
			var shield_visual = player1.get_node_or_null("ShieldVisual")
			if shield_visual:
				shield_visual.queue_free()

	# Handle speed boost timer
	if speed_boost_active:
		speed_boost_timer -= delta
		if speed_boost_timer <= 0:
			speed_boost_active = false
			if player1:
				player1.speed = original_speed
			print("Speed boost ended!")

	# Handle attack boost timer
	if attack_boost_active:
		attack_boost_timer -= delta
		if attack_boost_timer <= 0:
			attack_boost_active = false
			if player1:
				player1.attack_force = original_attack_force
			print("Attack boost ended!")

func start_round():
	game_state = "playing"
	current_round_time = round_time
	clear_traps()

func end_round():
	game_state = "shop"
	show_shop()

func show_shop():
	# Create and show shop
	var shop_scene = preload("res://scripts/Shop.gd")
	var shop = Control.new()
	shop.set_script(shop_scene)
	add_child(shop)

	# Give player some currency based on performance
	var currency_earned = 10 + (score1.text.to_int() * 5)
	shop.add_currency(currency_earned)

	# Connect shop closed signal
	shop.shop_closed.connect(start_round)

# Shop item effects
func add_life():
	player_lives += 1
	if lives_label:
		lives_label.text = "Lives: " + str(player_lives)

var shield_active := false
var shield_timer := 0.0

func activate_shield(duration: float):
	shield_active = true
	shield_timer = duration
	print("Shield activated for ", duration, " seconds!")

	# Add visual shield effect
	var shield_visual = ColorRect.new()
	shield_visual.name = "ShieldVisual"
	shield_visual.size = Vector2(30, 110)
	shield_visual.position = Vector2(-5, -5)
	shield_visual.color = Color(0, 1, 1, 0.3)  # Cyan semi-transparent
	player1.add_child(shield_visual)

var speed_boost_active := false
var original_speed := 400.0
var speed_boost_timer := 0.0

func boost_speed(multiplier: float, duration: float):
	if player1:
		original_speed = player1.speed
		player1.speed *= multiplier
		speed_boost_active = true
		speed_boost_timer = duration
		print("Speed boost activated!")

var attack_boost_active := false
var original_attack_force := 300.0
var attack_boost_timer := 0.0

func boost_attack(multiplier: float, duration: float):
	if player1:
		original_attack_force = player1.attack_force
		player1.attack_force *= multiplier
		attack_boost_active = true
		attack_boost_timer = duration
		print("Attack boost activated!")

func game_over():
	game_state = "game_over"
	# AI gets a point when player runs out of lives
	ai_score += 1
	update_scoreboard()
	print("Game Over! Player lives: ", player_lives, " | Final Score - Player: ", player_score, " AI: ", ai_score)

	# Reset for next game
	player_lives = 3
	if lives_label:
		lives_label.text = "Lives: " + str(player_lives)

	# Wait a moment then restart
	var timer = get_tree().create_timer(3.0)
	timer.timeout.connect(start_round)

func clear_traps():
	for spike in spikes:
		if is_instance_valid(spike):
			spike.queue_free()
	for trap in wall_traps:
		if is_instance_valid(trap):
			trap.queue_free()
	spikes.clear()
	wall_traps.clear()

func create_ui_elements():
	# Lives label
	lives_label = Label.new()
	lives_label.position = Vector2(50, 20)
	lives_label.text = "Lives: " + str(player_lives)
	lives_label.add_theme_color_override("font_color", Color.WHITE)
	add_child(lives_label)

	# Timer label
	timer_label = Label.new()
	timer_label.position = Vector2(450, 20)
	timer_label.text = "Time: " + str(int(current_round_time))
	timer_label.add_theme_color_override("font_color", Color.WHITE)
	add_child(timer_label)

	# Controls info
	var controls_label = Label.new()
	controls_label.position = Vector2(50, 570)
	controls_label.text = "Controls: WASD to move, Left Click to attack ball"
	controls_label.add_theme_color_override("font_color", Color.GRAY)
	add_child(controls_label)

func update_scoreboard():
	if score1:
		score1.text = str(player_score)
	if score2:
		score2.text = str(ai_score)

func player_scored():
	player_score += 1
	update_scoreboard()
	print("Player scored! Score: ", player_score, " - ", ai_score)

func ai_scored():
	ai_score += 1
	update_scoreboard()
	print("AI scored! Score: ", player_score, " - ", ai_score)
