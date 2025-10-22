extends TextureProgressBar

@export var enemy: Enemy
@onready var bar: TextureProgressBar = $"."

# just a simple health bar
func _process(delta: float) -> void:
	if enemy:
		bar.value = enemy.hp
	else:
		return
