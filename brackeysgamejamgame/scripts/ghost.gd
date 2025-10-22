extends Enemy

@onready var heal: Sprite2D = $Heal
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var angel: Sprite2D = $Angel
@onready var detector: Area2D = $Detector
@onready var chasing_area: Area2D = $ChasingArea
@onready var heal_sound: AudioStreamPlayer2D = $HealSound
@export var healing = 10.0
@export var target: Node2D
var move_speed: float = 80.0
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_friction: float = 100000.0
var max_hp: int = 0.0
var side_offset: float = 60.0
var side_direction: int = 1 
var switch_timer: float = 0.0
var switch_interval: float = 1

func _ready() -> void:
	if target:
		max_hp = target.hp
	else:
		return

func _physics_process(delta: float) -> void:
	
	if !target:
		queue_free()
	
	if hp <= 0:
		queue_free()
	
	is_chasing = true
	var move_velocity = Vector2.ZERO

	if is_chasing and target:
		switch_timer -= delta
		if switch_timer <= 0:
			side_direction *= -1  # Flip side
			switch_timer = switch_interval + randf_range(0.5, 1.5)

		var desired_position = target.global_position + Vector2(side_offset * side_direction, 0)
		var direction = (desired_position - global_position).normalized()
		move_velocity = direction * move_speed

		angel.visible = true
		angel.global_position = target.global_position
	else:
		angel.visible = false

	# Apply knockback
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)

	# Final velocity
	velocity = move_velocity + knockback_velocity
	move_and_slide()


func _on_detector_body_entered(body: Enemy ) -> void:
	if body == target and body.hp < max_hp:
		heal_sound.playing = true
		sprite.modulate = Color(104 / 255.0, 56 / 255.0, 108 / 255.0)
		animation.play("enter")
		body.sprite.modulate = Color(104 / 255.0, 56 / 255.0, 108 / 255.0)
		body.hp += healing
		await get_tree().create_timer(1.0).timeout

		sprite.modulate = Color(1, 1, 1)
		body.sprite.modulate = Color(1, 1, 1)
