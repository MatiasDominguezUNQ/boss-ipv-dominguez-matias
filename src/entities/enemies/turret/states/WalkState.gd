extends AbstractEnemyState

@export var pathfinding_step_threshold: float = 5.0
var path: Array = []

func enter():
	if character.pathfinding != null: 
		var random_target: Vector2 =  character.global_position + Vector2(
			randi_range(-character.wander_radius.x, character.wander_radius.x),
			randi_range(-character.wander_radius.y, character.wander_radius.y)
			)
		path = character.pathfinding.get_simple_path(character.global_position, random_target)
		if path.is_empty():
			emit_signal("finished", "idle")
		else:
			if character.target != null:
				character._play_animation("walk_alert")
			else:
				character._play_animation("walk")
	else:
		emit_signal("finished", "idle")

func exit():
	path = []

func update(delta):
	if character._can_see_target():
		emit_signal("finished", "alert")
		return
	if path.is_empty():
		emit_signal("finished", "idle")
		return
	var next_point: Vector2 = path.front()
	while character.global_position.distance_to(next_point) < pathfinding_step_threshold:
		path.pop_front()
		if path.is_empty():
			emit_signal("finished", "idle")
			break
		next_point = path.front()
	character._set_velocity(next_point)
	character._apply_movement()

func _handle_body_entered(body):
	super(body)
	character.target = body
	
func _handle_body_exited(body):
	super(body)
	character.target = null
