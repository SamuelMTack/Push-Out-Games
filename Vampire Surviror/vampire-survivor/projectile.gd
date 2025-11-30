extends Area2D

var direction = Vector2.ZERO
var speed = 300.0
var damage = 15.0
var lifetime = 4.0
var pierce_count = 1  # How many enemies it can hit
var hits_remaining = 1  # Remaining hits before destruction
var crit_chance = 0.0
var crit_multiplier = 2.0

func _ready():
	body_entered.connect(_on_body_entered)

func setup(dir: Vector2, spd: float, dmg: float, crit_c: float = 0.0, crit_m: float = 2.0):
	direction = dir
	speed = spd
	damage = dmg
	crit_chance = crit_c
	crit_multiplier = crit_m
#	pierce_count = pierce
#	hits_remaining = pierce
	
	# Scale the projectile visual
#	scale = Vector2(size_scale, size_scale)
	
	# Destroy after lifetime
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.has_method("take_damage"):
		var final_damage = damage
		var is_crit = false
		
		# Roll for crit
		if randf() < crit_chance:
			final_damage *= crit_multiplier
			is_crit = true
			
		body.take_damage(final_damage)
		
		# Show crit indicator if available (optional, requires damage number system update)
		if is_crit:
			# If we had a way to show text, we'd show it here. 
			# For now, maybe just print or rely on the bigger number killing faster.
			pass
		
		# Reduce remaining hits
		hits_remaining -= 1
		
		# Only destroy if no hits remaining
		if hits_remaining <= 0:
			queue_free()
