extends AbstractState

func update(delta: float) -> void:
	character._handle_move()
	character._apply_movement()
	if !character.acting() && character.can_attack:
		if character._can_attack_target_ground():
			character._play_animation("attack")
		elif character._can_move_to_target():
			emit_signal("finished", "walk")
		else:
			emit_signal("finished", "idle")

func handle_event(event: String, value = null, isCrit = false) -> void:
	match event:
		"hit":
			character._handle_hit(value, isCrit)
			if character.is_dead:
				emit_signal("finished", "dead")

func _on_animation_finished(anim_name):
	if anim_name == "attack":
		character.gravity = 15
		character.can_attack = false
		character.attack_cooldown.start()
		emit_signal("finished", "walk")
