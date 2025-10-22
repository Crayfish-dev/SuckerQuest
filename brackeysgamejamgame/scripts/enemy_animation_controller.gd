extends Node2D
class_name EnemyAnimationController

# the enemy 
@export var body : Enemy

func _process(delta: float) -> void:
	# die animation, creates timer and deletes node
	if body.hp <= 0 or body.hp == 0:
		body.sprite.play("die")
		await get_tree().create_timer(1).timeout
		body.queue_free()

	# Sprite Animation and Flipping and bla bla bla ( thanks chatGBT)
	if body.sprite:
		# Flip horizontally based on X movement direction
		if abs(body.velocity.x) > 5:
			body.sprite.flip_h = body.velocity.x > 0  
		# to make this work you need at least a die animation, a back and front idle and a back and front walk
		if body.velocity.length() < 10:
			if abs(body.velocity.y) > abs(body.velocity.x):
				if body.velocity.y < 0:
					body.sprite.play("back_idle")
				else:
					body.sprite.play("front_idle")
			else:
				body.sprite.play("front_idle")
		else:
			if abs(body.velocity.y) > abs(body.velocity.x):
				if body.velocity.y < 0:
					body.sprite.play("back_walk")
				else:
					body.sprite.play("front_walk")
			else:
				body.sprite.play("front_walk")

# i wanted to make just two direction for tim purposes and becouse im lazy, feel free to chage that if you want to
