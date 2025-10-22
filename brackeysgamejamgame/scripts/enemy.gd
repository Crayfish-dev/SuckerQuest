extends CharacterBody2D
class_name Enemy

@export var player: PlayerController
@export var damage: int = 10.0
@export var sprite: Node2D
@export var hp: int = 100.0

var is_chasing: bool = false
var immune: bool = false
var deceleration: float = 1000.0  # Lower = slower stop, tweak as needed

func _physics_process(delta: float) -> void:
	if hp <= 0 or hp == 0:
		sprite.play("die")
		await get_tree().create_timer(1).timeout
		queue_free()

	
	# Just apply deceleration to stop smoothly
	velocity = lerp(velocity, Vector2.ZERO, delta * deceleration)

	move_and_slide()

func take_damage(dm: int):
	if immune:
		return
	is_chasing = false
	hp -= dm
	immune = true
	sprite.modulate = Color(255, 0, 0)
	await get_tree().create_timer(0.5).timeout
	is_chasing = true
	immune = false
	sprite.modulate = Color(1, 1, 1)

func apply_knockback(velocity: Vector2) -> void:
	self.velocity = velocity
