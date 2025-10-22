extends Area2D
func _on_body_entered(body: PlayerController) -> void:
	body.blood += 25
	queue_free()
