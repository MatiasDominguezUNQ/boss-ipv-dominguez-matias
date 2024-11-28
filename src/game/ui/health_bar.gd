extends ProgressBar

@export var player: PhysicsBody2D

func _ready() -> void:
	update(player.health, player.max_health)

func update(val, max_val):
	if val == max_val:
		hide()
	else:
		show()
	value = val * 100 / max_val
