extends Enemy

@onready var pivot: Node2D = $Pivot
@onready var shape: Area2D = $Pivot/DamageShape
@onready var detector: Area2D = $Detector
@onready var arrow: AnimatedSprite2D = $Pivot/arrow
@onready var emotion: AnimatedSprite2D = $EmotionPoint

# Movement behavior
var move_speed: float = 60.0
var min_distance: float = 60.0  # too close, move away
var max_distance: float = 160.0  # too far, move closer

func _physics_process(delta: float) -> void:

	if velocity.length() > 0:
		sprite.play("walk")
	else:
		sprite.play("idle")
	
	# Flip sprite based on movement direction (inverted: flip when moving right)
	if abs(velocity.x) > 5:
		sprite.flip_h = velocity.x > 0

	if hp <= 0 or hp == 0:
		sprite.play("die")
		await get_tree().create_timer(1).timeout
		queue_free()
	
	if is_chasing and player and not immune:
		var distance_to_player = global_position.distance_to(player.global_position)
		var direction = (player.global_position - global_position).normalized()

		if distance_to_player < min_distance:
			# Too close — back away
			velocity = -direction * move_speed
		elif distance_to_player > max_distance:
			# Too far — move closer
			velocity = direction * move_speed
		else:
			# Ideal range — don't steer
			pass
	else:
		# Don't steer; immune or not chasing — retain existing velocity
		pass

	move_and_slide()

func _process(delta: float) -> void:
	if player:
		pivot.look_at(player.position)

func _on_damage_shape_body_entered(body: PlayerController) -> void:
	if body.bat:
		return
	body.take_damage(damage)
	var knockback_direction = (body.global_position - global_position).normalized()
	var knockback_strength = 1000
	var knockback_velocity = knockback_direction * knockback_strength
	body.apply_knockback(knockback_velocity)

	# Enemy gets pushed slightly (if needed)
	var player_knockback_strength = 0
	var player_knockback = -knockback_direction * player_knockback_strength
	velocity += player_knockback

func _on_detector_body_entered(body: PlayerController) -> void:
	if body.bat:
		return
	await get_tree().create_timer(0.8).timeout
	shape.monitoring = true
	arrow.visible = true
	arrow.play("shoot")
	await get_tree().create_timer(0.1).timeout
	shape.monitoring = false

func _on_arrow_animation_finished() -> void:
	arrow.visible = false

func _on_chasing_area_body_entered(body: PlayerController) -> void:
	if body.bat:
		return
	emotion.play("exclamation")
	is_chasing = true

func _on_chasing_area_body_exited(body: PlayerController) -> void:
	if body.bat:
		return
	emotion.play("wonder")
	is_chasing = false
