extends StaticBody2D

@export var key: Key
var can_be_opened: bool = false
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var opening_area: Area2D = $OpeningArea
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _process(delta: float) -> void:
	

	if key:
		can_be_opened = false
	else:
		can_be_opened = true


func _on_opening_area_body_entered(body: PlayerController) -> void:
	if can_be_opened:
		audio.play()
		sprite.play("open")


func _on_animated_sprite_2d_animation_finished() -> void:
	if can_be_opened:
		queue_free()
