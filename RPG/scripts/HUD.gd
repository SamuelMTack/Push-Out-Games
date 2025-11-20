extends Control

func _ready():
	GameManager.timer_updated.connect(_on_timer_updated)
	GameManager.gold_updated.connect(_on_gold_updated)
	GameManager.level_updated.connect(_on_level_updated)
	GameManager.game_over.connect(_on_game_over)

func _on_timer_updated(time_left):
	$TimerLabel.text = "%.2f" % time_left
	if time_left < 5.0:
		$TimerLabel.modulate = Color(1, 0, 0, 1)
	else:
		$TimerLabel.modulate = Color(1, 1, 1, 1)

func _on_gold_updated(current_gold):
	$GoldLabel.text = "Gold: " + str(current_gold)

func _on_level_updated(current_level):
	$LevelLabel.text = "Level: " + str(current_level)

func _on_game_over():
	$GameOverLabel.visible = true
