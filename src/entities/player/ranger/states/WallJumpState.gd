extends AbstractState

func enter() -> void:
	character.jumps = 0
	character.is_sliding = true
	character.V_SPEED_LIMIT = 10
	character._play_animation("fall")

func exit():
	character.V_SPEED_LIMIT = character.jump_speed

func handle_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("jump"):
		emit_signal("finished", "jump")


# En esta función vamos a manejar las acciones apropiadas para este estado
func update(delta: float) -> void:
	character._handle_move_input()
	character._handle_deacceleration()
	character._apply_movement()
	if character.get_slide_collision_count() == 0:
		await get_tree().create_timer(0.1).timeout
		if character.get_slide_collision_count() == 0:
			character.is_sliding = false
			emit_signal("finished", "jump")
	if character.is_on_floor():
		character.is_sliding = false
		if character.move_direction == 0:
			emit_signal("finished", "idle")
		else:
			emit_signal("finished", "walk")

func handle_event(event: String, value = null, isCrit = false) -> void:
	match event:
		"hit":
			character._handle_hit(value, isCrit)
			if character.is_dead:
				emit_signal("finished", "dead")
		"spike_hit":
			character._handle_spike_hit()
			if character.is_dead:
				emit_signal("finished", "dead")
