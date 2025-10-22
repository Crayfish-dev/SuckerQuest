extends Enemy

@onready var bite: AnimatedSprite2D = $Pivot/Slash
@onready var emotion: AnimatedSprite2D = $EmotionPoint
@onready var shape: Area2D = $DamageArea
@onready var pivot: Node2D = $Pivot

# Chasing behavior
var move_speed: float = 80.0
var target_position: Vector2
var target_reached_threshold: float = 20.0
var reposition_interval: float = 2.5
var reposition_timer: float = 0.0
var shielding: bool = false

# Knockback velocity and friction
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_friction: float = 10000000000000000000.0  # Adjust this to control how fast knockback slows

func _physics_process(delta: float) -> void:
	pivot.look_at(player.position)

	if hp <= 0 or hp == 0:
		sprite.play("die")
		await get_tree().create_timer(1).timeout
		queue_free()

	var move_velocity = Vector2.ZERO

	if is_chasing and player:
		reposition_timer -= delta

		if reposition_timer <= 0.0 or global_position.distance_to(target_position) < target_reached_threshold:
			target_position = get_random_position_near_player()
			reposition_timer = reposition_interval

		var direction = (target_position - global_position).normalized()
		move_velocity = direction * move_speed
	else:
		move_velocity = Vector2.ZERO

	# Apply friction to knockback velocity
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)

	velocity = move_velocity + knockback_velocity
	move_and_slide()

	# Inverted horizontal flipping
	if abs(velocity.x) > 5:
		sprite.flip_h = velocity.x > 0

	# Animation logic
	if shielding:
		immune = true
		if velocity.length() > 0:
			sprite.play("shield_walk")
		else:
			sprite.play("shield")
	else:
		if velocity.length() > 0:
			sprite.play("walk")
		else:
			sprite.play("idle")

func get_random_position_near_player(radius: float = 100.0) -> Vector2:
	var angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * randf_range(30, radius)
	return player.global_position + offset

func _on_detector_body_entered(body: PlayerController) -> void:
	if body.bat:
		return
	var decision_array = [
		"shield",
		"attack"
	]
	var decision = decision_array[randi() % decision_array.size()] 
	if decision == "attack":
		await get_tree().create_timer(0.2).timeout
		shape.monitoring = true
		bite.visible = true
		bite.play("bite")
		sprite.play("attack")
		await get_tree().create_timer(0.1).timeout
		shape.monitoring = false
		await get_tree().create_timer(0.2).timeout
		shielding = true
	elif decision == "shield":
		await get_tree().create_timer(0.1).timeout
		shielding = true

func _on_bite_animation_finished() -> void:
	bite.visible = false

func _on_chasing_area_body_entered(body: PlayerController) -> void:
	if body.bat:
		return
	emotion.play("exclamation")
	is_chasing = true
	target_position = get_random_position_near_player()
	reposition_timer = 0.0

func _on_chasing_area_body_exited(body: PlayerController) -> void:
	if body.bat:
		return
	emotion.play("wonder")
	is_chasing = false

func _on_damage_area_body_entered(body: PlayerController) -> void:
	if body.bat:
		return
	sprite.play("attack")
	body.take_damage(damage)

	# Knockback to player
	var knockback_direction = (body.global_position - global_position).normalized()
	var knockback_strength = 250
	var knockback_velocity_player = knockback_direction * knockback_strength
	body.apply_knockback(knockback_velocity_player)

	var player_knockback_strength = 400
	var player_knockback = -knockback_direction * player_knockback_strength
	knockback_velocity += player_knockback

func _on_detector_body_exited(body: PlayerController) -> void:
	shielding = false
	immune = false
