
extends AbstractState

func enter():
	character.is_attacking = true
	if character._can_attack_target_ground():
		character._handle_ground_attack()
	elif character._can_attack_target_air():
		character._handle_air_attack()

func update(delta: float) -> void:
	character._handle_move()
	character._apply_movement()
	if !character.fx_anim.is_playing() && character.can_attack:
		if character._can_attack_target_ground():
			character._handle_ground_attack()
		elif character._can_attack_target_air():
			character._handle_air_attack()
		elif character._can_move_to_target():
			emit_signal("finished", "walk")
		else:
			emit_signal("finished", "idle")

func exit():
	character.is_attacking = false

func handle_event(event: String, value = null, isCrit = false) -> void:
	match event:
		"hit":
			character._handle_hit(value, isCrit)
			if character.is_dead:
				emit_signal("finished", "dead")

func _on_animation_finished(anim_name):
	if anim_name in character.ground_attacks || anim_name in character.air_attacks:
		character.gravity = 15
		character.can_attack = false
		character.attack_cooldown.start()
		emit_signal("finished", "walk")
