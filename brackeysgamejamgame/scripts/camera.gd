extends Camera2D

@export var player: PlayerController 
@export var blood_bar: TextureProgressBar
@export var health_bar: TextureProgressBar
@export var bat_bar: TextureProgressBar 
@export var animation: AnimationPlayer 
@export var boss: CharacterBody2D 

@export var there_is_a_boss : bool = true

func _process(delta: float) -> void:
	if !boss and there_is_a_boss:
		animation.play("enter")
	if player:
		position = player.position
		health_bar.value = player.hp
		blood_bar.value = player.blood
		bat_bar.value = (player.bat_time / player.max_bat_time) * 100

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "enter":
		get_tree().change_scene_to_file("res://scenes/win_screen.tscn")
