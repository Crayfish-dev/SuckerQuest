extends Node2D

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var buttons: AnimatedSprite2D = $AnimatedSprite2D
var play: bool = false
var exit: bool = false
var exited = false
func _process(delta: float) -> void:

	if Input.is_action_just_pressed("attack"):
		if exit and exited == false:
			animation.play("esc")
			get_tree().quit()
			exited = true
		if play:
			await get_tree().create_timer(0.1).timeout
			get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_play_mouse_entered() -> void:
	buttons.play("play")
	play = true
	exit = false
func _on_play_mouse_exited() -> void:
	play = false


func _on_exit_mouse_entered() -> void:
	buttons.play("exit")
	exit = true
	play = false

func _on_exit_mouse_exited() -> void:
	exit = false
