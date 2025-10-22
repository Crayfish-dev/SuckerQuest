extends StaticBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var claimed: bool = false
@onready var opening: AudioStreamPlayer2D = $Opening
@onready var music: AudioStreamPlayer2D = $Music

func _on_detector_body_entered(body: PlayerController) -> void:
	GameManager.set_checkpoint(position)
	if !claimed:
		opening.playing = true
		music.playing = true
	claimed = true
func _process(delta: float) -> void:
	if GameManager.last_checkpoint_position == position:
		claimed = true
	else:
		claimed = false
	
	if claimed:
		sprite.play("opened")
	else:
		sprite.play("closed")
