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
var spike_spawn_interval := 8.0

# Wall trap system
var wall_trap_timer := 0.0
var wall_trap_interval := 5.0

# Coin system
var coins := []
var coin_spawn_timer := 0.0
var coin_spawn_interval := 7.0
var player_currency := 0

# UI references
var lives_label: Label
var timer_label: Label
var currency_label: Label
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

	# Initialize timer and start the game
	current_round_time = round_time
	start_round()

func _process(delta):
	if game_state == "playing":
		handle_round_timer(delta)
		handle_spike_spawning(delta)
		handle_wall_traps(delta)
		handle_coin_spawning(delta)
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

func handle_coin_spawning(delta):
	coin_spawn_timer += delta
	if coin_spawn_timer >= coin_spawn_interval:
		spawn_coin()
		coin_spawn_timer = 0.0

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
	# Random position for first spike, then mirror it
	var spike_pos: Vector2
	var attempts = 0
	var safe_distance = 150.0

	while attempts < 20:
		spike_pos = Vector2(
			randf_range(150, 400),  # Only generate on left side first
			randf_range(150, 450)
		)

		# Check current ball position
		var distance_to_ball = ball.position.distance_to(spike_pos)

		# Predict ball position in next 2 seconds to avoid trajectory
		var ball_future_pos = ball.position + (ball.velocity * 2.0)
		var distance_to_future = ball_future_pos.distance_to(spike_pos)

		# Position is safe if far from ball
		if distance_to_ball > safe_distance and distance_to_future > safe_distance:
			break
		attempts += 1

	# If we couldn't find a safe position, don't spawn spikes
	if attempts >= 20:
		return

	# Create mirrored spikes
	for side in range(2):  # 0=left, 1=right (mirrored)
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
		spike.add_child(visual)

		# Set position - mirror across center line (x=500)
		if side == 0:  # Left side (original)
			spike.position = spike_pos
		else:  # Right side (mirrored)
			spike.position = Vector2(1000 - spike_pos.x, spike_pos.y)

		add_child(spike)
		spikes.append(spike)

		# Remove after some time
		get_tree().create_timer(8.0).timeout.connect(remove_spike.bind(spike))

func spawn_wall_trap():
	# Random wall type and position
	var wall_side = randi() % 2  # 0=vertical, 1=horizontal

	match wall_side:
		0:  # Vertical walls - create mirrored left and right
			for side in range(2):  # 0=left, 1=right
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

				if side == 0:  # Left wall
					trap.position = Vector2(20, 300)
				else:  # Right wall (mirrored)
					trap.position = Vector2(980, 300)

				shape.size = Vector2(40, 600)  # Full screen height
				visual.size = Vector2(40, 600)
				visual.position = Vector2(-20, -300)

				add_child(trap)
				wall_traps.append(trap)

				# Connect to player collision
				trap.body_entered.connect(func(body): player_hit_by_wall_trap(body))

				# Remove after some time
				get_tree().create_timer(3.0).timeout.connect(remove_wall_trap.bind(trap))

		1:  # Horizontal walls - single wall only
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

			# Random top or bottom
			if randf() > 0.5:  # Top wall
				trap.position = Vector2(500, 20)
			else:  # Bottom wall
				trap.position = Vector2(500, 580)

			shape.size = Vector2(1000, 40)  # Full screen width
			visual.size = Vector2(1000, 40)
			visual.position = Vector2(-500, -20)

			add_child(trap)
			wall_traps.append(trap)

			# Connect to player collision
			trap.body_entered.connect(func(body): player_hit_by_wall_trap(body))

			# Remove after some time
			get_tree().create_timer(3.0).timeout.connect(remove_wall_trap.bind(trap))

func spawn_coin():
	# Find safe position in middle area, away from existing spikes
	var coin_pos: Vector2
	var attempts = 0
	var safe_distance_from_ball = 80.0
	var safe_distance_from_spikes = 60.0

	while attempts < 20:
		coin_pos = Vector2(
			randf_range(480, 520),  # Spawn in middle area around center line
			randf_range(100, 500)
		)

		# Check if position is safe (not too close to ball)
		var distance_to_ball = ball.position.distance_to(coin_pos)
		if distance_to_ball < safe_distance_from_ball:
			attempts += 1
			continue

		# Check if position is safe (not too close to existing spikes)
		var too_close_to_spike = false
		for spike in spikes:
			if is_instance_valid(spike):
				var distance_to_spike = spike.position.distance_to(coin_pos)
				if distance_to_spike < safe_distance_from_spikes:
					too_close_to_spike = true
					break

		if not too_close_to_spike:
			break
		attempts += 1

	# If we couldn't find a safe position, don't spawn coin
	if attempts >= 20:
		return

	# Create single coin at center line
	var coin = Area2D.new()
	coin.name = "Coin_" + str(coins.size())

	# Add collision for player collection only
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 15  # Coin collection radius
	collision.shape = shape
	coin.add_child(collision)

	# Set collision layers so only player can collect
	coin.collision_layer = 0  # Don't be detected by others
	coin.collision_mask = 1   # Only detect layer 1 (player)

	# Add visual - yellow circle
	var visual = ColorRect.new()
	visual.size = Vector2(20, 20)
	visual.position = Vector2(-10, -10)
	visual.color = Color.YELLOW
	coin.add_child(visual)

	# Position at center line
	coin.position = coin_pos

	add_child(coin)
	coins.append(coin)

	# Connect collection
	coin.body_entered.connect(func(body): collect_coin(body, coin))

	# Remove after some time
	get_tree().create_timer(12.0).timeout.connect(remove_coin.bind(coin))

func collect_coin(body, coin):
	if body == player1:
		player_currency += 5
		if currency_label:
			currency_label.text = "Coins: " + str(player_currency)
		remove_coin(coin)

func remove_coin(coin):
	if coin and is_instance_valid(coin):
		coins.erase(coin)
		coin.queue_free()

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

func lose_life(_reason: String):
	# Check if shield is active
	if shield_active:
		return

	player_lives -= 1
	if lives_label:
		lives_label.text = "Lives: " + str(player_lives)

	if player_lives <= 0:
		game_over()

func handle_boosts(delta):
	# Handle shield timer
	if shield_active:
		shield_timer -= delta
		if shield_timer <= 0:
			shield_active = false
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

	# Handle attack boost timer
	if attack_boost_active:
		attack_boost_timer -= delta
		if attack_boost_timer <= 0:
			attack_boost_active = false
			if player1:
				player1.attack_force = original_attack_force

func start_round():
	game_state = "playing"
	# Don't reset timer - let it continue
	clear_traps()

func end_round():
	game_state = "shop"
	show_shop()

func show_shop():
	# Pause the game
	get_tree().paused = true

	# Create and show shop
	var shop_scene = preload("res://scripts/Shop.gd")
	var shop = Control.new()
	shop.set_script(shop_scene)
	shop.process_mode = Node.PROCESS_MODE_WHEN_PAUSED  # Allow shop to work when paused
	add_child(shop)

	# Give player currency collected during round plus performance bonus
	var performance_bonus = 10 + (score1.text.to_int() * 5)
	shop.add_currency(player_currency + performance_bonus)

	# Connect shop closed signal
	shop.shop_closed.connect(close_shop_and_continue)

func close_shop_and_continue():
	get_tree().paused = false
	# Reset timer only when starting a new round after shop
	current_round_time = round_time
	start_round()

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

var attack_boost_active := false
var original_attack_force := 300.0
var attack_boost_timer := 0.0

func boost_attack(multiplier: float, duration: float):
	if player1:
		original_attack_force = player1.attack_force
		player1.attack_force *= multiplier
		attack_boost_active = true
		attack_boost_timer = duration

func game_over():
	game_state = "game_over"
	# AI gets a point when player runs out of lives
	ai_score += 1
	update_scoreboard()

	# Reset for next game
	player_lives = 3
	if lives_label:
		lives_label.text = "Lives: " + str(player_lives)

	# Restart immediately
	start_round()

func clear_traps():
	for spike in spikes:
		if is_instance_valid(spike):
			spike.queue_free()
	for trap in wall_traps:
		if is_instance_valid(trap):
			trap.queue_free()
	for coin in coins:
		if is_instance_valid(coin):
			coin.queue_free()
	spikes.clear()
	wall_traps.clear()
	coins.clear()

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

	# Currency label - next to lives
	currency_label = Label.new()
	currency_label.position = Vector2(200, 20)
	currency_label.text = "Coins: " + str(player_currency)
	currency_label.add_theme_color_override("font_color", Color.YELLOW)
	add_child(currency_label)


func update_scoreboard():
	if score1:
		score1.text = str(player_score)
	if score2:
		score2.text = str(ai_score)

func player_scored():
	player_score += 1
	update_scoreboard()

func ai_scored():
	ai_score += 1
	update_scoreboard()
