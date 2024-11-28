extends Camera3D

@export var target: Node2D  # Referencia al personaje

func _process(delta: float):
	if target:
		global_transform.origin.x = target.global_position.x
		global_transform.origin.y = target.global_position.y
