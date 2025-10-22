extends Enemy

@export var emotion: AnimatedSprite2D 


func _physics_process(delta: float) -> void:
	move_and_slide()
