extends Node2D


# yay you winnnnn
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("space"):
		get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
