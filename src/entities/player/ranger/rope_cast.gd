extends RayCast2D

signal collided(body)

var previous_collision: Object = null

func _physics_process(delta: float) -> void:
	if is_enabled() and is_colliding():
		var current_collision = get_collider()
		emit_signal("collided", current_collision)
		previous_collision = current_collision
	else:
		previous_collision = null
