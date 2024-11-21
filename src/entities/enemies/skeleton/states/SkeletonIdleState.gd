extends AbstractState


func enter() -> void:
	character._play_animation("idle")

func update(delta):
	character._handle_deacceleration()
	character._apply_movement()
	if character._can_attack_target():
		emit_signal("finished", "attack")
	elif character._can_move_to_target():
		emit_signal("finished", "walk")

func _on_animation_finished(anim_name):
	if anim_name == "hit":
		character._play_animation("idle")

func handle_event(event: String, value = null, isCrit = false) -> void:
	match event:
		"hit":
			character._handle_hit(value, isCrit)
			if character.is_dead:
				emit_signal("finished", "dead")
