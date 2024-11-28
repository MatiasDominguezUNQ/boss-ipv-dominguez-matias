extends AbstractState

func enter():
	character.is_dashing = true
	print("bat attacking")
	character.dash_attack()

func update(delta: float) -> void:
	character._apply_movement()
	if !character.acting() && character.can_attack and !character.is_dashing:
		if character._can_attack_target_air():
			character.dash_attack()
		elif character._can_move_to_target():
			emit_signal("finished", "walk")

func handle_event(event: String, value = null, isCrit = false) -> void:
	match event:
		"hit":
			character._handle_hit(value, isCrit)
			if character.is_dead:
				emit_signal("finished", "dead")

func _on_animation_finished(anim_name):
	if anim_name == "attack":
		print("done dashing")
		character.can_attack = false
		character.attack_cooldown.start()
		emit_signal("finished", "walk")
