extends CharacterBody2D

@export var speed: float = 300.0
@export var attack_damage: int = 10
@export var attack_cooldown: float = 0.5

var can_attack: bool = true

func _ready():
	add_to_group("Player")

func _physics_process(delta):
	if not GameManager.is_game_active:
		return

	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * speed
	move_and_slide()

	if Input.is_action_just_pressed("attack") and can_attack:
		attack()

func attack():
	can_attack = false
	# Visual feedback for attack (e.g., flash color)
	var original_color = $ColorRect.color
	$ColorRect.color = Color.WHITE
	
	var bodies = $AttackArea.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Enemy"):
			body.take_damage(attack_damage)
	
	await get_tree().create_timer(0.1).timeout
	$ColorRect.color = original_color
	
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
