extends CharacterBody2D

@export var speed: float = 150.0
@export var hp: int = 30
@export var damage: int = 5
@export var gold_drop: int = 5
@export var xp_drop: int = 20

var target: Node2D = null

func _ready():
	add_to_group("Enemy")
	$AggroArea.body_entered.connect(_on_aggro_area_body_entered)
	$AggroArea.body_exited.connect(_on_aggro_area_body_exited)

func _physics_process(delta):
	if not GameManager.is_game_active:
		return

	if target:
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
		
		# Simple collision damage to player
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider.is_in_group("Player"):
				# In a real game, add cooldown or knockback
				pass

func take_damage(amount: int):
	hp -= amount
	# Flash white
	$ColorRect.color = Color.WHITE
	await get_tree().create_timer(0.1).timeout
	$ColorRect.color = Color(0.8, 0.2, 0.2, 1)
	
	if hp <= 0:
		die()

func die():
	GameManager.add_gold(gold_drop)
	GameManager.add_xp(xp_drop)
	queue_free()

func _on_aggro_area_body_entered(body):
	if body.is_in_group("Player"):
		target = body

func _on_aggro_area_body_exited(body):
	if body == target:
		target = null
