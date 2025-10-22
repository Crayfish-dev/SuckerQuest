extends CharacterBody2D
class_name PlayerController

@onready var damage_box: Area2D = $DamageOrbitatingPoint/DamageBox
@onready var damage_point: Node2D = $DamageOrbitatingPoint
@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var bite: AnimatedSprite2D = $DamageOrbitatingPoint/Bite
@onready var bite_sound: AudioStreamPlayer2D = $BiteSound1
@onready var hit_sound: AudioStreamPlayer2D = $HitSound
@onready var dash_sound: AudioStreamPlayer2D = $DashSound
@onready var step_sounds: AudioStreamPlayer2D = $StepSounds
@onready var bat_damage_area: Area2D = $BatDamageArea
@onready var transformation: AnimatedSprite2D = $Transformation
@onready var bat_sound: AudioStreamPlayer2D = $BatSound
@onready var bat_flap: AudioStreamPlayer2D = $BatFlap
@onready var music: AudioStreamPlayer2D = $Music

var bat: bool = false
var can_be_bat: bool = true
var max_speed: int = 90
var dead: bool = false
const acceleration: int = 10
const friction: int = 16
var dash_velocity := max_speed * 5
const ATTACK_BOOST_STRENGTH := 350
var can_parry: bool = true
var blood: int = 50
var can_dash: bool = true
var hp: int = 100
var immune: bool = false
var is_dashing: bool = false

var bat_time := 0.0
var max_bat_time := 5.0  
var bat_timer_active := false
var draining_bat_time := false

func _ready() -> void:
	damage_box.monitoring = false
	_start_blood_drain()

func _physics_process(delta: float) -> void:
	# Handle bat transformation input
	if Input.is_action_just_pressed("space") and can_be_bat and not bat:
		bat_sound.playing = true
		bat = true
		bat_timer_active = true
		draining_bat_time = false
		can_be_bat = false
	elif Input.is_action_just_pressed("space") and bat:
		if (bat_time / max_bat_time) * 100  >= 50:
			transformation.play("explode")
			damage_cloud()
		bat = false
		bat_timer_active = false
		draining_bat_time = true

	# Bat transformation speed
	max_speed = 160 if bat else 90

	# Healing with blood
	if blood >= 40 and hp < 100 and Input.is_action_pressed("heal"):
		velocity = Vector2.ZERO
		await get_tree().create_timer(0.1).timeout
		blood -= 1
		hp += 5
		return

	# Death check
	if hp <= 0:
		dead = true
		await get_tree().create_timer(1).timeout
		global_position = GameManager.get_checkpoint()
		dead = false
		blood = 50
		hp = 100

	# Movement input
	var input = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()

	# Sprite animation logic
	if not dead:
		if not bat:
			if input.length() > 0:
				if input.y >= 0:
					sprite.play("front_walk")
				else:
					sprite.play("back_walk")
			else:
				# Play idle based on last vertical velocity direction
				if velocity.y < 0:
					sprite.play("back_idle")
				else:
					sprite.play("front_idle")
		else:
			sprite.play("bat_fly") if velocity.length() > 0 else sprite.play("bat_idle")
	else:
		sprite.play("death")

	# Blood and HP bounds
	blood = clamp(blood, 0, 100)
	if blood == 0:
		hp = 0

	# Attack logic
	if Input.is_action_just_pressed("attack") and blood >= 10 and not immune and not bat:
		attack(8)

	# Look direction
	damage_point.look_at(get_global_mouse_position())

	# Movement physics
	var lerp_weight = delta * (acceleration if input else friction)
	velocity = lerp(velocity, input * max_speed, lerp_weight)

	var direction = Input.get_action_strength("right") - Input.get_action_strength("left")
	var ydirection = Input.get_action_strength("down") - Input.get_action_strength("up")

	# Dashing
	if Input.is_action_just_pressed("dash") and can_dash and not bat:
		var random_pitch = randf_range(0.5, 2)
		dash_sound.pitch_scale = random_pitch
		dash_sound.playing = true
		velocity.x = dash_velocity * direction
		velocity.y = dash_velocity * ydirection
		can_dash = false
		is_dashing = true
		_stop_step_sounds()
		await get_tree().create_timer(1).timeout
		can_dash = true
		is_dashing = false

	move_and_slide()

	# Step sounds
	if input.length() > 0 and not is_dashing and not step_sounds.playing:
		_play_step_sounds()
	elif (input.length() == 0 or is_dashing) and step_sounds.playing:
		_stop_step_sounds()

	if bat_timer_active:
		bat_time += delta
		if bat_time >= max_bat_time:
			bat_time = max_bat_time
			damage_cloud()
			transformation.play("explode")
			bat = false
			bat_timer_active = false
			draining_bat_time = true
	elif draining_bat_time and not bat:
		bat_time -= delta
		if bat_time <= 0.0:
			bat_time = 0.0
			draining_bat_time = false
			can_be_bat = true

func _on_damage_box_body_entered(body: Enemy) -> void:
	if body.immune:
		return
	blood += 20
	body.take_damage(10)
	var knockback_direction = (body.global_position - global_position).normalized()
	var knockback_strength = 250
	var knockback_velocity = knockback_direction * knockback_strength
	var player_knockback_strength = 400
	var player_knockback = -knockback_direction * player_knockback_strength
	velocity += player_knockback

func _start_blood_drain() -> void:
	while true:
		await get_tree().create_timer(2).timeout
		blood = max(blood - 1, 0) 

func take_damage(dm: int):
	if immune:
		return
	hit_sound.playing = true
	hp -= dm
	immune = true
	sprite.modulate = Color(255, 0, 0)
	await get_tree().create_timer(0.5).timeout
	immune = false
	sprite.modulate = Color(1, 1, 1)

func apply_knockback(velocity: Vector2) -> void:
	self.velocity = velocity

func _on_bite_animation_finished() -> void:
	bite.visible = false

func attack(bl):
	var bite_sound_array = [
		"res://assets/sounds/bite (1).mp3",
		"res://assets/sounds/bite_2.mp3",
		"res://assets/sounds/bite_3.mp3"
	]
	var sound_path = bite_sound_array[randi() % bite_sound_array.size()]
	bite_sound.stream = load(sound_path)  
	bite_sound.playing = true
	blood -= bl
	damage_box.monitoring = true
	bite.visible = true
	bite.play("bite")
	var direction_to_mouse = (get_global_mouse_position() - global_position).normalized()
	velocity += direction_to_mouse * ATTACK_BOOST_STRENGTH
	if sprite.animation == "front_walk" or sprite.animation == "front_idle":
		sprite.play("bite")
	await get_tree().create_timer(0.2).timeout
	sprite.play("front_idle")
	damage_box.monitoring = false

func _play_step_sounds():
	step_sounds.pitch_scale = randf_range(0.8, 1.2)
	bat_flap.pitch_scale = randf_range(0.8, 1.2)
	
	if bat:
		bat_flap.playing = true
	else:
		step_sounds.playing = true
	

func _stop_step_sounds():
	if bat:
		bat_flap.playing = false
	else:
		step_sounds.playing = false

func can_be_bat_timer():
	await get_tree().create_timer(1).timeout
	can_be_bat = true

func _on_bat_damage_area_body_entered(body: Enemy) -> void:
	if body.name == "Ghost":
		return
	if body.name == "Boss":
			body.take_damage(30)
	blood += 40
	var knockback_direction = (body.global_position - global_position).normalized()
	var knockback_strength = 250
	var knockback_velocity = knockback_direction * knockback_strength
	var player_knockback_strength = 400
	var player_knockback = -knockback_direction * player_knockback_strength
	velocity += player_knockback
	body.take_damage(70)
	blood += 20
	velocity += player_knockback

func damage_cloud():
	bat_damage_area.monitoring = true
	await get_tree().create_timer(0.2).timeout
	bat_damage_area.monitoring = false
