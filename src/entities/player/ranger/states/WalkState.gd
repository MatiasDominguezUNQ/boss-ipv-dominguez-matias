extends AbstractState


func enter() -> void:
	character.jumps = 0
	character._play_animation("walk", -1, character.move_speed)


func handle_input(event:InputEvent) -> void:
	if Input.is_action_just_pressed("jump") && character.can_grab_rope():
		emit_signal("finished", "rope_swing")
	elif Input.is_action_just_pressed("jump"):
		emit_signal("finished", "jump")
	elif Input.is_action_just_pressed("utility_skill"):
		emit_signal("finished", "roll")

func update(delta: float) -> void:
	character._handle_weapon_actions()
	character._handle_move_input()
	character._apply_movement()
	character.body_animations.speed_scale = character.move_speed
	if character.move_direction == 0:
		emit_signal("finished", "idle")
	else:
		if character.is_on_floor():
			character._play_animation("walk")
		else:
			emit_signal("finished", "jump")

func exit():
	character.body_animations.speed_scale = 1

func handle_event(event: String, value = null, isCrit = false) -> void:
	match event:
		"hit":
			character._handle_hit(value, isCrit)
			if character.is_dead:
				emit_signal("finished", "dead")
