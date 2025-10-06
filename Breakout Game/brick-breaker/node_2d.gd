extends Node2D

# Game variables
var score = 0
var lives = 3
var ball_speed = 300
var paddle_speed = 400

# Node references
var paddle
var ball
var bricks_container
var score_label
var lives_label

# Ball velocity
var ball_velocity = Vector2.ZERO

# Screen dimensions
var screen_size

func _ready():
	screen_size = get_viewport_rect().size
	setup_game()

func setup_game():
	# Create paddle
	paddle = ColorRect.new()
	paddle.size = Vector2(100, 20)
	paddle.color = Color.BLUE
	paddle.position = Vector2(screen_size.x / 2 - 50, screen_size.y - 50)
	add_child(paddle)
	
	# Create ball
	ball = ColorRect.new()
	ball.size = Vector2(15, 15)
	ball.color = Color.WHITE
	ball.position = Vector2(screen_size.x / 2, screen_size.y - 100)
	add_child(ball)
	
	# Initialize ball velocity
	ball_velocity = Vector2(1, -1).normalized() * ball_speed
	
	# Create bricks container
	bricks_container = Node2D.new()
	add_child(bricks_container)
	
	# Create bricks
	create_bricks()
	
	# Create UI
	score_label = Label.new()
	score_label.position = Vector2(10, 10)
	score_label.text = "Score: 0"
	score_label.add_theme_font_size_override("font_size", 24)
	add_child(score_label)
	
	lives_label = Label.new()
	lives_label.position = Vector2(screen_size.x - 150, 10)
	lives_label.text = "Lives: 3"
	lives_label.add_theme_font_size_override("font_size", 24)
	add_child(lives_label)

func create_bricks():
	var brick_width = 60
	var brick_height = 20
	var brick_padding = 5
	var rows = 5
	var cols = 10
	var start_x = (screen_size.x - (cols * (brick_width + brick_padding))) / 2
	var start_y = 80
	
	var colors = [Color.RED, Color.ORANGE, Color.YELLOW, Color.GREEN, Color.CYAN]
	
	for row in range(rows):
		for col in range(cols):
			var brick = ColorRect.new()
			brick.size = Vector2(brick_width, brick_height)
			brick.color = colors[row]
			brick.position = Vector2(
				start_x + col * (brick_width + brick_padding),
				start_y + row * (brick_height + brick_padding)
			)
			brick.set_meta("is_brick", true)
			bricks_container.add_child(brick)

func _process(delta):
	# Move paddle
	if Input.is_action_pressed("ui_left"):
		paddle.position.x -= paddle_speed * delta
	if Input.is_action_pressed("ui_right"):
		paddle.position.x += paddle_speed * delta
	
	# Keep paddle on screen
	paddle.position.x = clamp(paddle.position.x, 0, screen_size.x - paddle.size.x)
	
	# Move ball
	ball.position += ball_velocity * delta
	
	# Ball collision with walls
	if ball.position.x <= 0 or ball.position.x >= screen_size.x - ball.size.x:
		ball_velocity.x = -ball_velocity.x
	
	if ball.position.y <= 0:
		ball_velocity.y = -ball_velocity.y
	
	# Ball falls below paddle (lose life)
	if ball.position.y > screen_size.y:
		lose_life()
	
	# Ball collision with paddle
	var ball_rect = Rect2(ball.position, ball.size)
	var paddle_rect = Rect2(paddle.position, paddle.size)
	
	if ball_rect.intersects(paddle_rect) and ball_velocity.y > 0:
		ball_velocity.y = -ball_velocity.y
		# Add some horizontal velocity based on where the ball hits the paddle
		var hit_pos = (ball.position.x - paddle.position.x) / paddle.size.x
		ball_velocity.x = (hit_pos - 0.5) * ball_speed * 1.5
		ball_velocity = ball_velocity.normalized() * ball_speed
	
	# Ball collision with bricks
	for brick in bricks_container.get_children():
		var brick_rect = Rect2(brick.position, brick.size)
		if ball_rect.intersects(brick_rect):
			# Remove the brick and bounce the ball
			brick.queue_free()
			ball_velocity.y = -ball_velocity.y
			score += 10
			score_label.text = "Score: " + str(score)
			
			# Check win condition
			# If there are no bricks left, player wins
			if bricks_container.get_child_count() == 0:
				win_game()
			break

func lose_life():
	lives -= 1
	lives_label.text = "Lives: " + str(lives)
	
	if lives > 0:
		# Reset ball position
		ball.position = Vector2(screen_size.x / 2, screen_size.y - 100)
		ball_velocity = Vector2(1, -1).normalized() * ball_speed
	else:
		game_over()

func game_over():
	ball_velocity = Vector2.ZERO
	var game_over_label = Label.new()
	game_over_label.text = "GAME OVER\nPress ESC to Restart"
	game_over_label.position = Vector2(screen_size.x / 2 - 100, screen_size.y / 2)
	game_over_label.add_theme_font_size_override("font_size", 32)
	add_child(game_over_label)
	set_process(false)

func win_game():
	ball_velocity = Vector2.ZERO
	var win_label = Label.new()
	win_label.text = "YOU WIN!\nPress ESC to Restart"
	win_label.position = Vector2(screen_size.x / 2 - 100, screen_size.y / 2)
	win_label.add_theme_font_size_override("font_size", 32)
	add_child(win_label)
	set_process(false)

func _input(event):
	# Reload scene when the user presses the UI cancel action (typically Escape)
	if event.is_action_pressed("ui_cancel"):
		get_tree().reload_current_scene()