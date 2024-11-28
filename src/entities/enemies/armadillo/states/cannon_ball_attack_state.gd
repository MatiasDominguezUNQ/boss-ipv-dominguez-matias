extends AbstractState


func enter():
	character._play_animation("start_attack")

func update(delta: float) -> void:
	character._apply_movement()
	if !character.acting() and character.can_attack and !character.is_attacking:
		if character._can_attack_target_ground():
			character.roll_attack()
		else: 
			character._play_animation("stop_attack")
	elif !character.can_attack:
		character.velocity = Vector2.ZERO
		character._play_animation("stop_attack")

func handle_event(event: String, value = null, isCrit = false) -> void:
	match event:
		"hit":
			character._handle_hit(value, isCrit)
			if character.is_dead:
				emit_signal("finished", "dead")

func _on_animation_finished(anim_name):
	if anim_name == "start_attack":
		print("attacking")
		character.roll_attack()
	if anim_name == "stop_attack":
		character.gravity = 15
		character.can_attack = false
		character.attack_cooldown.start()
		emit_signal("finished", "walk")
