extends AbstractEnemyState

func enter():
	character.velocity = Vector2.ZERO
	fire()

func fire():
	character._fire()
	character._play_animation("attack")
	character.body_sfx.stream = character.attack_sfx
	character.body_sfx.play()

func _on_animation_finished(animation) -> void:
	if character.target == null:
		emit_signal("finished", "idle")
	else:
		match animation:
			"attack":
				character._play_animation("alert")
			"alert":
				if character._can_see_target():
					fire()
				else:
					emit_signal("finished", "idle")

func _handle_body_exited(body):
	super(body)
	if character.target == null:
		if character.get_current_animation() != "attack":
			emit_signal("finished", "idle")
