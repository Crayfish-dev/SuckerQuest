extends Node

var last_checkpoint_position: Vector2 = Vector2.ZERO


func set_checkpoint(pos: Vector2):
	last_checkpoint_position = pos

func get_checkpoint():
	return last_checkpoint_position
