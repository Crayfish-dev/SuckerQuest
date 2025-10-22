extends Node2D
class_name EnemySimpleAI

@export var body : Enemy
@export var player_detection_area : Area2D
# Chasing behavior
var move_speed: float = 70.0
var target_position: Vector2
var target_reached_threshold: float = 15.0
var reposition_interval: float = 2
var reposition_timer: float = 0.0

# connect the signals to their nodes
func _ready() -> void:
	player_detection_area.body_entered.connect(body_entered)
	player_detection_area.body_exited.connect(body_exited)

# move in the direction of a random position near the target ( thanks chatGBT ) * note : i just used chatGBT twice in this game 
func _physics_process(delta: float) -> void:
	var move_velocity = Vector2.ZERO

	if body.is_chasing and body.player:
		reposition_timer -= delta

		if reposition_timer <= 0.0 or body.global_position.distance_to(target_position) < target_reached_threshold:
			target_position = get_random_position_near_player()
			reposition_timer = reposition_interval

		var direction = (target_position - global_position).normalized()
		move_velocity = direction * move_speed
	else:
		move_velocity = Vector2.ZERO


	body.velocity = move_velocity 

# if you see the player, get exited and go towards it
func body_entered(bod : PlayerController):
	if bod.bat:
		return
	if body.emotion:
		body.emotion.play("exclamation")
	body.is_chasing = true
	target_position = get_random_position_near_player()
	reposition_timer = 0.0

# if you don't see the player, get confused and stop like a stupid NPC
func body_exited( bod : PlayerController):
	if bod.bat:
		return
	if body.emotion:
		body.emotion.play("wonder")
	body.is_chasing = false

# see player, go near him ( give him a hug if you want before it murders you brutally) (thanks chatGBT, again... maybe i used it more than twice...)
func get_random_position_near_player(radius: float = 100.0) -> Vector2:
	var angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * randf_range(30, radius)
	return body.player.global_position + offset
