extends Area2D
class_name Key



func _on_body_entered(body: PlayerController) -> void:
	queue_free()
