extends Enemy

@onready var shape: Area2D = $DamageArea
@onready var pivot: Node2D = $Pivot
@onready var bite: AnimatedSprite2D = $Pivot/Bite
@onready var light: AnimatedSprite2D = $Light
@onready var music: AudioStreamPlayer2D = $Music
@onready var lightning: AudioStreamPlayer2D = $LIghtning
@onready var circle: Node2D = $Circle
@onready var cross: Sprite2D = $Circle/Cross
@onready var area_cross: Area2D = $Circle/AreaCross

# Chasing behavior
var move_speed: float = 80.0
var target_position: Vector2
var target_reached_threshold: float = 20.0
var reposition_interval: float = 2.5
var reposition_timer: float = 0.0

# Knockback velocity and friction
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_friction: float = 1e20  # Very high friction

func _physics_process(delta: float) -> void:
	
	if hp < 100 and is_chasing:
		cross.visible = true
		area_cross.monitoring = true
		cross.rotation += 0.05
	elif  hp < 50 and is_chasing:
		circle.scale.x = 0.6
		circle.scale.y = 0.6
	
	if Input.is_action_just_pressed("escape"):
		get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
	
	
	if velocity.length() < 10:
		if abs(velocity.y) > abs(velocity.x):
			if velocity.y < 0:
				sprite.play("back_idle")
			else:
				sprite.play("front_idle")
		else:
			sprite.play("front_idle")
	else:
		if abs(velocity.y) > abs(velocity.x):
			if velocity.y < 0:
				sprite.play("back_walk")
			else:
				sprite.play("front_walk")
		else:
			sprite.play("front_walk")

	pivot.look_at(player.position)

	if hp <= 0 or hp == 0:
		sprite.play("die")
		area_cross.monitoring = false
		cross.visible = false
		if music.volume_db != 0:
			music.volume_db -= 0.05
		await get_tree().create_timer(2).timeout
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


func get_random_position_near_player(radius: float = 100.0) -> Vector2:
	var angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * randf_range(30, radius)
	return player.global_position + offset

func _on_detector_body_entered(body: PlayerController) -> void:

	var decision_array = [
		"light",
		"attack",
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

	elif decision == "light":
		# Update position and visibility for light sprite
		light.global_position = player.global_position
		sprite.play("light")
		lightning.playing = true
		light.visible = true
		light.modulate = Color(1, 1, 1, 1)  # Fully visible
		light.z_index = 10  # Bring in front
		light.play("light")

		player.take_damage(30)

		# Optional: hide after animation finishes
		await get_tree().create_timer(1.0).timeout
		light.visible = false

func _on_bite_animation_finished() -> void:
	bite.visible = false

func _on_chasing_area_body_entered(body: PlayerController) -> void:
	music.playing = true
	player.music.playing = false
	is_chasing = true
	target_position = get_random_position_near_player()
	reposition_timer = 0.0

func _on_chasing_area_body_exited(body: PlayerController) -> void:
	is_chasing = false
	area_cross.monitoring = false
	cross.visible = false

func _on_damage_area_body_entered(body: PlayerController) -> void:
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
	immune = false


func _on_area_cross_body_entered(body: PlayerController) -> void:
	if hp < 100:
		body.take_damage(60)
	area_cross.monitoring = false
	await get_tree().create_timer(0.2).timeout
	area_cross.monitoring = true
