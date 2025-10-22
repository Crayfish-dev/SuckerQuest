extends StaticBody2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
func _on_opening_area_body_entered(body: PlayerController) -> void:
		sprite.play("open")
func _on_animated_sprite_2d_animation_finished() -> void:
	collision.disabled = true
	queue_free()
