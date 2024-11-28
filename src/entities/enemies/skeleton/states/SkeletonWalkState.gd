extends AbstractState


# Called when the node enters the scene tree for the first time.
func enter() -> void:
	character._play_animation("walk")

func exit():
	character._play_animation("idle")

func update(delta):
	character._handle_move()
	character._apply_movement()
	if character._can_attack_target():
		emit_signal("finished", "attack")
	elif !character._can_move_to_target():
		emit_signal("finished", "idle")

func handle_event(event: String, value = null, isCrit = false) -> void:
	match event:
		"hit":
			character._handle_hit(value, isCrit)
			if character.is_dead:
				emit_signal("finished", "dead")
