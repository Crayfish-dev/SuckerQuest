extends Node2D
class_name EnemyAttackController

# enemy's reaction time, in seconds
@export var attack_speed : float = 0.5
# The damage the enemy will do
@export var damage : int 
# Needed at the center of the enemy, the rest isn't important (needs to be a Node2D)
@export var pivot : Node2D
# Enemy's area that does damage to the player
@export var damage_shape: Area2D 
# Enemy's area that detects if player is near enough to attack
@export var player_detector: Area2D 
# Enemy bite sprite
@export var bite_animation: AnimatedSprite2D 
# Enemy parent
@export var body : Enemy
# Needed to attack
@export var ai_conponent : EnemySimpleAI

# connects the proper signals to the proper nodes ( es when the bite animation finishes the animation )
func _ready() -> void:
	damage_shape.body_entered.connect(damage_shape_body_entered)
	bite_animation.animation_finished.connect(bite_animation_finished)
	player_detector.body_entered.connect(detector_body_entered)

func _process(delta: float) -> void:
	# rotates the pivot and his children ( damage area!) in the direction of the player
	if body.player:
		pivot.look_at(body.player.position)

# if player detected, remove some damage and some knockback code that dosen't do absolutelly nothing at all
func damage_shape_body_entered(body: PlayerController) -> void:
	if body.bat:
		return
	body.take_damage(damage)
	
	# Knockback applied to the player
	var knockback_direction = (body.global_position - global_position).normalized()
	var knockback_strength = 250
	var knockback_velocity_player = knockback_direction * knockback_strength
	body.apply_knockback(knockback_velocity_player)

	var player_knockback_strength = 400
	var player_knockback = -knockback_direction * player_knockback_strength


# "if enemy see, enemy destroy" -Crayfish.dev 
func detector_body_entered(body: PlayerController) -> void:
	if body.bat:
		return
	await get_tree().create_timer(attack_speed).timeout
	damage_shape.monitoring = true
	bite_animation.visible = true
	bite_animation.play("bite")
	await get_tree().create_timer(0.1).timeout
	damage_shape.monitoring = false

 # finish animation, it becomes invisible 
func bite_animation_finished() -> void:
	bite_animation.visible = false
