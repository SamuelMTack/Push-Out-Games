extends StaticBody2D

var player_in_range: bool = false

func _ready():
	$InteractArea.body_entered.connect(_on_interact_area_body_entered)
	$InteractArea.body_exited.connect(_on_interact_area_body_exited)

func _process(delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		if GameManager.extend_time():
			print("Time Extended!")
			# Visual feedback
			var tween = create_tween()
			tween.tween_property($ColorRect, "scale", Vector2(1.2, 1.2), 0.1)
			tween.tween_property($ColorRect, "scale", Vector2(1.0, 1.0), 0.1)
		else:
			print("Not enough gold!")

func _on_interact_area_body_entered(body):
	if body.is_in_group("Player"):
		player_in_range = true
		$Label.visible = true
		$Label.text = "Cost: " + str(GameManager.extension_cost) + "G\nPress E"

func _on_interact_area_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range = false
		$Label.visible = false
