extends Key
func _on_body_entered(body: PlayerController) -> void:
	queue_free()
